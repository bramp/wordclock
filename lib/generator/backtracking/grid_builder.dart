import 'dart:math';
import 'package:wordclock/generator/backtracking/grid_state.dart';
import 'package:wordclock/generator/backtracking/graph/dependency_graph.dart';
import 'package:wordclock/generator/backtracking/graph/graph_builder.dart';
import 'package:wordclock/generator/backtracking/graph/word_node.dart';
import 'package:wordclock/generator/backtracking/graph/phrase_trie.dart';
import 'package:wordclock/generator/utils/grid_build_result.dart';
import 'package:wordclock/generator/utils/grid_validator.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/types.dart';
import 'package:wordclock/model/word_grid.dart';

/// Progress information during grid building.
class GridBuildProgress {
  /// Best number of words placed so far
  final int bestWords;

  /// Total words to place
  final int totalWords;

  /// Grid width
  final int width;

  /// Current grid cells (for colored display)
  final List<String> cells;

  /// Word placement info (for colored display)
  final List<PlacedWordInfo> wordPlacements;

  /// Number of iterations (recursive calls) so far
  final int iterationCount;

  /// When the search started
  final DateTime startTime;

  /// Words placed in current search path
  int get currentWords => wordPlacements.length;

  GridBuildProgress({
    required this.bestWords,
    required this.totalWords,
    required this.width,
    required this.cells,
    required this.wordPlacements,
    required this.iterationCount,
    required this.startTime,
  });
}

/// Callback for progress updates during grid building.
/// Return true to continue, false to stop the search.
typedef ProgressCallback = bool Function(GridBuildProgress progress);

/// A backtracking-based grid builder that finds optimal word placements.
class BacktrackingGridBuilder {
  final int width;
  final int height;
  final WordClockLanguage language;
  final Random random;

  /// The word dependency graph
  late final WordDependencyGraph graph;

  /// Cell codec for encoding/decoding cells to integers
  late final CellCodec codec;

  /// Padding alphabet cells
  final List<Cell> paddingCells;

  /// Padding cell codes (pre-encoded for efficiency)
  late final List<int> paddingCellCodes;

  /// If true, stop after finding the first valid grid (all words placed).
  /// If false (default), continue searching for optimal (minimum height) grid.
  final bool findFirstValid;

  /// If true (default), use frontier-based solving where words become eligible
  /// as soon as their dependencies are satisfied.
  /// If false, use rank-based solving where all words in a rank must complete
  /// before moving to the next rank.
  final bool useFrontier;

  /// Optional callback for progress updates (called at most once per second).
  /// Return true to continue, false to stop the search.
  final ProgressCallback? onProgress;

  /// Internal state for the best grid found
  GridState? _bestState;
  int _minHeightFound = 1000;
  int _maxWordsPlaced = -1;
  int _totalWords = 0;
  bool _stopRequested = false;
  DateTime _lastProgressReport = DateTime.now();
  int _iterationCount = 0;
  late DateTime _startTime;
  StopReason _stopReason = StopReason.completed;

  BacktrackingGridBuilder({
    required this.width,
    required this.height,
    required this.language,
    required int seed,
    this.findFirstValid = true,
    this.useFrontier = true,
    this.onProgress,
  }) : random = Random(seed),
       paddingCells = WordGrid.splitIntoCells(language.paddingAlphabet);

