import 'dart:math';
import 'package:wordclock/generator/backtracking/graph/word_node.dart';
import 'package:wordclock/generator/utils/grid_validator.dart';
import 'package:wordclock/model/types.dart';

/// Sentinel value for empty cells in the integer grid
const int emptyCell = -1;

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
  /// The grid as 1D array: [row * width + col] -> cell code or emptyCell (-1)
  final List<int> grid;

  /// Reference count for each cell as 1D array: [row * width + col] -> number of words using this cell
  final List<int> _usage;

  /// Codec for converting between cell strings and integer codes
  final CellCodec codec;

  /// Public getter for usage (mostly for testing/assertions)
  List<int> get usage => _usage;

  /// Width of the grid
  final int width;

  /// Height of the grid
  final int height;

  /// Track word placements: word node -> placement
  final Map<WordNode, WordPlacement> nodePlacements;

  /// Track which phrases are fully satisfied
  final Set<String> satisfiedPhrases;

  /// Count of placements per row (for efficient maxRowUsed tracking)
  final List<int> _placementsPerRow;

  int _filledCellsCount = 0;
  int _totalWordsLength = 0;
  int _maxRowUsed = -1;

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

  GridState({required this.width, required this.height, required this.codec})
    : grid = List.filled(width * height, emptyCell),
      _usage = List.filled(width * height, 0),
      _placementsPerRow = List.filled(height, 0),
      nodePlacements = {},
      satisfiedPhrases = {};

  /// The index of the highest row currently used in any placement (cached)
  int get maxRowUsed => _maxRowUsed;

  /// Create a deep copy of this state
  GridState clone() {
    final newState = GridState(width: width, height: height, codec: codec);

    // Copy grid and usage (1D arrays - simple copy)
    for (int i = 0; i < grid.length; i++) {
      newState.grid[i] = grid[i];
      newState._usage[i] = _usage[i];
    }
    for (int row = 0; row < height; row++) {
      newState._placementsPerRow[row] = _placementsPerRow[row];
    }

    // Copy word placements
    newState.nodePlacements.addAll(nodePlacements);

    // Copy satisfied phrases
    newState.satisfiedPhrases.addAll(satisfiedPhrases);

    // Copy counters
    newState._filledCellsCount = _filledCellsCount;
    newState._totalWordsLength = _totalWordsLength;
    newState._maxRowUsed = _maxRowUsed;

    return newState;
  }

  /// Check if a word can be placed at the given 1D offset using cell codes
  ///
  /// Returns true if placement is possible
  bool canPlaceWord(List<int> cellCodes, int offset) {
    // Check bounds
    assert(offset >= 0 && offset % width + cellCodes.length <= width);

    // Check each cell
    for (int i = 0; i < cellCodes.length; i++) {
      final existing = grid[offset + i];
      if (existing != emptyCell && existing != cellCodes[i]) {
        return false;
      }
    }

    return true;
  }

  /// Place a word node on the grid at the given 1D offset
  ///
  /// Returns the WordPlacement if successful, null if placement fails
  WordPlacement? placeWord(WordNode node, int offset) {
    if (!canPlaceWord(node.cellCodes, offset)) return null;

    // Place the word using cell codes
    final cellCodes = node.cellCodes;
    for (int i = 0; i < cellCodes.length; i++) {
      final idx = offset + i;
      if (grid[idx] == emptyCell) {
        _filledCellsCount++;
      }
      grid[idx] = cellCodes[i];
      _usage[idx]++;
    }

    _totalWordsLength += cellCodes.length;

    // Create placement record (convert offset to row/col)
    final row = offset ~/ width;
    final col = offset % width;
    final placement = WordPlacement(
      node: node,
      row: row,
      startCol: col,
      endCol: col + cellCodes.length - 1,
    );

    // Record placement
    nodePlacements[node] = placement;
    _placementsPerRow[row]++;

    // Update cached maxRowUsed
    if (row > _maxRowUsed) _maxRowUsed = row;

    return placement;
  }

  /// Remove a placed word from the grid (backtracking support)
  void removePlacement(WordPlacement placement) {
    // Remove from map
    nodePlacements.remove(placement.node);
    _placementsPerRow[placement.row]--;

    // Update cached maxRowUsed if we removed the last placement from the max row
    if (placement.row == _maxRowUsed && _placementsPerRow[placement.row] == 0) {
      // Scan backwards to find the new max row
      _maxRowUsed = -1;
      for (int r = placement.row - 1; r >= 0; r--) {
        if (_placementsPerRow[r] > 0) {
          _maxRowUsed = r;
          break;
        }
      }
    }

    final cellCodes = placement.node.cellCodes;
    final baseIdx = placement.row * width + placement.startCol;
    for (int i = 0; i < cellCodes.length; i++) {
      final idx = baseIdx + i;
      _usage[idx]--;
      if (_usage[idx] == 0) {
        grid[idx] = emptyCell;
        _filledCellsCount--;
      }
    }

    _totalWordsLength -= cellCodes.length;
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

    // Scan in reading order (already 1D)
    for (int i = 0; i < grid.length; i++) {
      if (grid[i] != emptyCell) {
        if (lastFilledPos >= 0) {
          wasted += i - lastFilledPos - 1;
        }
        lastFilledPos = i;
      }
    }

    return wasted;
  }

  /// Convert grid to flat list of cells (decodes integer codes back to strings)
  List<Cell> toFlatList({String paddingChar = ' '}) {
    return grid
        .map((code) => code == emptyCell ? paddingChar : codec.decode(code))
        .toList();
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
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        final code = grid[row * width + col];
        buffer.write(code == emptyCell ? '·' : codec.decode(code));
      }
      buffer.writeln();
    }
    return buffer.toString();
  }
}
