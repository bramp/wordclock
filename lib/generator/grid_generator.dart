import 'dart:math';

import 'package:wordclock/generator/dependency_graph.dart';
import 'package:wordclock/generator/grid_layout.dart';
import 'package:wordclock/generator/topological_sort.dart';

class GridGenerator {
  /// Generates a grid of characters for the word clock.
  /// returns the full string of letters.
  static String generate({required int width, int? seed}) {
    final Random random = seed != null ? Random(seed) : Random(0);
    final graph = DependencyGraphBuilder.build();
    final sortedNodes = TopologicalSorter.sort(
      graph,
      random: seed != null ? random : null,
    );
    return GridLayout.generateString(width, sortedNodes, graph, random);
  }
}