  /// Attempts to build a grid that satisfies all constraints.
  GridBuildResult build() {
    // 1. Build word dependency graph (this also creates the CellCodec)
    graph = WordDependencyGraphBuilder.build(language: language);
    codec = graph.codec;

    // Pre-encode padding cells
    paddingCellCodes = codec.encodeAll(paddingCells);

    // 2. Initialize search
    final state = GridState(width: width, height: height, codec: codec);
    _minHeightFound = height; // Initial target height
    _maxWordsPlaced = -1;
    _bestState = null;
    _stopRequested = false;
    _lastProgressReport = DateTime.now();
    _iterationCount = 0;
    _startTime = DateTime.now();
    _stopReason = StopReason.completed;

    // 3. Get all nodes
    final allNodes = graph.nodes.values.expand((i) => i).toList();
    _totalWords = allNodes.length;

    // 4. Solve using selected approach
    if (useFrontier) {
      _solveWithFrontier(state, allNodes);
    } else {
      _solveWithRanks(state, allNodes);
    }

    // 5. Build Result
    final finalState = _bestState;
    int placedWords = 0;
    List<String> gridCells;
    List<PlacedWordInfo> wordPlacements = [];

    if (finalState != null) {
      placedWords = finalState.nodePlacements.length;
      wordPlacements = _extractPlacements(finalState);
      _fillPadding(finalState);
      gridCells = finalState.toFlatList();
    } else {
      // Fallback: Empty grid if failed
      gridCells = List.filled(width * height, ' ');
    }

    final gridToValidate = WordGrid(width: width, cells: gridCells);
    final validationIssues = GridValidator.validate(gridToValidate, language);

    return GridBuildResult(
      grid: gridCells,
      validationIssues: validationIssues,
      totalWords: _totalWords,
      placedWords: placedWords,
      wordPlacements: wordPlacements,
      iterationCount: _iterationCount,
      startTime: _startTime,
      stopReason: _stopReason,
    );
  }

  void _reportProgress(DateTime now, GridState state) {
    if (now.difference(_lastProgressReport).inSeconds < 1) return;
    if (onProgress == null) return;

    _lastProgressReport = now;
    final shouldContinue = onProgress!(
      GridBuildProgress(
        bestWords: _maxWordsPlaced,
        totalWords: _totalWords,
        width: width,
        cells: state.toFlatList(),
        wordPlacements: _extractPlacements(state),
        iterationCount: _iterationCount,
        startTime: _startTime,
      ),
    );
    if (!shouldContinue) {
      _stopRequested = true;
      _stopReason = StopReason.userStopped;
    }
  }

  /// Extracts word placement info from a GridState
  List<PlacedWordInfo> _extractPlacements(GridState state) {
    return state.nodePlacements.entries.map((entry) {
      final node = entry.key;
      final placement = entry.value;
      return PlacedWordInfo(
        word: node.word,
        row: placement.row,
        startCol: placement.startCol,
        endCol: placement.endCol,
      );
    }).toList();
  }

  /// Returns true if search should stop
  bool get _shouldStop =>
      _stopRequested || (findFirstValid && _maxWordsPlaced == _totalWords);

  /// Sets up and runs frontier-based solving using bitset for eligible tracking
  void _solveWithFrontier(GridState state, List<WordNode> allNodes) {
    // Bitset is limited to 64 bits (Dart int is 64-bit)
    assert(
      allNodes.length <= 64,
      'Frontier solver limited to 64 nodes, got ${allNodes.length}. '
      'Use --use-ranks flag for languages with more words.',
    );

    // Sort all nodes by length (longest first) - this way iterating bits in order
    // gives us the preferred ordering
    allNodes.sort((a, b) => b.cellCodes.length.compareTo(a.cellCodes.length));

    // Map node -> index for quick lookup (after sorting!)
    final nodeIndex = <WordNode, int>{};
    for (int i = 0; i < allNodes.length; i++) {
      nodeIndex[allNodes[i]] = i;
    }

    // Pre-compute successor indices for each node
    final successorIndices = <List<int>>[];
    for (final node in allNodes) {
      final succs = graph.edges[node] ?? <WordNode>{};
      successorIndices.add(succs.map((s) => nodeIndex[s]!).toList());
    }

    // Compute initial in-degree for each node (count of predecessors)
    final inDegree = List<int>.filled(allNodes.length, 0);
    for (final entry in graph.edges.entries) {
      for (final succ in entry.value) {
        inDegree[nodeIndex[succ]!]++;
      }
    }

    // Initial eligible mask: nodes with in-degree 0 (no predecessors)
    int eligibleMask = 0;
    for (int i = 0; i < allNodes.length; i++) {
      if (inDegree[i] == 0) {
        eligibleMask |= (1 << i);
      }
    }

    _solveFrontier(state, allNodes, successorIndices, inDegree, eligibleMask);
  }

