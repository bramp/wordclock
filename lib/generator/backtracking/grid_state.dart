import 'dart:math';
import 'package:wordclock/generator/backtracking/graph/word_node.dart';
import 'package:wordclock/generator/utils/grid_validator.dart';

/// Represents a placed word on the grid.
class WordPlacement {
  /// The word node that was placed
  final WordNode node;

  /// Row where the word starts (0-based)
  final int row;

  /// Column where the word starts (0-based)
  final int startCol;

  /// Column where the word ends (inclusive, 0-based)
  final int endCol;

  /// Indices of cells (within this word) that overlapped with existing grid content
  final List<int> overlappedCells;

  /// Length of the word in cells
  int get length => endCol - startCol + 1;

  /// Number of cells that overlapped
  int get overlapCount => overlappedCells.length;

  WordPlacement({
    required this.node,
    required this.row,
    required this.startCol,
    required this.endCol,
    required this.overlappedCells,
  });

  /// Check if this placement comes after [other] in reading order
  bool comesAfter(WordPlacement other) {
    // Use shared validation logic
    return GridValidator.canPlaceAfter(
      prevEndRow: other.row,
      prevEndCol: other.endCol,
      currStartRow: row,
      currStartCol: startCol,
      requiresPadding: false, // Just checking reading order here
    );
  }

  /// Check if this placement has proper separation from [other] on the same row
  bool hasSeparationFrom(WordPlacement other, {required bool requiresPadding}) {
    // Use shared validation logic
    return GridValidator.hasSeparation(
      word1Row: other.row,
      word1StartCol: other.startCol,
      word1EndCol: other.endCol,
      word2Row: row,
      word2StartCol: startCol,
      word2EndCol: endCol,
      requiresPadding: requiresPadding,
    );
  }

  @override
  String toString() =>
      'WordPlacement(${node.id}@($row,$startCol-$endCol), overlaps=$overlapCount)';
}

/// Represents the current state of the grid during backtracking.
class GridState {
  /// The grid: [row][col] -> cell content or null
  final List<List<String?>> grid;

  /// Width of the grid
  final int width;

  /// Height of the grid
  final int height;

  /// Track word placements: word node -> placement
  final Map<WordNode, WordPlacement> nodePlacements;

  /// Track which phrases are fully satisfied
  final Set<String> satisfiedPhrases;

  /// Total cells filled (including overlaps)
  int get filledCells {
    int count = 0;
    for (final row in grid) {
      for (final cell in row) {
        if (cell != null) count++;
      }
    }
    return count;
  }

  /// Total overlap cells across all placements
  int get totalOverlapCells {
    int count = 0;
    for (final placement in nodePlacements.values) {
      count += placement.overlapCount;
    }
    return count;
  }

  /// Compactness score: ratio of overlaps to filled cells
  double get compactness {
    final filled = filledCells;
    return filled > 0 ? totalOverlapCells / filled : 0;
  }

  /// Density score: ratio of filled cells to total grid size
  double get density => filledCells / (width * height);

  GridState({required this.width, required this.height})
    : grid = List.generate(height, (_) => List.filled(width, null)),
      nodePlacements = {},
      satisfiedPhrases = {};

