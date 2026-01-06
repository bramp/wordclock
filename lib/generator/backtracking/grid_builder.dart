import 'dart:math';
import 'package:wordclock/generator/backtracking/grid_state.dart';
import 'package:wordclock/generator/backtracking/graph/dependency_graph.dart';
import 'package:wordclock/generator/backtracking/graph/graph_builder.dart';
import 'package:wordclock/generator/backtracking/graph/word_node.dart';
import 'package:wordclock/generator/utils/grid_build_result.dart';
import 'package:wordclock/generator/utils/grid_validator.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';

/// A candidate position for placing a word
class _Candidate {
  final int row;
  final int col;
  final double score;
  final List<int> overlappedIndices;

  _Candidate(this.row, this.col, this.score, this.overlappedIndices);

  @override
  String toString() =>
      '_Candidate(row=$row, col=$col, score=${score.toStringAsFixed(2)}, overlaps=${overlappedIndices.length})';
}

/// A backtracking-based grid builder that finds optimal word placements.
///
/// This builder:
/// 1. Builds a word-level dependency graph
/// 2. Uses backtracking to explore placement possibilities
/// 3. Maximizes word overlap and compactness
/// 4. Prunes suboptimal search paths
class BacktrackingGridBuilder {
  final int width;
  final int height;
  final WordClockLanguage language;
  final Random random;

  /// The word dependency graph
  late final WordDependencyGraph graph;

  /// Words sorted by priority
  late final List<String> wordOrder;

  /// Padding alphabet cells
  final List<String> paddingCells;

  /// Configuration
  final int maxSearchTimeSeconds;
  final int maxNodesExplored;
  final double minCompactnessThreshold;

  BacktrackingGridBuilder({
    required this.width,
    required this.height,
    required this.language,
    required int seed,
    this.maxSearchTimeSeconds = 30,
    this.maxNodesExplored = 100000,
    this.minCompactnessThreshold = 0.1,
  }) : random = Random(seed),
       paddingCells = WordGrid.splitIntoCells(language.paddingAlphabet);

  /// Attempts to build a grid that satisfies all constraints.
  ///
  /// Returns a GridBuildResult with the grid and validation information.
  GridBuildResult build() {
    // 1. Build word dependency graph
    graph = WordDependencyGraphBuilder.build(language: language);

    // 2. Get topological ranks for word instances (Node IDs)
    final nodeRanks = computeRanks(graph);

    // Create faster lookup map for helpers (ID -> Rank)
    final ranks = <String, int>{};
    for (final entry in nodeRanks.entries) {
      ranks[entry.key.id] = entry.value;
    }

    // 3. Initialize empty grid state
    final state = GridState(width: width, height: height);

    // 4. Create placement tasks from ranks
    int placedWords = 0;
    final placementTasks = _createPlacementTasks(nodeRanks);

    // 5. Recursive Solve
    final startTime = DateTime.now();
    final success = _solveRecursively(
      state,
      placementTasks,
      0,
      ranks,
      startTime,
    );

    if (success) {
      placedWords = placementTasks.length;
      _fillPadding(state);
    } else {
      print('Backtracking failed to find a valid grid solution.');
    }

    // 6. Validate
    final gridCells = state.toFlatList();
    final gridToValidate = WordGrid(width: width, cells: gridCells);
    final validationIssues = GridValidator.validate(gridToValidate, language);

    return GridBuildResult(
      grid: gridCells,
      validationIssues: validationIssues,
      totalWords: graph.nodes.length,
      placedWords: placedWords,
    );
  }

  /// Compute topological ranks for all word instances (Node IDs)
  static Map<WordNode, int> computeRanks(WordDependencyGraph graph) {
    // 1. Initialize in-degrees for all nodes
    final inDegree = <WordNode, int>{};
    for (final nodeList in graph.nodes.values) {
      for (final node in nodeList) {
        inDegree[node] = 0;
      }
    }

    // 2. Compute in-degrees based on edges
    for (final entry in graph.edges.entries) {
      final successors = entry.value;
      for (final succ in successors) {
        inDegree[succ] = (inDegree[succ] ?? 0) + 1;
      }
    }

    final ranks = <WordNode, int>{};

    // 3. Kahn's Algorithm
    // Initial queue: nodes with in-degree 0
    var queue = inDegree.entries
        .where((e) => e.value == 0)
        .map((e) => e.key)
        .toList();

    // Sort by ID to ensure deterministic behavior
    queue.sort((a, b) => a.id.compareTo(b.id));

    int currentRank = 0;

    while (queue.isNotEmpty) {
      final nextQueue = <WordNode>[];

      for (final node in queue) {
        ranks[node] = currentRank;

        // Find successors
        final successors = graph.edges[node] ?? {};
        for (final succ in successors) {
          inDegree[succ] = inDegree[succ]! - 1;
          if (inDegree[succ] == 0) {
            nextQueue.add(succ);
          }
        }
      }

      queue = nextQueue;
      queue.sort((a, b) => a.id.compareTo(b.id));
      currentRank++;
    }

    // 4. Handle cycles (assign remaining nodes the next rank)
    for (final nodeList in graph.nodes.values) {
      for (final node in nodeList) {
        if (!ranks.containsKey(node)) {
          ranks[node] = currentRank;
        }
      }
    }

    return ranks;
  }

  /// Creates a list of placement tasks sorted by rank and then by word length.
  List<_PlacementTask> _createPlacementTasks(Map<WordNode, int> nodeRanks) {
    final tasks = nodeRanks.entries
        .map((e) => _PlacementTask(e.key, e.value))
        .toList();

    tasks.sort((a, b) {
      if (a.rank != b.rank) {
        return a.rank.compareTo(b.rank);
      }
      return b.node.word.length.compareTo(a.node.word.length);
    });

    return tasks;
  }



