import 'dart:math';
import 'package:wordclock/generator/greedy/graph_types.dart';

/// A utility for performing a topological sort on a [Graph].
///
/// The sort determines a linear ordering of nodes such that for every directed
/// edge $u \to v$, node $u$ comes before $v$ in the ordering.
class TopologicalSorter {
  /// Performs a topological sort on the given [graph].
  ///
  /// This implementation uses Kahn's algorithm with a greedy heuristic:
  /// when multiple nodes are "ready" (have an in-degree of 0), it prioritizes
  /// the children of the node just processed. This helps keep characters of
  /// the same word together in the final grid.
  ///
  /// Parameters:
  /// - [graph]: The dependency graph to sort.
  /// - [random]: Optional random number generator for shuffling ready nodes,
  ///   allowing for different valid grid layouts from the same graph.
  ///
  /// Returns a list of [Node]s in topological order.
  ///
  /// Throws an [Exception] if a cycle is detected in the graph.
  ///
  /// Example:
  /// ```dart
  /// final sortedNodes = TopologicalSorter.sort(graph, random: Random(42));
  /// ```
  static List<Node> sort(Graph graph, {Random? random}) {
    final Map<Node, int> inDegree = {};
    for (var node in graph.keys) {
      inDegree[node] = 0;
    }
    for (var dests in graph.values) {
      for (var dest in dests) {
        inDegree[dest] = (inDegree[dest] ?? 0) + 1;
      }
    }

    final List<Node> orderedResult = [];

    // Current Layer: All nodes with In-Degree 0
    final List<Node> readyNodes = [];
    inDegree.forEach((node, degree) {
      if (degree == 0) readyNodes.add(node);
    });

    // Sort/Shuffle initial ready nodes
    readyNodes.sort((a, b) => a.word.compareTo(b.word));
    if (random != null) {
      readyNodes.shuffle(random);
    }

    while (readyNodes.isNotEmpty) {
      // 2. Pick the first ready node
      final Node current = readyNodes.removeAt(0);
      orderedResult.add(current);

      // 3. Process children to find NEXT Layer
      final List<Node> newlyReady = [];
      final dests = graph[current];
      if (dests != null) {
        for (final dest in dests) {
          inDegree[dest] = inDegree[dest]! - 1;
          if (inDegree[dest] == 0) {
            newlyReady.add(dest);
          }
        }
      }

      // 4. To be greedy, we prioritize newly ready nodes (children of the current node)
      // This keeps sequences (like words) together.
      if (newlyReady.isNotEmpty) {
        newlyReady.sort((a, b) {
          int cmp = a.word.compareTo(b.word);
          if (cmp != 0) return cmp;
          return a.index.compareTo(b.index);
        });
        if (random != null) {
          newlyReady.shuffle(random);
        }
        // TODO Should readyNodes also be shuffled?
        readyNodes.insertAll(0, newlyReady);
      }
    }

    if (orderedResult.length != graph.length) {
      throw Exception("Graph sequence cycle detected during sort.");
    }
    return orderedResult;
  }
}
