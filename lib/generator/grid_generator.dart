import 'dart:math';

import 'package:wordclock/generator/dependency_graph.dart';
import 'package:wordclock/generator/grid_layout.dart';
import 'package:wordclock/generator/topological_sort.dart';

import 'package:wordclock/logic/time_to_words.dart';

class GridGenerator {
  /// Generates a grid of characters for the word clock.
  /// returns the full string of letters.
  static String generate({
    required int width,
    int? seed,
    TimeToWords? language,
  }) {
    final Random random = seed != null ? Random(seed) : Random(0);
    final converter = language ?? EnglishTimeToWords();
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
      paddingAlphabet: converter.paddingChars,
    );
  }
}
