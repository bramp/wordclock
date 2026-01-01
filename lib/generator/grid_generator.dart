import 'dart:math';

import 'package:wordclock/generator/dependency_graph.dart';
import 'package:wordclock/generator/grid_layout.dart';
import 'package:wordclock/generator/topological_sort.dart';

import 'package:wordclock/languages/language.dart';
import 'package:wordclock/languages/english.dart';

class GridGenerator {
  /// Generates a grid of characters for the word clock.
  /// returns the full string of letters.
  static String generate({
    required int width,
    int? seed,
    WordClockLanguage? language,
  }) {
    final Random random = seed != null ? Random(seed) : Random(0);
    final lang = language ?? EnglishLanguage();
    final converter = lang.timeToWords;
    final padding = lang.paddingAlphabet;

    final graph = DependencyGraphBuilder.build(converter: converter);
    final sortedNodes = TopologicalSorter.sort(
      graph,
      random: seed != null ? random : null,
    );
    return GridLayout.generateString(
      width,
      sortedNodes,
      graph,
      random,
      paddingAlphabet: padding,
    );
  }
}
