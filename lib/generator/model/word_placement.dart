/// Represents a word placed on a word clock grid.
///
/// This is a solver-agnostic data class used for result reporting
/// and UI visualization.
class WordPlacement {
  /// The word text (e.g., "FIVE")
  final String word;

  /// 1D offset where the word starts in the cell list
  final int startOffset;

  /// Width of the grid this word is placed in
  final int width;

  /// Length of the word in grid cells
  final int length;

  WordPlacement({
    required this.word,
    required this.startOffset,
    required this.width,
    required this.length,
  });

  /// Row index (0-based)
  int get row => startOffset ~/ width;

  /// Starting column index (0-based)
  int get startCol => startOffset % width;

  /// Ending column index (inclusive, 0-based)
  int get endCol => startCol + length - 1;

  @override
  String toString() => 'WordPlacement($word at $row:$startCol-$endCol)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordPlacement &&
          runtimeType == other.runtimeType &&
          word == other.word &&
          startOffset == other.startOffset &&
          width == other.width &&
          length == other.length;

  @override
  int get hashCode =>
      word.hashCode ^ startOffset.hashCode ^ width.hashCode ^ length.hashCode;
}
