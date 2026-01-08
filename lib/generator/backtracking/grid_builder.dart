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

    // 2. Get topological ranks
    final nodeRanks = computeRanks(graph);

    // 3. Initialize search
    final state = GridState(width: width, height: height, codec: codec);
    _minHeightFound = height; // Initial target height
    _maxWordsPlaced = -1;
    _totalWords = graph.nodes.values.expand((instances) => instances).length;
    _bestState = null;
    _stopRequested = false;
    _lastProgressReport = DateTime.now();
    _iterationCount = 0;
    _startTime = DateTime.now();
    _stopReason = StopReason.completed;

    // Group nodes by rank
    final maxRank = nodeRanks.isEmpty ? 0 : nodeRanks.values.reduce(max);
    final List<List<WordNode>> ranks = List.generate(maxRank + 1, (_) => []);
    for (final entry in nodeRanks.entries) {
      ranks[entry.value].add(entry.key);
    }

    // Sort words within each rank by length (longest first)
    for (final rankList in ranks) {
      rankList.sort((a, b) => b.cellCodes.length.compareTo(a.cellCodes.length));

      // Bitmask uses 64-bit int, so max 63 words per rank (bits 0-62)
      assert(rankList.length <= 63, 'Rank has ${rankList.length} words, max 63');
    }

    // 4. Recursive Solve
    // Use bitmask where bit i means rankNodes[rankIndex][i] is remaining
    final initialMask = ranks[0].isEmpty ? 0 : (1 << ranks[0].length) - 1;
    _solve(state, ranks, 0, initialMask);

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

  /// The main recursive solve function.
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
  /// Each terminal node represents the end of a predecessor sequence. We walk up
  /// the parent chain checking that all nodes have cachedPosition set (meaning
  /// all predecessor words are placed). Returns the max terminal position.
  (int, int)? _findMaxPredecessorPositionUsingIndex(
    GridState state,
    List<PhraseTrieNode> terminalNodes,
  ) {
    int maxRow = -1;
    int maxCol = -1;
    bool anyFound = false;

    // For each terminal node (end of a predecessor sequence),
    // check if the full path has cached positions
    for (final terminal in terminalNodes) {
      final endPos = _getPathEndPositionFromCache(terminal);
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

  /// Get the end position of a predecessor path by reading cached positions.
  /// Returns null if any node in the path doesn't have a cached position.
  (int, int)? _getPathEndPositionFromCache(PhraseTrieNode terminal) {
    // Walk from terminal up to root, checking all have cached positions
    PhraseTrieNode? current = terminal;
    while (current != null) {
      if (current.cachedPosition == null) return null;
      current = current.parent;
    }
    // All nodes have positions, return the terminal's position
    return terminal.cachedPosition;
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