  /// Create a deep copy of this state
  GridState clone() {
    final newState = GridState(width: width, height: height);

    // Copy grid
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        newState.grid[row][col] = grid[row][col];
      }
    }

    // Copy word placements
    newState.nodePlacements.addAll(nodePlacements);

    // Copy satisfied phrases
    newState.satisfiedPhrases.addAll(satisfiedPhrases);

    return newState;
  }

  /// Check if a word can be placed at the given position
  ///
  /// Returns a tuple: (canPlace, overlappedIndices)
  /// - canPlace: true if placement is possible
  /// - overlappedIndices: list of cell indices (within word) that overlap with existing content
  (bool, List<int>) canPlaceWord(
    List<String> cells,
    int row,
    int col,
  ) {
    // Check bounds
    assert (row >= 0 && row < height);
    assert (col >= 0 && col + cells.length <= width);

    final overlappedIndices = <int>[];

    // Check each cell
    for (int i = 0; i < cells.length; i++) {
      final c = col + i;
      final existing = grid[row][c];

      if (existing == null) {
        // Empty cell - OK
      } else if (existing == cells[i]) {
        // Matching overlap - OK, record it
        overlappedIndices.add(i);
      } else {
        // Conflict - cannot place
        return (false, []);
      }
    }

    return (true, overlappedIndices);
  }

  /// Place a word node on the grid
  ///
  /// Returns the WordPlacement if successful, null if placement fails
  WordPlacement? placeWord(
    WordNode node,
    int row,
    int col,
  ) {
    final (canPlace, overlappedIndices) = canPlaceWord(node.cells, row, col);
    if (!canPlace) return null;

    // Place the word
    for (int i = 0; i < node.cells.length; i++) {
      grid[row][col + i] = node.cells[i];
    }

    // Create placement record
    final placement = WordPlacement(
      node: node,
      row: row,
      startCol: col,
      endCol: col + node.cells.length - 1,
      overlappedCells: overlappedIndices,
    );

    // Record placement
    nodePlacements[node] = placement;

    return placement;
  }

  /// Remove a placed word from the grid (backtracking support)
  void removePlacement(WordPlacement placement) {
    // Remove from map
    nodePlacements.remove(placement.node);

    // Clear grid cells that were NOT overlapped
    // We assume standard splitting matches - usually true unless special merging
    // Ideally we'd store the specific cells in placement, but regenerating is okay
    // for this context if we are consistent.
    // Actually, to be safe, we should check what's in the grid?
    // No, removing requires knowing what we put there.
    // We don't need the character value!

    for (int i = 0; i < placement.length; i++) {
      if (placement.overlappedCells.contains(i)) {
        continue; // Was existing, leave it
      }
      grid[placement.row][placement.startCol + i] = null;
    }
  }

  /// Get all placements of a specific word (by string)
  List<WordPlacement> getPlacementsOf(String word) {
    return nodePlacements.values.where((p) => p.node.word == word).toList();
  }

  /// Check if a word node is placed
  bool isNodePlaced(WordNode node) {
    return nodePlacements.containsKey(node);
  }

  /// Get the number of instances of a word that are placed
  int getPlacedInstanceCount(String word) {
    return nodePlacements.keys.where((n) => n.word == word).length;
  }

  /// Calculate distance from position to nearest placed word
  double distanceToNearestWord(int row, int col) {
    if (nodePlacements.isEmpty) return double.infinity;

    double minDist = double.infinity;

    for (final placement in nodePlacements.values) {
        // Distance to start of word
        final distStart = sqrt(
          pow(row - placement.row, 2) + pow(col - placement.startCol, 2),
        );
        minDist = min(minDist, distStart);

        // Distance to end of word
        final distEnd = sqrt(
          pow(row - placement.row, 2) + pow(col - placement.endCol, 2),
        );
        minDist = min(minDist, distEnd);
    }

    return minDist;
  }

  /// Count wasted cells (empty cells between placed words in reading order)
  int countWastedCells() {
    int wasted = 0;
    int lastFilledPos = -1;

    // Scan in reading order
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        final linearPos = row * width + col;
        if (grid[row][col] != null) {
          if (lastFilledPos >= 0) {
            wasted += linearPos - lastFilledPos - 1;
          }
          lastFilledPos = linearPos;
        }
      }
    }

    return wasted;
  }

  /// Convert grid to flat list of cells
  List<String> toFlatList({String paddingChar = ' '}) {
    final result = <String>[];
    for (final row in grid) {
      result.addAll(row.map((cell) => cell ?? paddingChar));
    }
    return result;
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('GridState:');
    buffer.writeln(
      '  Filled: $filledCells/${width * height} cells (${(density * 100).toStringAsFixed(1)}%)',
    );
    buffer.writeln(
      '  Overlaps: $totalOverlapCells (compactness: ${(compactness * 100).toStringAsFixed(1)}%)',
    );
    buffer.writeln('  Words placed: ${nodePlacements.length}');
    buffer.writeln('  Satisfied phrases: ${satisfiedPhrases.length}');
    return buffer.toString();
  }

  /// Debug: Print grid with visual representation
  String toGridString() {
    final buffer = StringBuffer();
    for (final row in grid) {
      for (final cell in row) {
        buffer.write(cell ?? '·');
      }
      buffer.writeln();
    }
    return buffer.toString();
  }
}
