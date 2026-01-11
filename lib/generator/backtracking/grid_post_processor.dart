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
  final Random random;
  final List<Cell> paddingCells;
  final CellCodec codec;

  GridPostProcessor({
    required this.width,
    required this.height,
    required this.language,
    required this.random,
    required this.codec,
  }) : paddingCells = WordGrid.splitIntoCells(language.paddingAlphabet);

  /// Processes the placements and returns the final grid cells.
  GridPostProcessResult process(List<Placement> placements) {
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
  List<Placement> distributePadding(List<Placement> original) {
    final allPlacements = List<Placement>.from(original);

    // Find the first and last rows that actually contain words
    int firstRowWithWords = -1;
    int lastRowWithWords = -1;
    for (final p in allPlacements) {
      if (firstRowWithWords == -1 || p.row < firstRowWithWords) {
        firstRowWithWords = p.row;
      }
      if (p.row > lastRowWithWords) {
        lastRowWithWords = p.row;
      }
    }

    for (int r = 0; r < height; r++) {
      final rowPlacements = allPlacements.where((p) => p.row == r).toList();
      if (rowPlacements.isEmpty) continue;

      // Sort by start column to process clusters left-to-right
      rowPlacements.sort((a, b) => a.startCol.compareTo(b.startCol));

      // Group overlapping words into clusters that must move together
      final clusters = <_Cluster>[];
      for (final p in rowPlacements) {
        if (clusters.isEmpty || p.startCol > clusters.last.endCol) {
          clusters.add(_Cluster(p));
        } else {
          clusters.last.add(p);
        }
      }

      final occupiedLength = clusters.fold(0, (sum, c) => sum + c.length);
      final totalPadding = width - occupiedLength;
      final numSlots = clusters.length;

      // Calculate minimum mandatory gaps between clusters if required
      int minGapTotal = 0;
      if (language.requiresPadding) {
        minGapTotal = numSlots - 1;
      }

      final extraPadding = totalPadding - minGapTotal;

      // We should never have negative extra padding if the solver found a valid state
      if (extraPadding < 0) continue;

      final distribution = List.filled(numSlots, 0);
      if (r == lastRowWithWords && r != firstRowWithWords) {
        // Last row with words: push to absolute right (all extra padding to slot 0)
        distribution[0] = extraPadding;
      } else if (r == firstRowWithWords) {
        // First row with words: push to absolute left (all extra padding to the end)
        // distribution is already 0-filled, all padding remains trailing.
      } else {
        // Fair distribution: spread extra padding among left and internal slots
        int perSlot = extraPadding ~/ numSlots;
        int remainder = extraPadding % numSlots;
        for (int i = 0; i < numSlots; i++) {
          distribution[i] = perSlot + (i < remainder ? 1 : 0);
        }
      }

      // Apply distribution by shifting clusters absolutely based on the new gaps
      int currentPos = 0;
      for (int i = 0; i < numSlots; i++) {
        currentPos += distribution[i];

        // Shift this cluster's members to their new absolute positions
        final colDelta = currentPos - clusters[i].startCol;
        for (final p in clusters[i].members) {
          // Find the index in the main list and replace it
          final idx = allPlacements.indexOf(p);
          allPlacements[idx] = p.shiftedTo(p.row, p.startCol + colDelta);
        }

        currentPos += clusters[i].length;
        if (language.requiresPadding && i < numSlots - 1) {
          currentPos += 1; // Add the mandatory gap
        }
      }
    }
    return allPlacements;
  }

  /// Generates a grid from a list of placements
  List<Cell?> generateGrid(List<Placement> placements) {
    final grid = List<Cell?>.filled(width * height, null);
    for (final p in placements) {
      final cellCodes = p.node.cellCodes;
      for (int i = 0; i < cellCodes.length; i++) {
        grid[p.row * width + p.startCol + i] = codec.decode(cellCodes[i]);
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
  final List<Placement> placements;

  GridPostProcessResult({required this.grid, required this.placements});
}

/// A cluster of overlapping word placements on a single row.
class _Cluster {
  final List<Placement> members = [];
  int startCol;
  int endCol;

  _Cluster(Placement p) : startCol = p.startCol, endCol = p.endCol {
    members.add(p);
  }

  void add(Placement p) {
    members.add(p);
    if (p.startCol < startCol) startCol = p.startCol;
    if (p.endCol > endCol) endCol = p.endCol;
  }

  int get length => endCol - startCol + 1;
}
