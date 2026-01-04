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
    bool requiresPadding = true,
    int targetHeight = 0,
  }) {
    final paddingCells = WordGrid.splitIntoCells(paddingAlphabet);
    final session = _GridLayoutSession(
      width: width,
      orderedResult: orderedResult,
      graph: graph,
      random: random,
      paddingCells: paddingCells,
      requiresPadding: requiresPadding,
      targetHeight: targetHeight,
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
  final bool requiresPadding;
  final int targetHeight;

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
    this.requiresPadding = true,
    this.targetHeight = 0,
  }) {
    _firstNode = orderedResult.isNotEmpty ? orderedResult.first : null;
    _lastNode = orderedResult.isNotEmpty ? orderedResult.last : null;
  }

  List<String> generate() {
    int i = 0;
    Node? lastAtomLastNode;

    // Estimate line length (in cells) to hit targetHeight
    double targetCellsPerLine = width.toDouble();
    if (targetHeight > 0) {
      int totalCells =
          orderedResult.length -
          orderedResult.where((n) => _isApostrophe(n.char)).length;
      targetCellsPerLine = totalCells / targetHeight;
      // Ensure we don't try to fit more than fits
      if (targetCellsPerLine > width) targetCellsPerLine = width.toDouble();
    }

    while (i < orderedResult.length) {
      final atomNodes = _findNextAtomBlock(i);
      // Atom length in cells
      final int atomCellLength = atomNodes
          .where((n) => !_isApostrophe(n.char))
          .length;

      // Check if we need a gap between lastAtomLastNode and atomNodes.first
      if (requiresPadding &&
          lastAtomLastNode != null &&
          graph[lastAtomLastNode]!.contains(atomNodes.first)) {
        _addGapIfNecessary();
      }

      // Decide whether to wrap to next line.
      bool shouldWrap = false;
      if (_currentLineLength + atomCellLength > width) {
        shouldWrap = true;
      } else if (targetHeight > 0 && _currentLineLength > 0) {
        if (_currentLineLength >= targetCellsPerLine) {
          shouldWrap = true;
        }
      }

      if (shouldWrap) {
        _flushLine(isLastLine: false);
      }

      // Add atom characters to GridItems
      for (final wn in atomNodes) {
        _currentLineItems.add(_GridItem(wn.char, wn));
        if (!_isApostrophe(wn.char)) {
          _currentLineLength += 1;
        }
      }
      lastAtomLastNode = atomNodes.last;

      i += atomNodes.length;
    }

    _flushLine(isLastLine: true);

    // Add extra padding rows if we are still short of targetHeight
    if (targetHeight > 0) {
      int currentHeight = _cells.length ~/ width;
      while (currentHeight < targetHeight) {
        _cells.addAll(GridLayout._generatePadding(width, random, paddingCells));
        currentHeight++;
      }
    }

    return _cells;
  }

  /// Finds the next contiguous block of nodes belonging to the same atom (word or character).
  List<Node> _findNextAtomBlock(int startIndex) {
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

  /// Adds a mandatory gap between atoms if they are in the same phrase.
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

  /// Randomly distributes padding across all slots (before, after, and between atoms).
  List<String> _distributePadding(int paddingTotal) {
    final atoms = _groupItemsIntoAtoms();
    final int numSlots = atoms.length + 1;
    final slotPaddings = List.filled(numSlots, 0);

    for (int p = 0; p < paddingTotal; p++) {
      slotPaddings[random.nextInt(numSlots)]++;
    }

    final List<String> lineCells = [];
    for (int s = 0; s < atoms.length; s++) {
      lineCells.addAll(
        GridLayout._generatePadding(slotPaddings[s], random, paddingCells),
      );
      lineCells.addAll(atoms[s]);
    }
    lineCells.addAll(
      GridLayout._generatePadding(slotPaddings.last, random, paddingCells),
    );
    return lineCells;
  }

  /// Groups GridItems into "atoms" (contiguous words or single gaps) that shouldn't be split by padding.
  List<List<String>> _groupItemsIntoAtoms() {
    List<List<String>> atoms = [];
    List<String> currentAtom = [];
    String? currentAtomName;

    for (final item in _currentLineItems) {
      if (item.node == null) {
        if (currentAtom.isNotEmpty) {
          atoms.add(currentAtom);
          currentAtom = [];
          currentAtomName = null;
        }
        atoms.add([item.char]);
      } else {
        if (currentAtomName != null && item.node!.word == currentAtomName) {
          currentAtom.add(item.char);
        } else {
          if (currentAtom.isNotEmpty) {
            atoms.add(currentAtom);
          }
          currentAtom = [item.char];
          currentAtomName = item.node!.word;
        }
      }
    }
    if (currentAtom.isNotEmpty) {
      atoms.add(currentAtom);
    }
    return atoms;
  }

  bool _isApostrophe(String char) => char == "'" || char == "’";
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
