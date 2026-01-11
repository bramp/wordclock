import 'package:wordclock/model/types.dart';

/// Maps cell strings to unique integer codes for fast comparison.
///
/// This serves as an intern table for [Cell] values (typically single characters
/// or strings like "O'"). Identical cells are mapped to the same integer code,
/// allowing O(1) character comparison during the backtracking search.
///
/// Example:
/// ```dart
/// final codec = CellCodec();
/// final a1 = codec.encode('A'); // Returns 0
/// final b = codec.encode('B');  // Returns 1
/// final a2 = codec.encode('A'); // Returns 0 (reused)
/// ```
///
/// - Code -1 is reserved for [emptyCell].
/// - Positive codes are assigned sequentially starting from 0.
class CellCodec {
  final Map<Cell, int> _cellToCode = {};
  final List<Cell> _codeToCell = [];

  /// Get or create an integer code for a cell string.
  int encode(Cell cell) {
    var code = _cellToCode[cell];
    if (code == null) {
      code = _codeToCell.length;
      _cellToCode[cell] = code;
      _codeToCell.add(cell);
    }
    return code;
  }

  /// Convert integer code back to cell string.
  Cell decode(int code) => _codeToCell[code];

  /// Encode a list of cells to codes.
  List<int> encodeAll(List<Cell> cells) {
    final result = List<int>.filled(cells.length, 0);
    for (var i = 0; i < cells.length; i++) {
      result[i] = encode(cells[i]);
    }
    return result;
  }
}