  List<_Candidate> _findPlacementCandidates(
    GridState state,
    WordNode node,
    int rank,
    Map<String, int> ranks,
  ) {
    final candidates = <_Candidate>[];

    // Special case: first word
    if (state.nodePlacements.isEmpty) {
      candidates.add(_Candidate(0, 0, 1000.0, []));
      return candidates;
    }

    // Find the latest parent position to constrain the search
    int startRow = 0;
    int startCol = 0;

    final parents = graph.inEdges[node] ?? {};
    for (final parentNode in parents) {
      final p = state.nodePlacements[parentNode];
      if (p == null) return []; // Parent not placed yet

      if (p.row > startRow) {
        startRow = p.row;
        startCol = p.endCol + 1; // TODO This may be tweak to handle padding
      } else if (p.row == startRow) {
        startCol = max(startCol, p.endCol + 1);
      }
    }

    for (int row = startRow; row < height; row++) {
      final colStart = (row == startRow) ? startCol : 0;
      for (int col = colStart; col <= width - node.cells.length; col++) {
        // Basic fit check
        final (canPlace, overlappedIndices) = state.canPlaceWord(
          node.cells,
          row,
          col,
        );
        if (!canPlace) continue;

        // Check separation
        if (!_hasProperSeparation(state, row, col, node.cells.length)) {
          continue;
        }

        final score = _scorePosition(
          state,
          node,
          row,
          col,
          ranks,
          overlappedIndices,
        );
        candidates.add(_Candidate(row, col, score, overlappedIndices));
      }
    }
    candidates.sort((a, b) => b.score.compareTo(a.score));
    return candidates;
  }

  /// Check if a position has proper separation from adjacent words
  bool _hasProperSeparation(GridState state, int row, int col, int wordLength) {
    final endCol = col + wordLength - 1;

    // Check all existing placements
    for (final other in state.nodePlacements.values) {
      // Check if on same row or adjacent rows
      if ((other.row - row).abs() <= 1) {
        // Check horizontal separation on same row
        if (other.row == row) {
          // Check if words are adjacent
          if ((other.endCol == col - 1) || (endCol == other.startCol - 1)) {
            // Words are adjacent - need padding if language requires it
            if (language.requiresPadding) {
              return false; // Reject - no padding between words
            }
          }
          // Check if words overlap in a way that creates no separation
          if ((col >= other.startCol && col <= other.endCol) ||
              (endCol >= other.startCol && endCol <= other.endCol) ||
              (col <= other.startCol && endCol >= other.endCol)) {
            // Some overlap - this is checked by canPlaceWord, so if we're here it's OK
            continue;
          }
        }
      }
    }
    return true;
  }

  double _scorePosition(
    GridState state,
    WordNode node,
    int row,
    int col,
    Map<String, int> ranks,
    List<int> overlappedIndices,
  ) {
    double score = 0.0;
    score += overlappedIndices.length * 100.0;

    final currentRank = ranks[node.id] ?? 0;
    final parents = _getParentWords(node, currentRank, ranks);

    for (final parent in parents) {
      final parentPlacement = state.nodePlacements[parent];
      if (parentPlacement != null) {
        if (parentPlacement.row == row) {
          final expectedCol =
              parentPlacement.endCol + (language.requiresPadding ? 2 : 1);
          if (col == expectedCol) {
            score += 10000.0;
          } else if (col > expectedCol) {
            score += 5000.0 - (col - expectedCol) * 10.0;
          }
        }
      }
    }

    score -= state.distanceToNearestWord(row, col) * 5.0;
    score -= (row + col) * 1.0;
    score -= col * 0.5;
    return score;
  }

  bool _solveRecursively(
    GridState state,
    List<_PlacementTask> tasks,
    int taskIndex,
    Map<String, int> ranks,
    DateTime startTime,
  ) {
    if (taskIndex >= tasks.length) return true;
    if (DateTime.now().difference(startTime).inSeconds > maxSearchTimeSeconds) {
      return false;
    }

    final task = tasks[taskIndex];
    final candidates = _findPlacementCandidates(
      state,
      task.node,
      task.rank,
      ranks,
    );

    final maxCandidates = 50;
    final count = min(candidates.length, maxCandidates);

    for (int i = 0; i < count; i++) {
      final c = candidates[i];
      final p = state.placeWord(task.node, c.row, c.col);
      if (p != null) {
        if (_solveRecursively(state, tasks, taskIndex + 1, ranks, startTime)) {
          return true;
        }
        state.removePlacement(p);
      }
    }
    return false;
  }

  List<WordNode> _getParentWords(
    WordNode node,
    int currentRank,
    Map<String, int> ranks,
  ) {
    final parents = <WordNode>[];
    final potentialParents = graph.inEdges[node] ?? {};
    for (final fromNode in potentialParents) {
      // Rank check
      if (ranks.containsKey(fromNode.id) &&
          ranks[fromNode.id]! < currentRank) {
        parents.add(fromNode);
      }
    }
    return parents;
  }

  /// Fill remaining cells with padding characters
  void _fillPadding(GridState state) {
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        if (state.grid[row][col] == null) {
          state.grid[row][col] =
              paddingCells[random.nextInt(paddingCells.length)];
        }
      }
    }
  }
}

class _PlacementTask {
  final WordNode node;
  final int rank;

  _PlacementTask(this.node, this.rank);
}
