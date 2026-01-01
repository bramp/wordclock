import 'dart:math';
import 'package:wordclock/generator/graph_types.dart';

class TopologicalSorter {
  static List<Node> sort(Graph graph, {Random? random}) {
    // 1. Calculate 'Level' for each node using Kahn's algorithm.
    // Level = Length of longest path from any source to this node.
    // This ensures that if A -> B, Level(B) > Level(A).
    // So sorting by Level guarantees Topological Order.

    final Map<Node, int> inDegree = {};
    for (var node in graph.keys) {
      inDegree[node] = 0;
    }
    for (var edges in graph.values) {
      for (var neighbor in edges) {
        inDegree[neighbor] = (inDegree[neighbor] ?? 0) + 1;
      }
    }

    final List<Node> orderedResult = [];

    // Current Layer: All nodes with In-Degree 0
    List<Node> currentLayer = [];
    inDegree.forEach((node, degree) {
      if (degree == 0) currentLayer.add(node);
    });

    while (currentLayer.isNotEmpty) {
      // 1. Shuffle CURRENT Layer
      // Since these nodes have no dependencies among themselves (all in-degree 0 at this step),
      // and no remaining dependencies on unvisited nodes, their relative order DOES NOT MATTER.
      currentLayer.sort((a, b) => a.word.compareTo(b.word)); // Deterministic
      if (random != null) {
        currentLayer.shuffle(random);
      }

      // 2. Add to result
      orderedResult.addAll(currentLayer);

      // 3. Process children to find NEXT Layer
      final List<Node> nextLayer = [];
      for (final node in currentLayer) {
        final neighbors = graph[node];
        if (neighbors != null) {
          for (final neighbor in neighbors) {
            inDegree[neighbor] = inDegree[neighbor]! - 1;
            if (inDegree[neighbor] == 0) nextLayer.add(neighbor);
          }
        }
      }
      currentLayer = nextLayer;
    }

    if (orderedResult.length != graph.length) {
      throw Exception("Graph sequence cycle detected during sort.");
    }
    return orderedResult;
  }
}
