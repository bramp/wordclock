import 'dart:math';

import 'package:wordclock/generator/dependency_graph.dart';
import 'package:wordclock/generator/grid_layout.dart';
import 'package:wordclock/generator/topological_sort.dart';

import 'package:wordclock/languages/language.dart';
import 'package:wordclock/languages/all.dart';

class GridGenerator {
  /// Generates a grid of characters for the word clock.
  /// returns the full string of letters.
  static String generate({
    required int width,
    int? seed,
    WordClockLanguage? language,
  }) {
    final Random random = seed != null ? Random(seed) : Random(0);
    final lang = language ?? WordClockLanguages.byId['en']!;
    final padding = lang.paddingAlphabet;

    // 1. Build Dependency Graph
    final graph = DependencyGraphBuilder.build(language: lang);
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
