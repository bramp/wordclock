import 'dart:math';
import 'package:wordclock/generator/greedy/graph_types.dart';
import 'package:wordclock/model/word_grid.dart';

/// A layout engine that arranges character nodes into a grid.
///
/// It supports two modes:
/// 1. **Greedy**: Fills lines as much as possible, moving to the next line
///    when an atom (word) doesn't fit.
/// 2. **Balanced (DP)**: Attempts to distribute atoms across a fixed number
///    of lines ([targetHeight]) to minimize the variance in line lengths.
class GridLayout {
  /// Generates a list of cells of the given [width] from the [orderedResult] nodes.
  ///
  /// Parameters:
  /// - [width]: The fixed width of the grid.
  /// - [orderedResult]: A topologically sorted list of character nodes.
  /// - [graph]: The dependency graph used to identify mandatory gaps.
  /// - [random]: Random number generator for padding.
  /// - [paddingAlphabet]: Characters to use for filling empty spaces.
  /// - [requiresPadding]: Whether to insert gaps between words in a phrase.
  /// - [targetHeight]: If > 0, attempts to fit the grid into exactly this many rows.
  ///
  /// Example:
  /// ```dart
  /// final result = GridLayout.generateCells(
  ///   11,
  ///   nodes,
  ///   graph,
  ///   random,
  ///   paddingAlphabet: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
  /// );
  /// final cells = result.cells;
  /// final placements = result.placements;
  /// ```
  static ({List<String> cells, List<RawPlacement> placements}) generateCells(
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
    final cells = session.generate();
    return (cells: cells, placements: session.placements);
  }

  /// Generates a random sequence of padding characters of the given [length].
  ///
  /// If [paddingCells] is empty, it returns a list of spaces.
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

/// A simple internal representation of a word placement for the greedy algorithm
class RawPlacement {
  final String word;
  final int startOffset;
  final int length;
  RawPlacement(this.word, this.startOffset, this.length);
}

/// Internal state for a single grid generation pass.
///
/// This class encapsulates the logic for packing atoms into lines,
/// handling mandatory gaps, and applying padding.
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

  final List<RawPlacement> placements = [];

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

