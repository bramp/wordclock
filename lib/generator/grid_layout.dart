import 'package:wordclock/generator/constraint_grid_builder.dart';
import 'package:wordclock/languages/language.dart';

/// A layout engine that arranges words into a grid.
///
/// Uses a constraint-based algorithm that places whole words on a 2D grid
/// with overlap support, using scoring heuristics to find optimal positions
/// while respecting phrase ordering and spacing constraints.
class GridLayout {
  /// Generates a list of cells for a word clock grid.
  ///
  /// Parameters:
  /// - [width]: The fixed width of the grid.
  /// - [language]: The language to generate the grid for.
  /// - [seed]: Random seed for reproducible grids.
  /// - [targetHeight]: The target height of the grid (default: 10).
  ///
  /// Example:
  /// ```dart
  /// final cells = GridLayout.generateCells(
  ///   width: 11,
  ///   language: catalanLanguage,
  ///   seed: 42,
  ///   targetHeight: 10,
  /// );
  /// ```
  static List<String> generateCells({
    required int width,
    required WordClockLanguage language,
    required int seed,
    int targetHeight = 10,
  }) {
    final constraintBuilder = ConstraintGridBuilder(
      width: width,
      height: targetHeight,
      language: language,
      seed: seed,
    );

    final result = constraintBuilder.build();
    if (result == null) {
      throw StateError(
        'Could not generate grid for ${language.id} with ${width}x$targetHeight. '
        'Try increasing height or width.',
      );
    }

    return result;
  }
}