  /// Sets up and runs rank-based solving
  void _solveWithRanks(GridState state, List<WordNode> allNodes) {
    // Group nodes by rank (topological level)
    final ranks = computeRanks(graph);
    final maxRank = ranks.values.fold(0, (a, b) => a > b ? a : b);

    final rankNodes = List.generate(maxRank + 1, (_) => <WordNode>[]);
    for (final node in allNodes) {
      rankNodes[ranks[node]!].add(node);
    }

    // Sort each rank by word length (longest first for better packing)
    for (final rank in rankNodes) {
      rank.sort((a, b) => b.cellCodes.length.compareTo(a.cellCodes.length));
    }

    // Start with all words in rank 0 as remaining
    final initialMask = rankNodes.isNotEmpty
        ? (1 << rankNodes[0].length) - 1
        : 0;
    _solve(state, rankNodes, 0, initialMask);
  }

  /// Frontier-based recursive solve function using bitset.
  /// Words become eligible when all their dependencies (predecessors) are placed.
  /// [eligibleMask] is a bitmask where bit i set means node i is eligible for placement.
  /// [inDegree] tracks how many unplaced predecessors each node has.
  void _solveFrontier(
    GridState state,
    List<WordNode> allNodes,
    List<List<int>> successorIndices,
    List<int> inDegree,
    int eligibleMask,
  ) {
    _iterationCount++;
    final placedWords = state.nodePlacements.length;

    // Periodically report progress
    if (_iterationCount % 1000 == 0) {
      final now = DateTime.now();
      _reportProgress(now, state);
      if (_shouldStop) return;
    }

    // Update best found so far
    if (placedWords > _maxWordsPlaced) {
      _maxWordsPlaced = placedWords;
      _bestState = state.clone();
    }

    // Pruning: if height exceeds best, backtrack
    final currentHeight = state.maxRowUsed + 1;
    if (currentHeight > _minHeightFound) return;

    // All words placed?
    if (placedWords == allNodes.length) {
      if (currentHeight <= _minHeightFound) {
        _minHeightFound = currentHeight;
        _bestState = state.clone();
      }
      return;
    }

    // No eligible words but not all placed - dead end
    if (eligibleMask == 0) return;

    // Try each eligible word (iterate over set bits)
    int mask = eligibleMask;
    while (mask != 0) {
      // Get index of lowest set bit
      final lowestBit = mask & -mask;
      final nodeIdx = lowestBit.bitLength - 1;
      mask &= mask - 1; // Clear lowest bit for next iteration

      final node = allNodes[nodeIdx];

      // Find earliest valid placement
      final (r, c) = findEarliestPlacementByPhrase(state, node);

      if (r != -1) {
        final p = state.placeWord(node, r, c);
        if (p != null) {
          // Update trie cache
          for (final trieNode in node.ownedTrieNodes) {
            trieNode.cachedPosition = (p.row, p.endCol);
          }

          // Update eligible mask: remove placed node
          int newEligibleMask = eligibleMask & ~lowestBit;

          // Decrement in-degree of successors and add newly eligible
          for (final succIdx in successorIndices[nodeIdx]) {
            inDegree[succIdx]--;
            if (inDegree[succIdx] == 0) {
              newEligibleMask |= (1 << succIdx);
            }
          }

          // Recurse
          _solveFrontier(
            state,
            allNodes,
            successorIndices,
            inDegree,
            newEligibleMask,
          );

          // Restore in-degree for successors
          for (final succIdx in successorIndices[nodeIdx]) {
            inDegree[succIdx]++;
          }

          // Clear trie cache and remove placement
          for (final trieNode in node.ownedTrieNodes) {
            trieNode.cachedPosition = null;
          }
          state.removePlacement(p);
        }
      }

      if (_shouldStop) return;
    }
  }