  /// Orchestrates the generation process.
  ///
  /// It first identifies "atom blocks" (sequences of characters that must stay
  /// together), then uses either a Dynamic Programming approach (if [targetHeight]
  /// is set) or a greedy approach to pack them into lines.
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
      return block.length;
    }

    final List<int> blockCellLengths = atomBlocks.map(getCellLength).toList();

    int totalMandatoryGaps = gapAfter.where((g) => g).length;

    double targetCellsPerLine = 0;
    if (targetHeight > 0) {
      int totalCells = orderedResult.length;

      // ignore: avoid_print
      print(
        'GridLayout: totalCells=$totalCells, mandatoryGaps=$totalMandatoryGaps, targetHeight=$targetHeight',
      );

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
          _addItem(wn.char, wn);
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

  /// Packs atoms into lines using a greedy approach.
  ///
  /// This is used when [targetHeight] is not specified or when balanced packing fails.
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
        _addItem(wn.char, wn);
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
  ///
  /// An atom block is a sequence of nodes that must stay together on the same line.
  /// It checks for:
  /// 1. Same word.
  /// 2. Sequential character indices.
  /// 3. Direct edge in the dependency graph.
  List<Node> _findNextAtomBlock(int startIndex) {
    int j = startIndex + 1;
    while (j < orderedResult.length) {
      final prev = orderedResult[j - 1];
      final curr = orderedResult[j];
      if (prev.word != curr.word ||
          prev.charIndex + 1 != curr.charIndex ||
          !graph[prev]!.contains(curr)) {
        break;
      }
      j++;
    }
    return orderedResult.sublist(startIndex, j);
  }

  /// Adds a mandatory gap between atoms if they are in the same phrase.
  ///
  /// If the gap doesn't fit on the current line, it flushes the line first.
  void _addGapIfNecessary() {
    if (_currentLineItems.isNotEmpty) {
      if (_currentLineLength + 1 > width) {
        _flushLine(isLastLine: false);
      } else {
        _addPadding(1);
      }
    }
  }

  /// Adds a single character item to the current line.
  void _addItem(String char, Node? node) {
    _currentLineItems.add(_GridItem(char, node));
    _currentLineLength += 1;
  }

  /// Adds random padding characters to the current line.
  void _addPadding(int length) {
    final padding = GridLayout._generatePadding(length, random, paddingCells);
    for (final p in padding) {
      _currentLineItems.add(_GridItem(p));
      _currentLineLength += 1;
    }
  }

  List<_GridItem> _generatePaddingItems(int length) {
    if (length <= 0) return [];
    final padding = GridLayout._generatePadding(length, random, paddingCells);
    return padding.map((p) => _GridItem(p)).toList();
  }

  /// Flushes the current line to the buffer, applying padding and pinning.
  void _flushLine({required bool isLastLine}) {
    if (_currentLineItems.isEmpty) return;

    final int paddingTotal = max(0, width - _currentLineLength);
    final List<_GridItem> lineItems = [];

    // 1. PIN TOP-LEFT
    if (_containsNode(_firstNode) &&
        _currentLineItems.first.node == _firstNode) {
      lineItems.addAll(_currentLineItems);
      lineItems.addAll(_generatePaddingItems(paddingTotal));
    }
    // 2. PIN BOTTOM-RIGHT
    else if (isLastLine && _containsNode(_lastNode)) {
      lineItems.addAll(_generatePaddingItems(paddingTotal));
      lineItems.addAll(_currentLineItems);
    }
    // 3. RANDOM SCATTER
    else {
      lineItems.addAll(_distributePaddingItems(paddingTotal));
    }

    // Record placements
    final int rowOffset = _cells.length;

    String? currentWord;
    int? wordStart;
    int wordLen = 0;

    void flushWord() {
      if (currentWord != null && wordStart != null) {
        placements.add(
          RawPlacement(currentWord!, rowOffset + wordStart!, wordLen),
        );
      }
      currentWord = null;
      wordStart = null;
      wordLen = 0;
    }

    for (int i = 0; i < lineItems.length; i++) {
      final item = lineItems[i];
      final node = item.node;

      if (node != null) {
        if (currentWord != node.word) {
          flushWord();
          currentWord = node.word;
          wordStart = i;
          wordLen = 1;
        } else {
          wordLen++;
        }
      } else {
        flushWord();
      }
    }
    flushWord();

    _cells.addAll(lineItems.map((e) => e.char));
    _currentLineItems = [];
    _currentLineLength = 0;
  }

  bool _containsNode(Node? node) {
    if (node == null) return false;
    return _currentLineItems.any((item) => item.node == node);
  }

  /// Randomly distributes padding across all slots (before, after, and between atoms).
  List<_GridItem> _distributePaddingItems(int paddingTotal) {
    final atoms = _groupItemsIntoAtoms();
    final int numSlots = atoms.length + 1;
    final slotPaddings = List.filled(numSlots, 0);

    for (int p = 0; p < paddingTotal; p++) {
      slotPaddings[random.nextInt(numSlots)]++;
    }

    final List<_GridItem> lineItems = [];
    for (int s = 0; s < atoms.length; s++) {
      lineItems.addAll(_generatePaddingItems(slotPaddings[s]));
      lineItems.addAll(atoms[s]);
    }
    lineItems.addAll(_generatePaddingItems(slotPaddings.last));
    return lineItems;
  }

  /// Groups GridItems into "atoms" (contiguous words or single gaps) that shouldn't be split by padding.
  List<List<_GridItem>> _groupItemsIntoAtoms() {
    List<List<_GridItem>> atoms = [];
    List<_GridItem> currentAtom = [];
    String? currentAtomName;

    for (final item in _currentLineItems) {
      if (item.node == null) {
        if (currentAtom.isNotEmpty) {
          atoms.add(currentAtom);
          currentAtom = [];
          currentAtomName = null;
        }
        atoms.add([item]);
      } else {
        if (currentAtomName != null && item.node!.word == currentAtomName) {
          currentAtom.add(item);
        } else {
          if (currentAtom.isNotEmpty) {
            atoms.add(currentAtom);
          }
          currentAtom = [item];
          currentAtomName = item.node!.word;
        }
      }
    }
    if (currentAtom.isNotEmpty) {
      atoms.add(currentAtom);
    }
    return atoms;
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
