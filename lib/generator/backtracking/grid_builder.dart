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

  /// Padding alphabet cells
  final List<Cell> paddingCells;

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
    final remainingLength = currentRankRemaining.length;
    for (int i = 0; i < remainingLength; i++) {
      final node = currentRankRemaining[i];

      // Find EARLIEST valid placement for this word
      final (r, c) = findEarliestPlacementByPhrase(state, node);
      //final (r, c) = findEarliestPlacement(state, node);

      if (r != -1) {
        final p = state.placeWord(node, r, c);
        if (p != null) {
          // Update trie cache: set position on all trie nodes this word owns
          for (final trieNode in node.ownedTrieNodes) {
            trieNode.cachedPosition = (p.row, p.endCol);
          }

          // Build next remaining list excluding element i
          // TODO Can this be replaced by a bitset, instead of maintaining a list?
          final nextRemaining = <WordNode>[];
          for (int j = 0; j < remainingLength; j++) {
            if (j != i) nextRemaining.add(currentRankRemaining[j]);
          }
          _solve(state, rankNodes, rankIndex, nextRemaining);

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

  /// Non-cached trie-based version (falls back when cache not available).
  (int, int) _findEarliestPlacementByTrie(GridState state, WordNode node) {
    // If this word can be first in any phrase, it can start at (0, 0)
    if (node.hasEmptyPredecessor) {
      return _findFirstValidPlacement(state, node, 0, 0);
    }

    // Use trie-based scanning if available
    final trie = node.predecessorTrie;
    if (trie == null) {
      return (-1, -1); // No valid predecessor sequences
    }

    // Scan using trie to find the max end position across all valid paths
    final (maxEndRow, maxEndCol) = _scanTrieForMaxEndPosition(state, trie);

    if (maxEndRow == -1) {
      return (-1, -1);
    }

    // Calculate the minimum starting position after the max end position
    int minRow = maxEndRow;
    int minCol = maxEndCol + (language.requiresPadding ? 2 : 1);

    if (minCol >= width) {
      minRow++;
      minCol = 0;
    }

    return _findFirstValidPlacement(state, node, minRow, minCol);
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
      for (int c = cStart; c <= width - node.cells.length; c++) {
        final (canPlace, _) = _checkPlacement(state, node, r, c);
        if (canPlace) {
          return (r, c);
        }
      }
    }
    return (-1, -1);
  }

  // ============================================================
  // Trie-based scanning (non-cached version)
  // ============================================================

  /// Scans trie to find max end position across all valid paths.
  /// Returns (-1, -1) if no complete path is found.
  (int, int) _scanTrieForMaxEndPosition(GridState state, PredecessorTrie trie) {
    int maxRow = -1, maxCol = -1;
    bool found = false;

    for (final entry in trie.roots.entries) {
      final node = entry.value;
      final pos = _findWordCellsAfterPosition(state, node.wordCells, 0, 0);
      if (pos == null) continue;

      final result = _scanTrieNodeDFS(state, node, pos.$1, pos.$2);
      if (result != null) {
        found = true;
        if (_isAfter(result, (maxRow, maxCol))) {
          (maxRow, maxCol) = result;
        }
      }
    }
    return found ? (maxRow, maxCol) : (-1, -1);
  }

  /// DFS through trie node, returns max end position of any complete path.
  (int, int)? _scanTrieNodeDFS(
    GridState state,
    PredecessorTrieNode node,
    int row,
    int endCol,
  ) {
    int maxRow = -1, maxCol = -1;
    bool found = node.isTerminal;
    if (found) (maxRow, maxCol) = (row, endCol);

    for (final child in node.children.values) {
      final pos = _findWordCellsAfterPosition(
        state,
        child.wordCells,
        row,
        endCol + 1,
      );
      if (pos == null) continue;

      final result = _scanTrieNodeDFS(state, child, pos.$1, pos.$2);
      if (result != null) {
        found = true;
        if (_isAfter(result, (maxRow, maxCol))) {
          (maxRow, maxCol) = result;
        }
      }
    }
    return found ? (maxRow, maxCol) : null;
  }

  // ============================================================
  // Trie-based scanning (cached version)
  // ============================================================

  /// Scans trie with per-call cache to avoid redundant word lookups.
  (int, int) _scanTrieForMaxEndPositionCached(
    GridState state,
    PredecessorTrie trie,
  ) {
    final cache = <(String, int, int), (int, int)?>{};
    int maxRow = -1, maxCol = -1;
    bool found = false;

    for (final entry in trie.roots.entries) {
      final node = entry.value;
      final pos = _findWordCached(state, node.wordCells, 0, 0, cache);
      if (pos == null) continue;

      final result = _scanTrieNodeDFSCached(state, node, pos.$1, pos.$2, cache);
      if (result != null) {
        found = true;
        if (_isAfter(result, (maxRow, maxCol))) {
          (maxRow, maxCol) = result;
        }
      }
    }
    return found ? (maxRow, maxCol) : (-1, -1);
  }

  /// DFS through trie with cache.
  (int, int)? _scanTrieNodeDFSCached(
    GridState state,
    PredecessorTrieNode node,
    int row,
    int endCol,
    Map<(String, int, int), (int, int)?> cache,
  ) {
    int maxRow = -1, maxCol = -1;
    bool found = node.isTerminal;
    if (found) (maxRow, maxCol) = (row, endCol);

    for (final entry in node.children.entries) {
      final child = entry.value;
      final pos = _findWordCached(
        state,
        child.wordCells,
        row,
        endCol + 1,
        cache,
      );
      if (pos == null) continue;

      final result = _scanTrieNodeDFSCached(
        state,
        child,
        pos.$1,
        pos.$2,
        cache,
      );
      if (result != null) {
        found = true;
        if (_isAfter(result, (maxRow, maxCol))) {
          (maxRow, maxCol) = result;
        }
      }
    }
    return found ? (maxRow, maxCol) : null;
  }

  /// Cached word lookup helper.
  (int, int)? _findWordCached(
    GridState state,
    Word wordCells,
    int afterRow,
    int afterCol,
    Map<(String, int, int), (int, int)?> cache,
  ) {
    final key = (wordCells.join(), afterRow, afterCol);
    if (cache.containsKey(key)) return cache[key];
    final result = _findWordCellsAfterPosition(
      state,
      wordCells,
      afterRow,
      afterCol,
    );
    cache[key] = result;
    return result;
  }

  /// Returns true if pos1 is after pos2 in reading order.
  bool _isAfter((int, int) pos1, (int, int) pos2) {
    return pos1.$1 > pos2.$1 || (pos1.$1 == pos2.$1 && pos1.$2 > pos2.$2);
  }

  // ============================================================
  // Grid scanning helpers
  // ============================================================

  /// Scans the grid left-to-right to find placements for a sequence of predecessor cells.
  ///
  /// Each subsequent word must be found AFTER the previous one in reading order.
  /// Returns the (row, col) of the END of the last word found.
  /// Returns (-1, -1) if any word is not found.
  (int row, int col) _scanPhraseForPredecessorCells(
    GridState state,
    Phrase predecessorCells,
  ) {
    int currentRow = 0;
    int currentCol = 0;

    for (final wordCells in predecessorCells) {
      // Find the first occurrence of this word that starts at or after (currentRow, currentCol)
      final result = _findWordCellsAfterPosition(
        state,
        wordCells,
        currentRow,
        currentCol,
      );

      if (result == null) {
        return (-1, -1);
      }

      // Move current position to just after this word
      currentRow = result.$1;
      currentCol = result.$2 + 1;
    }

    // Return the end position of the last word
    // currentCol is already endCol + 1, so we need to subtract 1
    return (currentRow, currentCol - 1);
  }

  /// Finds the first occurrence of word cells in the grid starting at or after the given position.
  ///
  /// Scans the grid in reading order (left-to-right, top-to-bottom).
  /// Returns null if the word is not found.
  (int row, int endCol)? _findWordCellsAfterPosition(
    GridState state,
    Word wordCells,
    int afterRow,
    int afterCol,
  ) {
    final cells = state.grid;
    final wordLen = wordCells.length;

    for (int r = afterRow; r < height; r++) {
      final startCol = (r == afterRow) ? afterCol : 0;
      final maxCol = width - wordLen;

      for (int c = startCol; c <= maxCol; c++) {
        if (_matchesAt(cells, wordCells, r, c)) {
          return (r, c + wordLen - 1);
        }
      }
    }
    return null;
  }

  /// Check if wordCells matches the grid at (row, col).
  bool _matchesAt(List<List<String?>> cells, Word wordCells, int row, int col) {
    for (int i = 0; i < wordCells.length; i++) {
      if (cells[row][col + i] != wordCells[i]) return false;
    }
    return true;
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