  /// Rank-based recursive solve function.
  /// Processes words rank-by-rank (topological levels).
  /// [remainingMask] is a bitmask where bit i set means rankNodes[rankIndex][i]
  /// is still remaining to be placed.
  void _solve(
    GridState state,
    List<List<WordNode>> rankNodes,
    int rankIndex,
    int remainingMask,
  ) {
    _iterationCount++;
    final placedWords = state.nodePlacements.length;

    // Periodically report progress (check every 1000 iterations to avoid DateTime overhead)
    if (_iterationCount % 1000 == 0) {
      final now = DateTime.now();
      _reportProgress(now, state);
      if (_shouldStop) return;
    }

    // Update best found so far (even if partial)
    if (placedWords > _maxWordsPlaced) {
      _maxWordsPlaced = placedWords;
      _bestState = state.clone();
    }

    // Pruning: If currently used height already exceeds our best found, backtrack.
    // We check maxRowUsed + 1 (the current height).
    final currentHeight = state.maxRowUsed + 1;
    if (currentHeight > _minHeightFound) return;

    // Finished all ranks?
    if (rankIndex >= rankNodes.length) {
      if (currentHeight <= _minHeightFound) {
        _minHeightFound = currentHeight;
        _bestState = state.clone();
      }
      return;
    }

    // Finished current rank? Move to next.
    if (remainingMask == 0) {
      final nextRankIndex = rankIndex + 1;
      final nextMask = nextRankIndex < rankNodes.length
          ? (1 << rankNodes[nextRankIndex].length) - 1
          : 0;
      _solve(state, rankNodes, nextRankIndex, nextMask);
      return;
    }

    // Try each remaining word in this rank (iterate over set bits)
    final rankList = rankNodes[rankIndex];
    int mask = remainingMask;
    while (mask != 0) {
      // Get index of lowest set bit: (mask & -mask) isolates it,
      // then bitLength - 1 gives the 0-based index
      final lowestBit = mask & -mask;
      final i = lowestBit.bitLength - 1;
      mask &= mask - 1; // Clear the lowest set bit for next iteration

      final node = rankList[i];

      // Find EARLIEST valid placement for this word
      final (r, c) = findEarliestPlacementByPhrase(state, node);

      if (r != -1) {
        final p = state.placeWord(node, r, c);
        if (p != null) {
          // Update trie cache: set position on all trie nodes this word owns
          for (final trieNode in node.ownedTrieNodes) {
            trieNode.cachedPosition = (p.row, p.endCol);
          }

          // Recurse with this word removed from mask (no allocation needed!)
          _solve(state, rankNodes, rankIndex, remainingMask & ~lowestBit);

          // Clear trie cache before removal
          for (final trieNode in node.ownedTrieNodes) {
            trieNode.cachedPosition = null;
          }
          state.removePlacement(p);
        }
      }

      if (_shouldStop) return;
    }
  }

  /// Finds the earliest valid placement for a word by scanning phrases left-to-right.
  ///
  /// This method uses the pre-computed predecessor cells for each phrase and scans
  /// the grid to find placements for each predecessor word in reading order. The earliest
  /// valid position is after the MAX end position across all phrases.
  ///
  /// This differs from [findEarliestPlacement] which uses the pre-computed graph edges.
  /// The phrase-based approach correctly handles cases where duplicate words may
  /// already be satisfied by earlier placements.
  ///
  /// Uses a pre-computed trie of predecessor sequences to deduplicate work when
  /// multiple phrases share common prefixes.
  ///
  /// Returns (-1, -1) if a required predecessor word is not found on the grid.
  (int, int) findEarliestPlacementByPhrase(GridState state, WordNode node) {
    // If this word can be first in any phrase, it can start at (0, 0)
    if (node.hasEmptyPredecessor) {
      return _findFirstValidPlacement(state, node, 0, 0);
    }

    // Try to find max end position using the index
    final maxPos = _findMaxPredecessorPositionUsingIndex(
      state,
      node.phraseTrieNodes,
    );
    if (maxPos == null) {
      return (-1, -1); // No predecessor sequences satisfied yet
    }

    // Calculate the minimum starting position after the max end position
    int minRow = maxPos.$1;
    int minCol = maxPos.$2 + (language.requiresPadding ? 2 : 1);

    if (minCol >= width) {
      minRow++;
      minCol = 0;
    }

    return _findFirstValidPlacement(state, node, minRow, minCol);
  }

