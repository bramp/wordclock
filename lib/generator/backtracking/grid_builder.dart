import 'dart:math';
import 'package:wordclock/generator/backtracking/grid_state.dart';
import 'package:wordclock/generator/backtracking/graph/dependency_graph.dart';
import 'package:wordclock/generator/backtracking/graph/graph_builder.dart';
import 'package:wordclock/generator/backtracking/graph/word_node.dart';
import 'package:wordclock/generator/utils/grid_build_result.dart';
import 'package:wordclock/generator/utils/grid_validator.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';

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

  /// Configuration
  final int maxSearchTimeSeconds;

  /// Internal state for the best grid found
  GridState? _bestState;
  int _minHeightFound = 1000;
  int _maxWordsPlaced = -1;
  late DateTime _deadline;
  DateTime _lastProgressPrint = DateTime.now();

  BacktrackingGridBuilder({
    required this.width,
    required this.height,
    required this.language,
    required int seed,
    this.maxSearchTimeSeconds = 30,
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
    _bestState = null;
    _deadline = DateTime.now().add(Duration(seconds: maxSearchTimeSeconds));
    _lastProgressPrint = DateTime.now();

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

    if (finalState != null) {
      placedWords = finalState.nodePlacements.length;
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
      totalWords: graph.nodes.values.expand((instances) => instances).length,
      placedWords: placedWords,
    );
  }

  void _printProgress(DateTime now, GridState state, int totalWords) {
    if (now.difference(_lastProgressPrint).inSeconds < 1) return;

    _lastProgressPrint = now;
    final progressGrid = state.clone();
    print(
      '\n--- Current Search: ${state.nodePlacements.length}/$totalWords words (Best: $_maxWordsPlaced) ---',
    );
    print(progressGrid.toGridString());
  }

  /// The main recursive solve function
  void _solve(
    GridState state,
    List<List<WordNode>> rankNodes,
    int rankIndex,
    List<WordNode> currentRankRemaining,
  ) {
    final placedWords = state.nodePlacements.length;
    final totalWords =
        graph.nodes.values.expand((instances) => instances).length;

    final now = DateTime.now();

    // Periodically print progress
    _printProgress(now, state, totalWords);

    if (now.isAfter(_deadline)) return;

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
      final (r, c) = _findEarliestPlacement(state, node);

      if (r != -1) {
        final p = state.placeWord(node, r, c);
        if (p != null) {
          final nextRemaining = List<WordNode>.from(currentRankRemaining)
            ..removeAt(i);
          _solve(state, rankNodes, rankIndex, nextRemaining);
          state.removePlacement(p);
        }
      }

      if (DateTime.now().isAfter(_deadline)) return;
    }
  }

  /// Finds the earliest valid placement for a word, respecting parents and reading order.
  (int row, int col) _findEarliestPlacement(
    GridState state,
    WordNode node,
  ) {
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

  /// Helper to check placement and count overlaps
  (bool, int) _checkPlacement(GridState state, WordNode node, int row, int col) {
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
