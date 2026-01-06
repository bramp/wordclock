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

    final maxRank = nodeRanks.isEmpty
        ? 0
        : nodeRanks.values.reduce((a, b) => a > b ? a : b);

    // 3. Initialize empty grid state
    final state = GridState(width: width, height: height);

    // 4. Place words rank by rank
    int placedWords = 0;

    // Convert ranks to tasks
    final placementTasks = <_PlacementTask>[];

    for (int rank = 0; rank <= maxRank; rank++) {
      final nodesAtRank = nodeRanks.entries
          .where((e) => e.value == rank)
          .map((e) => e.key)
          .toList();

      if (nodesAtRank.isEmpty) continue;

      // Sort by word length
      nodesAtRank.sort((a, b) => b.word.length.compareTo(a.word.length));

      for (final node in nodesAtRank) {
        placementTasks.add(
          _PlacementTask(node.word, node.instance, node.cells, rank),
        );
      }
    }

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

  /// Place a single word instance in the grid
  bool _respectsParents(
    GridState state,
    String word,
    int instanceIndex,
    int row,
    int col,
    Map<String, int> ranks,
  ) {
    // Find parents in the graph
    // Since edges are Map<WordNode, Set<WordNode>>, we need to iterate
    final parents = <WordNode>[];
    for (final entry in graph.edges.entries) {
      final successors = entry.value;
      for (final succ in successors) {
        if (succ.word == word && succ.instance == instanceIndex) {
          parents.add(entry.key);
        }
      }
    }

    for (final parentNode in parents) {
      final parentPlacements = state.wordPlacements[parentNode.word];
      if (parentPlacements == null) return false;

      bool found = false;
      bool before = false;
      for (final p in parentPlacements) {
        if (p.instanceIndex == parentNode.instance) {
          found = true;
          if (p.row < row || (p.row == row && p.endCol < col)) {
            before = true;
          }
          break;
        }
      }
      if (!found || !before) return false;
    }
    return true;
  }

  List<_Candidate> _findPlacementCandidates(
    GridState state,
    String word,
    List<String> cells,
    int instanceIndex,
    int rank,
    Map<String, int> ranks,
  ) {
    final candidates = <_Candidate>[];

    // Special case: first word
    if (state.wordPlacements.isEmpty) {
      candidates.add(_Candidate(0, 0, 1000.0, []));
      return candidates;
    }

    for (int row = 0; row < height; row++) {
      for (int col = 0; col <= width - cells.length; col++) {
        // Basic fit check
        final (canPlace, overlappedIndices) = state.canPlaceWord(
          word,
          cells,
          row,
          col,
        );
        if (!canPlace) continue;

        // Check dependencies
        if (_respectsParents(state, word, instanceIndex, row, col, ranks)) {
          // Check separation
          if (!_hasProperSeparation(state, row, col, cells.length)) continue;

          final score = _scorePosition(
            state,
            word,
            instanceIndex,
            row,
            col,
            ranks,
            overlappedIndices,
          );
          candidates.add(_Candidate(row, col, score, overlappedIndices));
        }
      }
    }
    candidates.sort((a, b) => b.score.compareTo(a.score));
    return candidates;
  }

  /// Check if a position has proper separation from adjacent words
  bool _hasProperSeparation(GridState state, int row, int col, int wordLength) {
    final endCol = col + wordLength - 1;

    // Check all existing placements
    for (final placements in state.wordPlacements.values) {
      for (final other in placements) {
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
    }
    return true;
  }

  double _scorePosition(
    GridState state,
    String word,
    int instanceIndex,
    int row,
    int col,
    Map<String, int> ranks,
    List<int> overlappedIndices,
  ) {
    double score = 0.0;
    score += overlappedIndices.length * 100.0;

    final nodeId = instanceIndex == 0 ? word : '$word#$instanceIndex';
    final currentRank = ranks[nodeId] ?? 0;
    final parents = _getParentWords(word, currentRank, ranks);

    for (final parent in parents) {
      final parentPlacements = state.wordPlacements[parent];
      if (parentPlacements != null) {
        for (final pp in parentPlacements) {
          if (pp.row == row) {
            final expectedCol = pp.endCol + (language.requiresPadding ? 2 : 1);
            if (col == expectedCol) {
              score += 10000.0;
            } else if (col > expectedCol) {
              score += 5000.0 - (col - expectedCol) * 10.0;
            }
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
      task.word,
      task.cells,
      task.instanceIndex,
      task.rank,
      ranks,
    );

    final maxCandidates = 50;
    final count = min(candidates.length, maxCandidates);

    for (int i = 0; i < count; i++) {
      final c = candidates[i];
      final p = state.placeWord(
        task.word,
        task.cells,
        c.row,
        c.col,
        instanceIndex: task.instanceIndex,
      );
      if (p != null) {
        if (_solveRecursively(state, tasks, taskIndex + 1, ranks, startTime)) {
          return true;
        }
        state.removePlacement(p);
      }
    }
    return false;
  }

  List<String> _getParentWords(
    String word,
    int currentRank,
    Map<String, int> ranks,
  ) {
    final parents = <String>[];
    for (final entry in graph.edges.entries) {
      final fromNode = entry.key;

      final successors = entry.value;
      for (final toNode in successors) {
        // Rank check on ID
        if (toNode.word == word &&
            ranks.containsKey(fromNode.id) &&
            ranks[fromNode.id]! < currentRank) {
          parents.add(fromNode.word);
        }
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
  final String word;
  final int instanceIndex;
  final List<String> cells;
  final int rank;

  _PlacementTask(this.word, this.instanceIndex, this.cells, this.rank);
}
