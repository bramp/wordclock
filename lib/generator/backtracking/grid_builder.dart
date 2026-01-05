import 'dart:math';
import 'package:wordclock/generator/backtracking/grid_state.dart';
import 'package:wordclock/generator/backtracking/dependency_graph.dart';
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

    // 2. Get topological ranks for words
    final ranks = _computeRanks();
    final maxRank = ranks.values.reduce((a, b) => a > b ? a : b);

    // 3. Initialize empty grid state
    final state = GridState(width: width, height: height);

    // 4. Place words rank by rank
    int placedWords = 0;
    for (int rank = 0; rank <= maxRank; rank++) {
      final wordsAtRank = ranks.entries
          .where((e) => e.value == rank)
          .map((e) => e.key)
          .toList();

      if (wordsAtRank.isEmpty) continue;

      for (final word in wordsAtRank) {
        final instances = graph.nodes[word]!;
        final cells = instances[0].cells;
        final numInstances = instances.length;

        // Place each instance of this word
        bool wordPlaced = false;
        for (int i = 0; i < numInstances; i++) {
          final placed = _placeWord(state, word, cells, i, rank, ranks);
          if (placed) wordPlaced = true;
        }
        if (wordPlaced) placedWords++;
      }
    }

    // 5. Fill padding
    _fillPadding(state);

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

  /// Compute topological ranks for all words
  Map<String, int> _computeRanks() {
    final Map<String, int> ranks = {};

    // Get all word names (not node IDs)
    final allWords = graph.nodes.keys.toList();

    // Build word-level edges (collapse all instances)
    final Map<String, Set<String>> wordEdges = {};
    for (final entry in graph.edges.entries) {
      final fromId = entry.key;
      final fromWord = fromId.split('#')[0];

      for (final toId in entry.value) {
        final toWord = toId.split('#')[0];
        if (fromWord != toWord) {
          wordEdges.putIfAbsent(fromWord, () => {}).add(toWord);
        }
      }
    }

    // Assign ranks based on longest path from sources
    final inDegree = <String, int>{};
    for (final word in allWords) {
      inDegree[word] = 0;
    }
    for (final successors in wordEdges.values) {
      for (final succ in successors) {
        inDegree[succ] = (inDegree[succ] ?? 0) + 1;
      }
    }

    // Process in waves (Kahn's algorithm for topological sort)
    final queue = allWords.where((w) => inDegree[w] == 0).toList();
    int currentRank = 0;

    while (queue.isNotEmpty) {
      final nextQueue = <String>[];

      // Assign rank to all nodes in current queue
      for (final word in queue) {
        ranks[word] = currentRank;

        // Decrement in-degree of successors
        final successors = wordEdges[word] ?? {};
        for (final succ in successors) {
          inDegree[succ] = inDegree[succ]! - 1;
          if (inDegree[succ] == 0 && !ranks.containsKey(succ)) {
            nextQueue.add(succ);
          }
        }
      }

      queue.clear();
      queue.addAll(nextQueue);
      currentRank++;
    }

    // Any remaining words (in cycles) get assigned to next rank
    for (final word in allWords) {
      if (!ranks.containsKey(word)) {
        ranks[word] = currentRank;
      }
    }

    return ranks;
  }

  /// Place a single word instance in the grid
  bool _placeWord(
    GridState state,
    String word,
    List<String> cells,
    int instanceIndex,
    int currentRank,
    Map<String, int> ranks,
  ) {
    // Find best position for this word
    final candidates = _findPlacementCandidates(
      state,
      word,
      cells,
      instanceIndex,
      currentRank,
      ranks,
    );

    if (candidates.isEmpty) {
      return false;
    }

    // Try candidates in order of score
    for (final candidate in candidates) {
      final placement = state.placeWord(
        word,
        cells,
        candidate.row,
        candidate.col,
        instanceIndex: instanceIndex,
      );

      if (placement != null) {
        return true;
      }
    }

    return false;
  }

  /// Find all valid placement candidates for a word
  List<_Candidate> _findPlacementCandidates(
    GridState state,
    String word,
    List<String> cells,
    int instanceIndex,
    int currentRank,
    Map<String, int> ranks,
  ) {
    final candidates = <_Candidate>[];

    // Special case: first word - place at top-left
    if (state.wordPlacements.isEmpty) {
      candidates.add(_Candidate(0, 0, 1000.0, []));
      return candidates;
    }

    // Try all positions in the grid
    for (int row = 0; row < height; row++) {
      for (int col = 0; col <= width - cells.length; col++) {
        final (canPlace, overlappedIndices) = state.canPlaceWord(
          word,
          cells,
          row,
          col,
        );

        if (!canPlace) continue;

        // Check if this position respects parent words
        if (!_respectsParents(
          state,
          word,
          row,
          col,
          cells.length,
          currentRank,
          ranks,
        )) {
          continue;
        }

        // Check if this position has proper padding/separation from adjacent words
        if (!_hasProperSeparation(state, row, col, cells.length)) {
          continue;
        }

        final score = _scorePosition(
          state,
          row,
          col,
          overlappedIndices,
          word,
          currentRank,
          ranks,
        );
        candidates.add(_Candidate(row, col, score, overlappedIndices));
      }
    }

    // Sort by score descending (best first)
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

  /// Check if a position respects parent words (doesn't come before them)
  bool _respectsParents(
    GridState state,
    String word,
    int row,
    int col,
    int wordLength,
    int currentRank,
    Map<String, int> ranks,
  ) {
    // Get all parent words (words that must come before this one)
    final parents = <String>{};
    for (final entry in graph.edges.entries) {
      final fromId = entry.key;
      final fromWord = fromId.split('#')[0];

      for (final toId in entry.value) {
        final toWord = toId.split('#')[0];
        if (toWord == word && ranks[fromWord]! < currentRank) {
          parents.add(fromWord);
        }
      }
    }

    // For each parent, check that at least one of its placements comes before this position
    for (final parent in parents) {
      final parentPlacements = state.wordPlacements[parent];
      if (parentPlacements == null || parentPlacements.isEmpty) {
        continue; // Parent not placed yet, skip check
      }

      // Check if any parent placement comes before this position
      bool hasParentBefore = false;
      for (final parentPlacement in parentPlacements) {
        final parentEndRow = parentPlacement.row;
        final parentEndCol = parentPlacement.endCol;

        // Parent comes before if it ends before this word starts
        if (parentEndRow < row || (parentEndRow == row && parentEndCol < col)) {
          hasParentBefore = true;
          break;
        }
      }

      if (!hasParentBefore) {
        return false; // This position would violate parent constraint
      }
    }

    return true;
  }

  /// Score a position (higher is better)
  double _scorePosition(
    GridState state,
    int row,
    int col,
    List<int> overlappedIndices,
    String word,
    int currentRank,
    Map<String, int> ranks,
  ) {
    double score = 0.0;

    // Heavily reward overlap (cell reuse)
    score += overlappedIndices.length * 100.0;

    // HUGE bonus for being right after a parent word on the same row
    final parents = _getParentWords(word, currentRank, ranks);
    for (final parent in parents) {
      final parentPlacements = state.wordPlacements[parent];
      if (parentPlacements != null) {
        for (final parentPlacement in parentPlacements) {
          if (parentPlacement.row == row) {
            // Same row as parent
            final expectedCol =
                parentPlacement.endCol + (language.requiresPadding ? 2 : 1);
            if (col == expectedCol) {
              // Exactly where it should be after parent!
              score += 10000.0;
            } else if (col > expectedCol) {
              // Later on same row - still good but not as good
              score += 5000.0 - (col - expectedCol) * 10.0;
            }
          }
        }
      }
    }

    // Prefer positions near existing words (compactness)
    final distance = state.distanceToNearestWord(row, col);
    score -= distance * 5.0;

    // Prefer top-left positions
    score -= (row + col) * 1.0;

    // Prefer earlier in row (left side)
    score -= col * 0.5;

    return score;
  }

  /// Get parent words for a given word at current rank
  List<String> _getParentWords(
    String word,
    int currentRank,
    Map<String, int> ranks,
  ) {
    final parents = <String>[];
    for (final entry in graph.edges.entries) {
      final fromId = entry.key;
      final fromWord = fromId.split('#')[0];

      for (final toId in entry.value) {
        final toWord = toId.split('#')[0];
        if (toWord == word && ranks[fromWord]! < currentRank) {
          parents.add(fromWord);
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
