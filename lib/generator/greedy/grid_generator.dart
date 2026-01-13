import 'dart:math';

import 'package:wordclock/generator/greedy/dependency_graph.dart';
import 'package:wordclock/generator/greedy/grid_layout.dart';
import 'package:wordclock/generator/greedy/topological_sort.dart';

import 'package:wordclock/languages/language.dart';
import 'package:wordclock/languages/all.dart';

/// A high-level generator that orchestrates the creation of a word clock grid.
class GridGenerator {
  /// Generates a list of characters (cells) for a word clock grid.
  ///
  /// The generation process follows these steps:
  /// 1. Builds a dependency graph of all words/phrases in the [language].
  /// 2. Performs a topological sort on the graph to determine a valid linear order.
  /// 3. Uses [GridLayout] to arrange these nodes into a grid of the specified [width].
  /// 4. Fills any gaps with characters from the language's padding alphabet.
  ///
  /// Parameters:
  /// - [width]: The fixed width of the grid.
  /// - [seed]: Optional seed for random number generation (ensures reproducibility).
  /// - [language]: The language logic to use (defaults to English).
  /// - [targetHeight]: Optional target height for the grid.
  ///
  /// Example:
  /// ```dart
  /// final cells = GridGenerator.generate(
  ///   width: 11,
  ///   language: English(),
  ///   seed: 42,
  /// );
  /// ```
  static ({List<String> cells, List<RawPlacement> placements}) generate({
    required int width,
    int? seed,
    WordClockLanguage? language,
    int targetHeight = 0,
  }) {
    final Random random = seed != null ? Random(seed) : Random(0);
    final lang = language ?? WordClockLanguages.byId['en']!;
    final padding = lang.defaultGridRef!.paddingAlphabet;

    // 1. Build Dependency Graph
    final graph = DependencyGraphBuilder.build(language: lang);
    final sortedNodes = TopologicalSorter.sort(
      graph,
      random: seed != null ? random : null,
    );

    if (sortedNodes.isEmpty) {
      return (
        cells: List.filled(width * targetHeight, ' '),
        placements: const [],
      );
    }

    return GridLayout.generateCells(
      width,
      sortedNodes,
      graph,
      random,
      paddingAlphabet: padding,
      requiresPadding: lang.requiresPadding,
      targetHeight: targetHeight,
    );
  }
}
