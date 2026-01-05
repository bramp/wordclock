import 'package:wordclock/generator/greedy/grid_generator.dart';
import 'package:wordclock/generator/utils/grid_build_result.dart';
import 'package:wordclock/generator/utils/grid_validator.dart';
import 'package:wordclock/generator/utils/word_clock_utils.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';

/// A greedy grid builder that generates word clock grids.
///
/// This builder:
/// 1. Uses a constraint-based algorithm to place words
/// 2. Greedily fills the grid row by row
/// 3. Supports word overlap when characters match
class GreedyGridBuilder {
  final int width;
  final int height;
  final WordClockLanguage language;
  final int seed;

  GreedyGridBuilder({
    required this.width,
    required this.height,
    required this.language,
    required this.seed,
  });

  /// Attempts to build a grid that satisfies all constraints.
  ///
  /// Returns a GridBuildResult with the grid and validation information.
  GridBuildResult build() {
    // Count unique words needed
    final uniqueWords = <String>{};
    WordClockUtils.forEachTime(language, (time, phrase) {
      final tokens = language.tokenize(phrase);
      for (final token in tokens) {
        uniqueWords.add(token);
      }
    });
    final totalWords = uniqueWords.length;

    // Try to generate grid with user-provided seed
    List<String>? cells;
    String? errorMessage;

    try {
      cells = GridGenerator.generate(
        width: width,
        seed: seed,
        language: language,
        targetHeight: height,
      );
    } catch (e) {
      errorMessage = e.toString();
    }

    if (cells == null) {
      return GridBuildResult(
        grid: null,
        validationIssues: [errorMessage ?? 'Failed to generate grid'],
        totalWords: totalWords,
        placedWords: 0,
      );
    }

    // Merge cells (handle apostrophes)
    final mergedCells = WordGrid.splitIntoCells(
      cells.join(''),
      mergeApostrophes: true,
    );

    final actualHeight = mergedCells.length ~/ width;

    // Pad or truncate to match target height
    List<String> finalCells;
    if (actualHeight < height) {
      // Pad with spaces
      finalCells = List<String>.from(mergedCells);
      final needed = (height * width) - mergedCells.length;
      finalCells.addAll(List.filled(needed, ' '));
    } else if (actualHeight > height) {
      // Truncate
      finalCells = mergedCells.sublist(0, height * width);
    } else {
      finalCells = mergedCells;
    }

    // Validate the grid
    final wordGrid = WordGrid(width: width, cells: finalCells);
    final issues = GridValidator.validate(wordGrid, language);

    // Estimate placed words based on validation
    int placedWords = totalWords;
    if (issues.isNotEmpty) {
      // Some words missing - count from validation issues
      final missingCount = issues.where((i) => i.contains('not found')).length;
      placedWords = totalWords - missingCount;
    }

    return GridBuildResult(
      grid: finalCells,
      validationIssues: issues,
      totalWords: totalWords,
      placedWords: placedWords,
    );
  }
}
