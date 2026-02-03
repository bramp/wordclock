import 'dart:math';
import 'package:wordclock/generator/backtracking/graph/cell_codec.dart';
import 'package:wordclock/generator/backtracking/grid_state.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/types.dart';
import 'package:wordclock/model/word_grid.dart';

/// Post-processes word placements to apply aesthetic alignments and fill padding.
class GridPostProcessor {
  final int width;
  final int height;
  final WordClockLanguage language;
  final String paddingAlphabet;
  final Random random;
  final List<Cell> paddingCells;
  final CellCodec codec;

  GridPostProcessor({
    required this.width,
    required this.height,
    required this.language,
    required this.paddingAlphabet,
    required this.random,
    required this.codec,
  }) : paddingCells = WordGrid.splitIntoCells(paddingAlphabet);

  /// Processes the placements and returns the final grid cells.
  GridPostProcessResult process(List<SolverPlacement> placements) {
    // 1. Distribute padding horizontally
    final shifted = distributePadding(placements);

    // 2. Generate the initial grid from placements (with nulls)
    final gridWithNulls = generateGrid(shifted);

    // 3. Fill remaining cells with padding
    final finalGrid = fillPadding(gridWithNulls);

    return GridPostProcessResult(grid: finalGrid, placements: shifted);
  }

  /// Distributes trailing padding horizontally for each row.
  /// Last row: all padding moves to the left (words pushed right).
  /// Other rows: padding is distributed between the left and internal gaps.
  List<SolverPlacement> distributePadding(List<SolverPlacement> original) {
    if (original.isEmpty) return [];

    // 1. Group original placements into clusters by their solver-assigned rows.
    final usedRows = original.map((p) => p.row).toSet().toList()..sort();
    final rowsOfClusters = <List<_Cluster>>[];
    for (final r in usedRows) {
      final rowPlacements = original.where((p) => p.row == r).toList()
        ..sort((a, b) => a.startCol.compareTo(b.startCol));
      final clusters = <_Cluster>[];
      for (final p in rowPlacements) {
        if (clusters.isEmpty || p.startCol > clusters.last.endCol) {
          clusters.add(_Cluster(p));
        } else {
          clusters.last.add(p);
        }
      }
      rowsOfClusters.add(clusters);
    }

    // 2. Split rows vertically to use as much grid height as possible.
    final totalClustersCount = rowsOfClusters.fold(
      0,
      (sum, list) => sum + list.length,
    );
    final rowCountTarget = min(totalClustersCount, height);
    while (rowsOfClusters.length < rowCountTarget) {
      int splitIdx = -1;
      for (int i = 0; i < rowsOfClusters.length; i++) {
        if (rowsOfClusters[i].length > 1) {
          if (splitIdx == -1 ||
              rowsOfClusters[i].length > rowsOfClusters[splitIdx].length) {
            splitIdx = i;
          }
        }
      }
      if (splitIdx == -1) break;
      final list = rowsOfClusters[splitIdx];
      int mid = (list.length + 1) ~/ 2;
      rowsOfClusters.replaceRange(splitIdx, splitIdx + 1, [
        list.sublist(0, mid),
        list.sublist(mid),
      ]);
    }

    // 3. Map resulting rows to physical row indices [0...height-1], spreading vertically.
    final rowCount = rowsOfClusters.length;
    final physicalRows = List.generate(rowCount, (i) {
      if (rowCount <= 1) return 0;
      return (i * (height - 1)) ~/ (rowCount - 1);
    });

    final firstRowWithWords = physicalRows.first;
    final lastRowWithWords = physicalRows.last;

    // 4. Create shifted placements with aesthetic horizontal alignment for each row.
    final result = <SolverPlacement>[];
    for (int i = 0; i < rowCount; i++) {
      final clusters = rowsOfClusters[i];
      final r = physicalRows[i];

      final occupiedLength = clusters.fold(0, (sum, c) => sum + c.length);
      final totalPadding = width - occupiedLength;
      final numSlots = clusters.length;
      int minGapTotal = language.requiresPadding ? numSlots - 1 : 0;
      final extraPadding = totalPadding - minGapTotal;

      // Fallback if solver found a state that doesn't fit our padding rules (shouldn't happen)
      if (extraPadding < 0) {
        for (final c in clusters) {
          for (final p in c.members) {
            result.add(p.shiftedTo(r, p.startCol));
          }
        }
        continue;
      }

      final distribution = List.filled(numSlots, 0);
      if (r == lastRowWithWords && r != firstRowWithWords) {
        // Last row with words: push right
        distribution[0] = extraPadding;
      } else if (r == firstRowWithWords) {
        // First row with words: push left
      } else {
        // Intermediate: distribute padding generally (Center/Justified)
        if (numSlots == 1) {
          // Center the single item
          distribution[0] = extraPadding ~/ 2;
        } else {
          // Distribute padding between items and edges.
          // We use a randomized approach to avoid vertical columns:
          // We have 'extraPadding' to distribute into 'numSlots + 1' buckets
          // (before 1st item, between items, after last item).
          int totalBuckets = numSlots + 1;

          List<int> buckets = List.filled(totalBuckets, 0);

          // Distribute extraPadding randomly one unit at a time.
          // This ensures a "stable" (seeded) but "random" distribution.
          for (int p = 0; p < extraPadding; p++) {
            buckets[random.nextInt(totalBuckets)]++;
          }

          // Map buckets to distribution array (which covers padding *before* each item).
          for (int k = 0; k < numSlots; k++) {
            distribution[k] = buckets[k];
          }
        }
      }

      int currentPos = 0;
      for (int k = 0; k < numSlots; k++) {
        currentPos += distribution[k];
        final cluster = clusters[k];
        final colDelta = currentPos - cluster.startCol;
        for (final p in cluster.members) {
          result.add(p.shiftedTo(r, p.startCol + colDelta));
        }
        currentPos += cluster.length;
        if (language.requiresPadding && k < numSlots - 1) {
          currentPos += 1;
        }
      }
    }

    return result;
  }

  /// Generates a grid from a list of placements
  List<Cell?> generateGrid(List<SolverPlacement> placements) {
    final grid = List<Cell?>.filled(width * height, null);
    for (final p in placements) {
      // Use effective cellCodes from placement, or re-encode if missing
      final codes =
          p.cellCodes ?? codec.encodeAll(WordGrid.splitIntoCells(p.word));

      for (int i = 0; i < codes.length; i++) {
        grid[p.row * width + p.startCol + i] = codec.decode(codes[i]);
      }
    }
    return grid;
  }

  /// Fill remaining empty cells with random padding characters
  List<Cell> fillPadding(List<Cell?> grid) {
    final result = List<Cell>.filled(grid.length, '');
    for (int i = 0; i < grid.length; i++) {
      result[i] = grid[i] ?? paddingCells[random.nextInt(paddingCells.length)];
    }
    return result;
  }
}

/// Result of the post-processing step.
class GridPostProcessResult {
  final List<Cell> grid;
  final List<SolverPlacement> placements;

  GridPostProcessResult({required this.grid, required this.placements});
}

/// A cluster of overlapping word placements on a single row.
class _Cluster {
  final List<SolverPlacement> members = [];
  int startCol;
  int endCol;

  _Cluster(SolverPlacement p) : startCol = p.startCol, endCol = p.endCol {
    members.add(p);
  }

  void add(SolverPlacement p) {
    members.add(p);
    if (p.startCol < startCol) startCol = p.startCol;
    if (p.endCol > endCol) endCol = p.endCol;
  }

  int get length => endCol - startCol + 1;
}
