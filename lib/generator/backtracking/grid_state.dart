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

  /// Length of the word in cells
  int get length => endCol - startCol + 1;

  WordPlacement({
    required this.node,
    required this.row,
    required this.startCol,
    required this.endCol,
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
  String toString() => 'WordPlacement(${node.id}@($row,$startCol-$endCol))';
}

/// Represents the current state of the grid during backtracking.
class GridState {
  /// The grid: [row][col] -> cell content or null
  final List<List<String?>> grid;

  /// Reference count for each cell: [row][col] -> number of words using this cell
  final List<List<int>> _usage;

  /// Public getter for usage (mostly for testing/assertions)
  List<List<int>> get usage => _usage;

  /// Width of the grid
  final int width;

  /// Height of the grid
  final int height;

  /// Track word placements: word node -> placement
  final Map<WordNode, WordPlacement> nodePlacements;

  /// Track which phrases are fully satisfied
  final Set<String> satisfiedPhrases;

  int _filledCellsCount = 0;
  int _totalWordsLength = 0;

  /// Total unique cells filled
  int get filledCells => _filledCellsCount;

  /// Total overlap cells across all placements
  int get totalOverlapCells => _totalWordsLength - _filledCellsCount;

  /// Compactness score: ratio of overlaps to filled cells
  double get compactness {
    final filled = filledCells;
    return filled > 0 ? totalOverlapCells / filled : 0;
  }

  /// Density score: ratio of filled cells to total grid size
  double get density => filledCells / (width * height);

  GridState({required this.width, required this.height})
    : grid = List.generate(height, (_) => List.filled(width, null)),
      _usage = List.generate(height, (_) => List.filled(width, 0)),
      nodePlacements = {},
      satisfiedPhrases = {};

  /// The index of the highest row currently used in any placement
  int get maxRowUsed {
    if (nodePlacements.isEmpty) return -1;
    int maxRow = -1;
    for (final p in nodePlacements.values) {
      if (p.row > maxRow) maxRow = p.row;
    }
    return maxRow;
  }

  /// Create a deep copy of this state
  GridState clone() {
    final newState = GridState(width: width, height: height);

    // Copy grid and usage
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        newState.grid[row][col] = grid[row][col];
        newState._usage[row][col] = _usage[row][col];
      }
    }

    // Copy word placements
    newState.nodePlacements.addAll(nodePlacements);

    // Copy satisfied phrases
    newState.satisfiedPhrases.addAll(satisfiedPhrases);

    // Copy counters
    newState._filledCellsCount = _filledCellsCount;
    newState._totalWordsLength = _totalWordsLength;

    return newState;
  }

  /// Check if a word can be placed at the given position
  ///
  /// Returns true if placement is possible
  bool canPlaceWord(List<String> cells, int row, int col) {
    // Check bounds
    assert(row >= 0 && row < height);
    assert(col >= 0 && col + cells.length <= width);

    // Check each cell
    for (int i = 0; i < cells.length; i++) {
      final c = col + i;
      final existing = grid[row][c];
      if (existing != null && existing != cells[i]) {
        return false;
      }
    }

    return true;
  }

  /// Place a word node on the grid
  ///
  /// Returns the WordPlacement if successful, null if placement fails
  WordPlacement? placeWord(WordNode node, int row, int col) {
    if (!canPlaceWord(node.cells, row, col)) return null;

    // Place the word
    for (int i = 0; i < node.cells.length; i++) {
      final c = col + i;
      if (grid[row][c] == null) {
        _filledCellsCount++;
      }
      grid[row][c] = node.cells[i];
      _usage[row][c]++;
    }

    _totalWordsLength += node.cells.length;

    // Create placement record
    final placement = WordPlacement(
      node: node,
      row: row,
      startCol: col,
      endCol: col + node.cells.length - 1,
    );

    // Record placement
    nodePlacements[node] = placement;

    return placement;
  }

  /// Remove a placed word from the grid (backtracking support)
  void removePlacement(WordPlacement placement) {
    // Remove from map
    nodePlacements.remove(placement.node);

    // TODO This is using reference counting, to know when to remove
    // a value from a cell. But I think keeping a index of overlaps in
    // WordPlacement may be more efficient.
    final node = placement.node;
    for (int i = 0; i < node.cells.length; i++) {
      final c = placement.startCol + i;
      _usage[placement.row][c]--;
      if (_usage[placement.row][c] == 0) {
        grid[placement.row][c] = null;
        _filledCellsCount--;
      }
    }

    _totalWordsLength -= node.cells.length;
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
