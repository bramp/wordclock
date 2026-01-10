import 'package:wordclock/generator/greedy/grid_generator.dart';
import 'package:wordclock/generator/greedy/grid_layout.dart';
import 'package:wordclock/generator/model/grid_build_result.dart';
import 'package:wordclock/generator/utils/grid_validator.dart';
import 'package:wordclock/generator/utils/word_clock_utils.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/generator/model/word_placement.dart';

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
    ({List<String> cells, List<RawPlacement> placements})? genResult;
    String? errorMessage;

    try {
      genResult = GridGenerator.generate(
        width: width,
        seed: seed,
        language: language,
        targetHeight: height,
      );
    } catch (e) {
      errorMessage = e.toString();
    }

    if (genResult == null) {
      return GridBuildResult(
        grid: WordGrid(width: width, cells: List.filled(width * height, ' ')),
        validationIssues: [errorMessage ?? 'Failed to generate grid'],
        totalWords: totalWords,
      );
    }

    final cells = genResult.cells;

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
      finalCells = List.from(mergedCells);
      final needed = (height * width) - mergedCells.length;
      finalCells.addAll(List.filled(needed, ' '));
    } else if (actualHeight > height) {
      // Truncate
      finalCells = mergedCells.sublist(0, height * width);
    } else {
      finalCells = mergedCells;
    }

    final wordGrid = WordGrid(width: width, cells: finalCells);

    // Build WordPlacements from raw placements
    // Note: greedy placements might be truncated if they were past height
    final wordPlacements = [
      for (final raw in genResult.placements)
        if (raw.startOffset < wordGrid.cells.length)
          WordPlacement(
            word: raw.word,
            startOffset: raw.startOffset,
            width: width,
            length: raw.length,
          ),
    ];

    // Validate the grid
    final issues = GridValidator.validate(wordGrid, language);

    return GridBuildResult(
      grid: wordGrid,
      validationIssues: issues,
      totalWords: totalWords,
      wordPlacements: wordPlacements,
    );
  }
}
