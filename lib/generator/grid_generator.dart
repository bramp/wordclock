import 'package:wordclock/generator/grid_layout.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/languages/all.dart';

/// A high-level generator that orchestrates the creation of a word clock grid.
class GridGenerator {
  /// Generates a list of characters (cells) for a word clock grid.
  ///
  /// Uses a constraint-based algorithm that places words on a 2D grid with
  /// overlap support, optimizing for compact placement while respecting
  /// phrase ordering and spacing constraints.
  ///
  /// Parameters:
  /// - [width]: The fixed width of the grid.
  /// - [seed]: Optional seed for random number generation (ensures reproducibility).
  /// - [language]: The language logic to use (defaults to English).
  /// - [targetHeight]: Target height for the grid (defaults to 10).
  ///
  /// Example:
  /// ```dart
  /// final cells = GridGenerator.generate(
  ///   width: 11,
  ///   language: catalanLanguage,
  ///   seed: 42,
  ///   targetHeight: 10,
  /// );
  /// ```
  static List<String> generate({
    required int width,
    int? seed,
    WordClockLanguage? language,
    int targetHeight = 10,
  }) {
    final lang = language ?? WordClockLanguages.byId['en']!;

    return GridLayout.generateCells(
      width: width,
      language: lang,
      seed: seed ?? 0,
      targetHeight: targetHeight,
    );
  }
}