  /// Find max predecessor end position by reading cached positions from trie nodes.
  ///
  /// Each terminal node represents the end of a predecessor sequence.
  /// Returns the max terminal position, or null if no predecessors are placed yet.
  ///
  /// Note: We only check the terminal node, not its ancestors. This works because
  /// words are placed in dependency order - if a terminal has a cached position,
  /// all its predecessors must already be placed.
  (int, int)? _findMaxPredecessorPositionUsingIndex(
    GridState state,
    List<PhraseTrieNode> terminalNodes,
  ) {
    int maxRow = -1;
    int maxCol = -1;
    bool anyFound = false;

    // For each terminal node (end of a predecessor sequence),
    // check if it has a cached position
    for (final terminal in terminalNodes) {
      final endPos = terminal.cachedPosition;
      if (endPos != null) {
        anyFound = true;
        if (endPos.$1 > maxRow || (endPos.$1 == maxRow && endPos.$2 > maxCol)) {
          maxRow = endPos.$1;
          maxCol = endPos.$2;
        }
      }
    }

    return anyFound ? (maxRow, maxCol) : null;
  }

  /// Find first valid placement starting from (minRow, minCol).
  (int, int) _findFirstValidPlacement(
    GridState state,
    WordNode node,
    int minRow,
    int minCol,
  ) {
    for (int r = minRow; r < _minHeightFound; r++) {
      int cStart = (r == minRow) ? minCol : 0;
      for (int c = cStart; c <= width - node.cellCodes.length; c++) {
        final (canPlace, _) = _checkPlacement(state, node, r, c);
        if (canPlace) {
          return (r, c);
        }
      }
    }
    return (-1, -1);
  }

  /// Helper to check placement and count overlaps
  (bool, int) _checkPlacement(
    GridState state,
    WordNode node,
    int row,
    int col,
  ) {
    int overlaps = 0;
    final cellCodes = node.cellCodes;
    for (int i = 0; i < cellCodes.length; i++) {
      final existing = state.grid[row][col + i];
      if (existing == emptyCell) continue;
      if (existing != cellCodes[i]) return (false, 0);
      overlaps++;
    }
    return (true, overlaps);
  }

  /// Fill remaining cells with padding characters
  void _fillPadding(GridState state) {
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        if (state.grid[row][col] == emptyCell) {
          assert(state.usage[row][col] == 0);
          state.grid[row][col] =
              paddingCellCodes[random.nextInt(paddingCellCodes.length)];
        }
      }
    }
  }

  /// Compute topological ranks for all word instances
  static Map<WordNode, int> computeRanks(WordDependencyGraph graph) {
    final inDegree = <WordNode, int>{};
    final allNodes = graph.nodes.values.expand((i) => i).toList();

    for (final node in allNodes) {
      inDegree[node] = 0;
    }

    for (final entry in graph.edges.entries) {
      for (final succ in entry.value) {
        inDegree[succ] = (inDegree[succ] ?? 0) + 1;
      }
    }

    final ranks = <WordNode, int>{};
    var queue = inDegree.entries
        .where((e) => e.value == 0)
        .map((e) => e.key)
        .toList();

    queue.sort((a, b) => a.id.compareTo(b.id));

    int currentRank = 0;
    while (queue.isNotEmpty) {
      final nextQueue = <WordNode>[];
      for (final node in queue) {
        ranks[node] = currentRank;
        for (final succ in graph.edges[node] ?? {}) {
          inDegree[succ] = inDegree[succ]! - 1;
          if (inDegree[succ] == 0) nextQueue.add(succ);
        }
      }
      queue = nextQueue;
      queue.sort((a, b) => a.id.compareTo(b.id));
      currentRank++;
    }

    for (final node in allNodes) {
      if (!ranks.containsKey(node)) ranks[node] = currentRank;
    }
    return ranks;
  }
}
