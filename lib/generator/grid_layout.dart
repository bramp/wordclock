import 'dart:math';
import 'package:wordclock/generator/graph_types.dart';
import 'package:wordclock/model/word_grid.dart';

class GridLayout {
  /// Generates a list of cells of the given [width] from the [orderedResult] nodes.
  static List<String> generateCells(
    int width,
    List<Node> orderedResult,
    Graph graph,
    Random random, {
    required String paddingAlphabet,
  }) {
    final paddingCells = WordGrid.splitIntoCells(paddingAlphabet);
    final session = _GridLayoutSession(
      width: width,
      orderedResult: orderedResult,
      graph: graph,
      random: random,
      paddingCells: paddingCells,
    );
    return session.generate();
  }

  static List<String> _generatePadding(
    int length,
    Random random,
    List<String> paddingCells,
  ) {
    if (paddingCells.isEmpty) return List.filled(length, ' ');
    return List.generate(
      length,
      (index) => paddingCells[random.nextInt(paddingCells.length)],
    );
  }
}

/// Internal state for a single grid generation pass.
class _GridLayoutSession {
  final int width;
  final List<Node> orderedResult;
  final Graph graph;
  final Random random;
  final List<String> paddingCells;

  final List<String> _cells = [];
  List<_GridItem> _currentLineItems = [];
  int _currentLineLength = 0;

  late final Node? _firstNode;
  late final Node? _lastNode;

  _GridLayoutSession({
    required this.width,
    required this.orderedResult,
    required this.graph,
    required this.random,
    required this.paddingCells,
  }) {
    _firstNode = orderedResult.isNotEmpty ? orderedResult.first : null;
    _lastNode = orderedResult.isNotEmpty ? orderedResult.last : null;
  }

  List<String> generate() {
    int i = 0;
    Node? lastWordLastNode;

    while (i < orderedResult.length) {
      final wordNodes = _findNextWordBlock(i);
      final int wordLength = wordNodes.length;

      // Check if we need a gap between lastWordLastNode and wordNodes.first
      if (lastWordLastNode != null &&
          graph[lastWordLastNode]!.contains(wordNodes.first)) {
        _addGapIfNecessary();
      }

      // Check fit for the ENTIRE word
      if (_currentLineLength + wordLength > width) {
        _flushLine(isLastLine: false);
      }

      // Add word characters
      for (final wn in wordNodes) {
        _currentLineItems.add(_GridItem(wn.char, wn));
      }
      _currentLineLength += wordLength;
      lastWordLastNode = wordNodes.last;

      i += wordLength;
    }

    _flushLine(isLastLine: true);
    return _cells;
  }

  /// Finds the next contiguous block of nodes belonging to the same word.
  List<Node> _findNextWordBlock(int startIndex) {
    int j = startIndex + 1;
    while (j < orderedResult.length) {
      final prev = orderedResult[j - 1];
      final curr = orderedResult[j];
      if (prev.word != curr.word || !graph[prev]!.contains(curr)) {
        break;
      }
      j++;
    }
    return orderedResult.sublist(startIndex, j);
  }

  /// Adds a mandatory gap between words if they are in the same phrase.
  void _addGapIfNecessary() {
    if (_currentLineItems.isNotEmpty) {
      if (_currentLineLength + 1 > width) {
        _flushLine(isLastLine: false);
      } else {
        _currentLineItems.add(
          _GridItem(GridLayout._generatePadding(1, random, paddingCells).first),
        );
        _currentLineLength += 1;
      }
    }
  }

  /// Flushes the current line to the buffer, applying padding and pinning.
  void _flushLine({required bool isLastLine}) {
    if (_currentLineItems.isEmpty) return;

    final int paddingTotal = max(0, width - _currentLineLength);
    final List<String> lineCells = [];

    // 1. PIN TOP-LEFT
    if (_containsNode(_firstNode) &&
        _currentLineItems.first.node == _firstNode) {
      lineCells.addAll(_currentLineItems.map((e) => e.char));
      lineCells.addAll(
        GridLayout._generatePadding(paddingTotal, random, paddingCells),
      );
    }
    // 2. PIN BOTTOM-RIGHT
    else if (isLastLine && _containsNode(_lastNode)) {
      lineCells.addAll(
        GridLayout._generatePadding(paddingTotal, random, paddingCells),
      );
      lineCells.addAll(_currentLineItems.map((e) => e.char));
    }
    // 3. RANDOM SCATTER
    else {
      lineCells.addAll(_distributePadding(paddingTotal));
    }

    _cells.addAll(lineCells);
    _currentLineItems = [];
    _currentLineLength = 0;
  }

  bool _containsNode(Node? node) {
    if (node == null) return false;
    return _currentLineItems.any((item) => item.node == node);
  }

  /// Randomly distributes padding across all slots (before, after, and between units).
  List<String> _distributePadding(int paddingTotal) {
    final units = _groupItemsIntoUnits();
    final int numSlots = units.length + 1;
    final slotPaddings = List.filled(numSlots, 0);

    for (int p = 0; p < paddingTotal; p++) {
      slotPaddings[random.nextInt(numSlots)]++;
    }

    final List<String> lineCells = [];
    for (int s = 0; s < units.length; s++) {
      lineCells.addAll(
        GridLayout._generatePadding(slotPaddings[s], random, paddingCells),
      );
      lineCells.addAll(units[s]);
    }
    lineCells.addAll(
      GridLayout._generatePadding(slotPaddings.last, random, paddingCells),
    );
    return lineCells;
  }

  /// Groups items into "units" (contiguous words or single gaps) that shouldn't be split by padding.
  List<List<String>> _groupItemsIntoUnits() {
    List<List<String>> units = [];
    List<String> currentUnit = [];
    String? currentWord;

    for (final item in _currentLineItems) {
      if (item.node == null) {
        if (currentUnit.isNotEmpty) {
          units.add(currentUnit);
          currentUnit = [];
          currentWord = null;
        }
        units.add([item.char]);
      } else {
        if (currentWord != null && item.node!.word == currentWord) {
          currentUnit.add(item.char);
        } else {
          if (currentUnit.isNotEmpty) {
            units.add(currentUnit);
          }
          currentUnit = [item.char];
          currentWord = item.node!.word;
        }
      }
    }
    if (currentUnit.isNotEmpty) {
      units.add(currentUnit);
    }
    return units;
  }
}

/// Represents a single character in the grid during the layout process.
class _GridItem {
  /// The character to be displayed in the grid.
  final String char;

  /// The original [Node] this character belongs to, if any.
  /// Padding and gap characters will have a null [node].
  final Node? node;

  _GridItem(this.char, [this.node]);
}
