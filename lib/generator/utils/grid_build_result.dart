/// Result of building a grid
class GridBuildResult {
  final List<String>? grid;
  final List<String> validationIssues;
  final int totalWords;
  final int placedWords;

  GridBuildResult({
    required this.grid,
    required this.validationIssues,
    required this.totalWords,
    required this.placedWords,
  });

  bool get isOptimal => validationIssues.isEmpty && placedWords == totalWords;
}
