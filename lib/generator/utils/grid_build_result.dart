import 'package:wordclock/generator/backtracking/grid_state.dart';

/// Reason why the grid building stopped
enum StopReason {
  /// Search completed successfully (found optimal or first valid)
  completed,

  /// Stopped due to timeout
  timeout,

  /// Stopped due to reaching max iterations
  maxIterations,

  /// Stopped by user/callback
  userStopped,
}

/// Result of building a grid
class GridBuildResult {
  final List<String>? grid;
  final List<String> validationIssues;
  final int totalWords;
  final int placedWords;

  /// Information about each placed word (for visualization)
  final List<WordPlacement> wordPlacements;

  /// Total iterations performed during the search
  final int iterationCount;

  /// When the search started
  final DateTime? startTime;

  /// Why the search stopped
  final StopReason stopReason;

  GridBuildResult({
    required this.grid,
    required this.validationIssues,
    required this.totalWords,
    required this.placedWords,
    this.wordPlacements = const [],
    this.iterationCount = 0,
    this.startTime,
    this.stopReason = StopReason.completed,
  });

  bool get isOptimal => validationIssues.isEmpty && placedWords == totalWords;
}
