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
    // 1. Collect all atom blocks.
    final List<List<Node>> atomBlocks = [];
    int idx = 0;
    while (idx < orderedResult.length) {
      final block = _findNextAtomBlock(idx);
      atomBlocks.add(block);
      idx += block.length;
    }

    if (atomBlocks.isEmpty) {
      // Return empty grid or padding-only grid based on targetHeight.
      return List.filled(width * targetHeight, ' ');
    }

    // 2. Determine mandatory gaps between atom blocks.
    final List<bool> gapAfter = List.filled(atomBlocks.length, false);
    if (requiresPadding) {
      for (int i = 0; i < atomBlocks.length - 1; i++) {
        final lastOfPrev = atomBlocks[i].last;
        final firstOfNext = atomBlocks[i + 1].first;
        if (graph[lastOfPrev]!.contains(firstOfNext)) {
          gapAfter[i] = true;
        }
      }
    }

    // 3. Helper to calculate cell length of a block.
    int getCellLength(List<Node> block) {
      return block.where((n) => !_isApostrophe(n.char)).length;
    }

    final List<int> blockCellLengths = atomBlocks.map(getCellLength).toList();

    double targetCellsPerLine = 0;
    if (targetHeight > 0) {
      int totalCells =
          orderedResult.length -
          orderedResult.where((n) => _isApostrophe(n.char)).length;

      targetCellsPerLine = totalCells / targetHeight;
      // Ensure we don't try to fit more than fits
      if (targetCellsPerLine > width) targetCellsPerLine = width.toDouble();
    }
    // 4. Balanced packing using DP? Actually, since we want to hit a specific
    // targetHeight, let's use a simpler heuristic or a target-aware greedy.
    // If targetHeight is not set, we just use greedy.
    if (targetHeight <= 0) {
      return _generateGreedy(atomBlocks, gapAfter, blockCellLengths);
    }

    // High level DP approach:
    // cost[i][h] = min cost to pack first i blocks into h lines.
    // cost[i][h] = min_{j < i} (cost[j][h-1] + line_cost(blocks j..i-1))
    // where line_cost = (width - usedCells)^2 or something similar.

    final int n = atomBlocks.length;
    final int h = targetHeight;

    // cost[blocks_count][lines_count]
    final List<List<double>> dp = List.generate(
      n + 1,
      (_) => List.filled(h + 1, double.infinity),
    );
    final List<List<int>> parent = List.generate(
      n + 1,
      (_) => List.filled(h + 1, -1),
    );

    dp[0][0] = 0;

    double lineCost(int start, int end) {
      int cells = 0;
      for (int k = start; k < end; k++) {
        cells += blockCellLengths[k];
        if (k < end - 1 && gapAfter[k]) {
          cells += 1; // Mandatory gap
        }
      }
      if (cells > width) return double.infinity;
      // We want lines to be balanced. Ideal length is totalCells / targetHeight.
      return pow((width - cells), 2).toDouble();
    }

    for (int line = 1; line <= h; line++) {
      for (int i = 1; i <= n; i++) {
        for (int j = 0; j < i; j++) {
          if (dp[j][line - 1] == double.infinity) continue;
          double lc = lineCost(j, i);
          if (lc == double.infinity) continue;
          double totalCost = dp[j][line - 1] + lc;
          if (totalCost < dp[i][line]) {
            dp[i][line] = totalCost;
            parent[i][line] = j;
          }
        }
      }
    }

    // If we couldn't find a way to pack into exactly `h` lines, fallback to greedy.
    if (dp[n][h] == double.infinity) {
      // ignore: avoid_print
      print(
        'Warning: Balanced packing failed for targetHeight $h, falling back to greedy.',
      );
      return _generateGreedy(atomBlocks, gapAfter, blockCellLengths);
    }

    // Backtrack to find split points.
    final List<int> splits = [];
    int currN = n;
    for (int currH = h; currH > 0; currH--) {
      splits.add(currN);
      currN = parent[currN][currH];
    }
    splits.add(0);
    final splitPoints = splits.reversed.toList();

    // Reconstruct lines.
    for (int k = 0; k < splitPoints.length - 1; k++) {
      final start = splitPoints[k];
      final end = splitPoints[k + 1];
      for (int i = start; i < end; i++) {
        // Add atom characters
        for (final wn in atomBlocks[i]) {
          _currentLineItems.add(_GridItem(wn.char, wn));
          if (!_isApostrophe(wn.char)) {
            _currentLineLength += 1;
          }
        }
        // Add gap if needed and NOT at end of line
        if (i < end - 1 && gapAfter[i]) {
          _addGapIfNecessary();
        }
      }
      _flushLine(isLastLine: (k == splitPoints.length - 2));
    }

    return _cells;
  }

  List<String> _generateGreedy(
    List<List<Node>> atomBlocks,
    List<bool> gapAfter,
    List<int> blockCellLengths,
  ) {
    _cells.clear();
    _currentLineItems = [];
    _currentLineLength = 0;

    for (int i = 0; i < atomBlocks.length; i++) {
      final int atomCellLength = blockCellLengths[i];
      final bool needsGap = i > 0 && gapAfter[i - 1];

      int spaceNeeded = atomCellLength;
      if (needsGap) spaceNeeded += 1;

      if (_currentLineLength + spaceNeeded > width) {
        _flushLine(isLastLine: false);
      }

      if (i > 0 && gapAfter[i - 1]) {
        _addGapIfNecessary();
      }

      for (final wn in atomBlocks[i]) {
        _currentLineItems.add(_GridItem(wn.char, wn));
        if (!_isApostrophe(wn.char)) {
          _currentLineLength += 1;
        }
      }
    }

    _flushLine(isLastLine: true);

    // Add extra padding rows if short
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
