import 'dart:math';
import 'package:wordclock/generator/backtracking/grid_state.dart';
import 'package:wordclock/generator/backtracking/graph/dependency_graph.dart';
import 'package:wordclock/generator/backtracking/graph/graph_builder.dart';
import 'package:wordclock/generator/backtracking/graph/word_node.dart';
import 'package:wordclock/generator/utils/grid_build_result.dart';
import 'package:wordclock/generator/utils/grid_validator.dart';
import 'package:wordclock/languages/language.dart';
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

  /// Padding alphabet cells
  final List<String> paddingCells;

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
    // 1. Build word dependency graph
    graph = WordDependencyGraphBuilder.build(language: language);

    // 2. Get topological ranks
    final nodeRanks = computeRanks(graph);

    // 3. Initialize search
    final state = GridState(width: width, height: height);
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
      rankList.sort((a, b) => b.cells.length.compareTo(a.cells.length));
    }

    // 4. Recursive Solve
    _solve(state, ranks, 0, ranks[0]);

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

  /// The main recursive solve function
  void _solve(
    GridState state,
    List<List<WordNode>> rankNodes,
    int rankIndex,
    List<WordNode> currentRankRemaining,
  ) {
    _iterationCount++;
    final placedWords = state.nodePlacements.length;

    final now = DateTime.now();

    // Periodically report progress
    _reportProgress(now, state);

    if (_shouldStop) return;

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
    if (currentRankRemaining.isEmpty) {
      final nextRankIndex = rankIndex + 1;
      _solve(
        state,
        rankNodes,
        nextRankIndex,
        nextRankIndex < rankNodes.length ? rankNodes[nextRankIndex] : [],
      );
      return;
    }

    // Try EVERY word in this rank as the next one to place (Combinatorial)
    for (int i = 0; i < currentRankRemaining.length; i++) {
      final node = currentRankRemaining[i];

      // Find EARLIEST valid placement for this word
      final (r, c) = findEarliestPlacementByPhrase(state, node);
      //final (r, c) = findEarliestPlacement(state, node);

      if (r != -1) {
        final p = state.placeWord(node, r, c);
        if (p != null) {
          final nextRemaining = List<WordNode>.from(currentRankRemaining)
            ..removeAt(i);
          _solve(state, rankNodes, rankIndex, nextRemaining);
          state.removePlacement(p);
        }
      }

      if (_shouldStop) return;
    }
  }

  /// Finds the earliest valid placement for a word, respecting parents and reading order.
  /// This uses the pre-computed graph edges (parent nodes).
  ///
  /// Made public for testing comparison with [findEarliestPlacementByPhrase].
  (int row, int col) findEarliestPlacement(GridState state, WordNode node) {
    int minRow = 0;
    int minCol = 0;

    // 1. Respect parents
    final parents = graph.inEdges[node] ?? {};
    for (final parentNode in parents) {
      final p = state.nodePlacements[parentNode];
      if (p == null) continue;

      if (p.row > minRow) {
        minRow = p.row;
        minCol = p.endCol + (language.requiresPadding ? 2 : 1);
      } else if (p.row == minRow) {
        minCol = max(minCol, p.endCol + (language.requiresPadding ? 2 : 1));
      }
    }

    if (minCol >= width) {
      minRow++;
      minCol = 0;
    }

    // 3. Find the very first valid cell
    for (int r = minRow; r < _minHeightFound; r++) {
      int cStart = (r == minRow) ? minCol : 0;
      for (int c = cStart; c <= width - node.cells.length; c++) {
        final (canPlace, _) = _checkPlacement(state, node, r, c);
        if (canPlace) {
          return (r, c);
        }
      }
    }

    return (-1, -1);
  }

  /// Finds the earliest valid placement for a word by scanning phrases left-to-right.
  ///
  /// This method uses the pre-computed predecessor tokens for each phrase and scans
  /// the grid to find placements for each predecessor word in reading order. The earliest
  /// valid position is after the MAX end position across all phrases.
  ///
  /// This differs from [findEarliestPlacement] which uses the pre-computed graph edges.
  /// The phrase-based approach correctly handles cases where duplicate words may
  /// already be satisfied by earlier placements.
  ///
  /// Returns (-1, -1) if a required predecessor word is not found on the grid.
  (int row, int col) findEarliestPlacementByPhrase(
    GridState state,
    WordNode node,
  ) {
    int maxEndRow = -1;
    int maxEndCol = -1;

    // Process each phrase's pre-computed predecessor tokens
    for (final predecessors in node.predecessorTokens) {
      // If no predecessors, this is the first word - no constraint from this phrase
      if (predecessors.isEmpty) continue;

      // Scan the grid left-to-right for each predecessor token
      final (endRow, endCol) = _scanPhraseForPredecessors(state, predecessors);

      // If any predecessor wasn't found, this phrase can't be satisfied
      if (endRow == -1) {
        return (-1, -1);
      }

      // Update max end position (in reading order)
      if (endRow > maxEndRow || (endRow == maxEndRow && endCol > maxEndCol)) {
        maxEndRow = endRow;
        maxEndCol = endCol;
      }
    }

    int minRow;
    int minCol;

    // If no phrases had predecessors, we can start at (0, 0)
    if (maxEndRow == -1) {
      minRow = 0;
      minCol = 0;
    } else {
      // Calculate the minimum starting position after the max end position
      minRow = maxEndRow;
      minCol = maxEndCol + (language.requiresPadding ? 2 : 1);

      if (minCol >= width) {
        minRow++;
        minCol = 0;
      }
    }

    // Find the first valid cell starting from minRow, minCol
    for (int r = minRow; r < _minHeightFound; r++) {
      int cStart = (r == minRow) ? minCol : 0;
      for (int c = cStart; c <= width - node.cells.length; c++) {
        final (canPlace, _) = _checkPlacement(state, node, r, c);
        if (canPlace) {
          return (r, c);
        }
      }
    }

    return (-1, -1);
  }

  /// Scans the grid left-to-right to find placements for a sequence of tokens.
  ///
  /// Each subsequent token must be found AFTER the previous one in reading order.
  /// Returns the (row, col) of the END of the last token found.
  /// Returns (-1, -1) if any token is not found.
  (int row, int col) _scanPhraseForPredecessors(
    GridState state,
    List<String> tokens,
  ) {
    int currentRow = 0;
    int currentCol = 0;

    for (final token in tokens) {
      // Find the first placement of this token that starts at or after (currentRow, currentCol)
      final placement = _findWordAfterPosition(
        state,
        token,
        currentRow,
        currentCol,
      );

      if (placement == null) {
        return (-1, -1);
      }

      // Move current position to just after this word
      currentRow = placement.row;
      currentCol = placement.endCol + 1;
    }

    // Return the end position of the last token
    // currentCol is already endCol + 1, so we need to subtract 1
    return (currentRow, currentCol - 1);
  }

  /// Finds the first placement of a word that starts at or after the given position.
  ///
  /// Scans all placements of the word and returns the one that comes first
  /// in reading order but is at or after (afterRow, afterCol).
  WordPlacement? _findWordAfterPosition(
    GridState state,
    String word,
    int afterRow,
    int afterCol,
  ) {
    final placements = state.getPlacementsOf(word);
    if (placements.isEmpty) return null;

    WordPlacement? best;

    for (final p in placements) {
      // Check if this placement starts at or after the required position
      final startsAfter =
          p.row > afterRow || (p.row == afterRow && p.startCol >= afterCol);

      if (!startsAfter) continue;

      // Check if this is the earliest valid placement found so far
      if (best == null) {
        best = p;
      } else {
        final isBetter =
            p.row < best.row ||
            (p.row == best.row && p.startCol < best.startCol);
        if (isBetter) {
          best = p;
        }
      }
    }

    return best;
  }

  /// Helper to check placement and count overlaps
  (bool, int) _checkPlacement(
    GridState state,
    WordNode node,
    int row,
    int col,
  ) {
    int overlaps = 0;
    for (int i = 0; i < node.cells.length; i++) {
      final existing = state.grid[row][col + i];
      if (existing == null) continue;
      if (existing != node.cells[i]) return (false, 0);
      overlaps++;
    }
    return (true, overlaps);
  }

  /// Fill remaining cells with padding characters
  void _fillPadding(GridState state) {
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        if (state.grid[row][col] == null) {
          assert(state.usage[row][col] == 0);
          state.grid[row][col] =
              paddingCells[random.nextInt(paddingCells.length)];
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
