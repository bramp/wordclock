import 'package:wordclock/generator/model/word_placement.dart';
import 'package:wordclock/model/types.dart';

/// Progress information during grid building.
class GridBuildProgress {
  /// Best number of words placed so far
  final int bestWords;

  /// Total words to place
  final int totalWords;

  /// Number of phrases completed in current search path
  final int phrasesCompleted;

  /// Best number of phrases completed so far
  final int bestPhrases;

  /// Total phrases to complete
  final int totalPhrases;

  /// Grid width
  final int width;

  /// Current grid cells (for colored display). May contain nulls for empty cells.
  final List<Cell?> cells;

  /// Word placement info (for colored display)
  final List<WordPlacement> wordPlacements;

  /// Number of iterations (recursive calls) so far
  final int iterationCount;

  /// When the search started
  final DateTime startTime;

  /// Total word placements in current search path (may include duplicates)
  int get currentWords => wordPlacements.length;

  /// Unique words placed in current search path
  int get uniqueCurrentWords => wordPlacements.map((p) => p.word).toSet().length;

  GridBuildProgress({
    required this.bestWords,
    required this.totalWords,
    required this.phrasesCompleted,
    required this.bestPhrases,
    required this.totalPhrases,
    required this.width,
    required this.cells,
    required this.wordPlacements,
    required this.iterationCount,
    required this.startTime,
  });
}

/// Callback for progress updates during grid building.
/// Return true to continue, false to stop the search.
typedef ProgressCallback = bool Function(GridBuildProgress progress);
