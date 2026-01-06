/// Information about a placed word in the grid
class PlacedWordInfo {
  /// The word text
  final String word;

  /// Row where the word is placed (0-based)
  final int row;

  /// Starting column (0-based)
  final int startCol;

  /// Ending column (inclusive, 0-based)
  final int endCol;

  PlacedWordInfo({
    required this.word,
    required this.row,
    required this.startCol,
    required this.endCol,
  });
}

/// Result of building a grid
class GridBuildResult {
  final List<String>? grid;
  final List<String> validationIssues;
  final int totalWords;
  final int placedWords;

  /// Information about each placed word (for visualization)
  final List<PlacedWordInfo> wordPlacements;

  GridBuildResult({
    required this.grid,
    required this.validationIssues,
    required this.totalWords,
    required this.placedWords,
    this.wordPlacements = const [],
  });

  bool get isOptimal => validationIssues.isEmpty && placedWords == totalWords;
}
