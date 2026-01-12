import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/generator/model/word_placement.dart';

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
  final WordGrid grid;
  final List<String> validationIssues;
  final int totalWords;

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
    this.wordPlacements = const [],
    this.iterationCount = 0,
    this.startTime,
    this.stopReason = StopReason.completed,
  });

  int get placedWords => wordPlacements.length;

  /// Number of unique words placed in the grid
  int get uniquePlacedWords => wordPlacements.map((p) => p.word).toSet().length;

  bool get isOptimal => validationIssues.isEmpty && uniquePlacedWords == totalWords;
}
