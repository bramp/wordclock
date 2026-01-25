import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:wordclock/generator/backtracking/graph/word_node.dart';
import 'package:wordclock/generator/backtracking/graph/cell_codec.dart';
import 'package:wordclock/generator/model/word_placement.dart' as public;
import 'package:wordclock/model/types.dart';

/// Sentinel value for empty cells in the integer grid
const int emptyCell = -1;

/// Represents a placed word on the grid.
class SolverPlacement {
  /// The word text
  final String word;

  /// Cell codes (private storage)
  final List<int>? _cellCodes;

  /// 1D offset where the word starts
  final int startOffset;

  /// Grid width (needed to derive row/col)
  final int width;

  /// Length of the word in cells
  final int length;

  /// The DAG node associated with this placement (optional, for Backtracking solver)
  final WordNode? node;

  /// Effective cell codes (from local storage or node)
  List<int>? get cellCodes => _cellCodes ?? node?.cellCodes;

  /// Row where the word starts (0-based)
  int get row => startOffset ~/ width;

  /// Column where the word starts (0-based)
  int get startCol => startOffset % width;

  /// Column where the word ends (inclusive, 0-based)
  int get endCol => startCol + length - 1;

  /// 1D offset where the word ends
  int get endOffset => startOffset + length - 1;

  /// Convert to public placement for reporting
  public.WordPlacement toPublic() => public.WordPlacement(
    word: word,
    startOffset: startOffset,
    width: width,
    length: length,
  );

  SolverPlacement({
    required this.word,
    required this.startOffset,
    required this.width,
    required this.length,
    List<int>? cellCodes,
    this.node,
  }) : _cellCodes = cellCodes;

  /// Create a new placement shifted to a specific row and column.
  SolverPlacement shiftedTo(int row, int col) {
    return SolverPlacement(
      word: word,
      startOffset: row * width + col,
      width: width,
      length: length,
      cellCodes: _cellCodes,
      node: node,
    );
  }

  @override
  String toString() => 'SolverPlacement($word@($row,$startCol-$endCol))';
}

/// Represents the current state of the grid during backtracking.
class GridState {
  /// The grid as 1D array: [row * width + col] -> cell code or emptyCell (-1)
  /// Uses Int8List for better cache locality and faster iteration.
  final Int8List grid;

  /// Codec for converting between cell strings and integer codes
  final CellCodec codec;

  /// Reference count for each cell: [row * width + col] -> number of words using this cell.
  /// Uses Uint8List since overlap count is always small (typically 0-3).
  final Uint8List _usage;

  /// Public getter for usage
  @visibleForTesting
  Uint8List get usage => _usage;

  /// Width of the grid
  final int width;

  /// Height of the grid
  final int height;

  /// Track word placements as a stack (LIFO for backtracking)
  final List<SolverPlacement> _placementStack;

  int _filledCellsCount = 0;
  int _totalWordsLength = 0;

  /// Number of words currently placed
  int get placementCount => _placementStack.length;

  /// Direct access to placement stack
  List<SolverPlacement> get placements => _placementStack;

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

  /// Check if a word can be placed at the given 1D offset.
  ///
  /// Returns true if placement is possible
  bool canPlaceWord(List<int> cellCodes, int offset) {
    if (offset < 0 || offset + cellCodes.length > grid.length) return false;
    if (offset % width + cellCodes.length > width) {
      return false; // Checks wrap-around
    }

    // Check each cell
    for (int i = 0; i < cellCodes.length; i++) {
      final existing = grid[offset + i];
      if (existing != emptyCell && existing != cellCodes[i]) {
        return false;
      }
    }

    return true;
  }

  /// Place a generic word. Used by Trie solver.
  SolverPlacement? placeGenericWord({
    required String word,
    required List<int> cellCodes,
    required int offset,
    WordNode? node,
  }) {
    // Optimistic placement (assumes bounded checks done by caller or loop logic)
    // But let's verify codes match if not empty.
    // Actually, placeWordUnchecked assumes valid.

    for (int i = 0; i < cellCodes.length; i++) {
      final idx = offset + i;
      if (grid[idx] == emptyCell) {
        _filledCellsCount++;
      }
      grid[idx] = cellCodes[i];
      _usage[idx]++;
    }

    _totalWordsLength += cellCodes.length;

    final placement = SolverPlacement(
      word: word,
      startOffset: offset,
      width: width,
      length: cellCodes.length,
      cellCodes: cellCodes,
      node: node,
    );

    _placementStack.add(placement);
    return placement;
  }

  /// Place a word node WITHOUT validity checks.
  /// Use ONLY if you are sure the word fits (e.g. after findFirstValidPlacement).
  SolverPlacement placeWordUnchecked(WordNode node, int offset) {
    return placeGenericWord(
      word: node.word,
      cellCodes: node.cellCodes,
      offset: offset,
      node: node,
    )!;
  }

  /// Place a word node (DAG solver). Wraps placeGenericWord.
  SolverPlacement? placeWord(WordNode node, int offset) {
    if (!canPlaceWord(node.cellCodes, offset)) return null;
    return placeWordUnchecked(node, offset);
  }

  /// Remove a placed word (backtracking)
  /// Remove a placed word (backtracking)
  void removePlacement(SolverPlacement placement) {
    assert(
      _placementStack.isNotEmpty && _placementStack.last == placement,
      'removePlacement must be called in LIFO order',
    );
    _placementStack.removeLast();

    final cellCodes = placement.cellCodes!;

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

  /// Convert grid to flat list of cells
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
