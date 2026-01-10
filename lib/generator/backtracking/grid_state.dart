import 'dart:typed_data';
import 'package:wordclock/generator/backtracking/graph/word_node.dart';
import 'package:wordclock/generator/utils/grid_validator.dart';
import 'package:wordclock/model/types.dart';

/// Sentinel value for empty cells in the integer grid
const int emptyCell = -1;

/// Represents a placed word on the grid.
class WordPlacement {
  /// The word node that was placed
  final WordNode node;

  /// 1D offset where the word starts
  final int startOffset;

  /// Grid width (needed to derive row/col)
  final int width;

  /// The word text
  String get word => node.word;

  /// Row where the word starts (0-based)
  int get row => startOffset ~/ width;

  /// Column where the word starts (0-based)
  int get startCol => startOffset % width;

  /// Column where the word ends (inclusive, 0-based)
  int get endCol => startCol + node.cellCodes.length - 1;

  /// 1D offset where the word ends
  int get endOffset => startOffset + node.cellCodes.length - 1;

  /// Length of the word in cells
  int get length => node.cellCodes.length;

  WordPlacement({
    required this.node,
    required this.startOffset,
    required this.width,
  });

  /// Create a new placement shifted to a specific row and column.
  WordPlacement shiftedTo(int row, int col) {
    return WordPlacement(
      node: node,
      startOffset: row * width + col,
      width: width,
    );
  }

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
  /// Uses Int8List for better cache locality and faster iteration.
  final Int8List grid;

  /// Reference count for each cell: [row * width + col] -> number of words using this cell.
  /// Uses Uint8List since overlap count is always small (typically 0-3).
  final Uint8List _usage;

  /// Codec for converting between cell strings and integer codes
  final CellCodec codec;

  /// Public getter for usage (mostly for testing/assertions)
  Uint8List get usage => _usage;

  /// Width of the grid
  final int width;

  /// Height of the grid
  final int height;

  /// Track word placements as a stack (LIFO for backtracking)
  final List<WordPlacement> _placementStack;

  int _filledCellsCount = 0;
  int _totalWordsLength = 0;

  /// Number of words currently placed
  int get placementCount => _placementStack.length;

  /// Direct access to placement stack (for efficient indexed access)
  List<WordPlacement> get placements => _placementStack;

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
    : grid = Int8List(width * height)..fillRange(0, width * height, emptyCell),
      _usage = Uint8List(width * height),
      _placementStack = [];

  /// Private constructor for cloning
  GridState._cloneFrom({
    required this.width,
    required this.height,
    required this.codec,
    required this.grid,
    required Uint8List usage,
  }) : _usage = usage,
       _placementStack = [];

  /// The highest 1D offset currently used in any placement
  /// Derived from the top of the placement stack (LIFO order means top has max offset)
  int get maxEndOffset =>
      _placementStack.isEmpty ? -1 : _placementStack.last.endOffset;

  /// Create a deep copy of this state
  GridState clone() {
    final newState = GridState._cloneFrom(
      width: width,
      height: height,
      codec: codec,
      grid: Int8List.fromList(grid),
      usage: Uint8List.fromList(_usage),
    );

    // Copy placement stack
    newState._placementStack.addAll(_placementStack);

    // Copy counters
    newState._filledCellsCount = _filledCellsCount;
    newState._totalWordsLength = _totalWordsLength;

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

  /// Place a word node on the grid at the given 1D offset.
  ///
  /// This method validates placement before writing to the grid.
  /// Returns the WordPlacement if successful, null if placement fails.
  ///
  /// **Performance note:** If you've already validated the placement via
  /// [findEarliestPlacementByPhrase] or similar, use [placeWordUnchecked]
  /// instead to avoid redundant validation.
  WordPlacement? placeWord(WordNode node, int offset) {
    if (!canPlaceWord(node.cellCodes, offset)) return null;
    return placeWordUnchecked(node, offset);
  }

  /// Place a word node on the grid without checking validity.
  ///
  /// **Performance optimization:** This method skips the [canPlaceWord] check.
  /// Use this when you've already validated the placement elsewhere (e.g.,
  /// [findEarliestPlacementByPhrase] already scans for valid positions).
  /// Avoiding the redundant validation saves ~5-10% in hot loops.
  ///
  /// **Precondition:** Caller MUST ensure the placement is valid:
  /// - `offset >= 0`
  /// - Word fits on the row: `offset % width + node.cellCodes.length <= width`
  /// - All cells are either empty or match the word's cell codes
  WordPlacement placeWordUnchecked(WordNode node, int offset) {
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

    // Create placement record
    final placement = WordPlacement(
      node: node,
      startOffset: offset,
      width: width,
    );

    // Record placement (push to stack)
    _placementStack.add(placement);

    return placement;
  }

  /// Remove a placed word from the grid (backtracking support)
  /// Note: Must be called in LIFO order (most recent placement first)
  void removePlacement(WordPlacement placement) {
    // Pop from stack (assert LIFO order)
    assert(
      _placementStack.isNotEmpty && _placementStack.last == placement,
      'removePlacement must be called in LIFO order',
    );
    _placementStack.removeLast();

    final cellCodes = placement.node.cellCodes;
    for (int i = 0; i < cellCodes.length; i++) {
      final idx = placement.startOffset + i;
      _usage[idx]--;
      if (_usage[idx] == 0) {
        grid[idx] = emptyCell;
        _filledCellsCount--;
      }
    }

    _totalWordsLength -= cellCodes.length;
  }

  /// Convert grid to flat list of cells (decodes integer codes back to strings)
  List<Cell?> toFlatList({Cell? paddingChar}) {
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
    buffer.writeln('  Words placed: ${_placementStack.length}');
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
