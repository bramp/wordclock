import 'dart:math';
import 'package:wordclock/generator/graph_types.dart';

class TopologicalSorter {
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
        readyNodes.insertAll(0, newlyReady);
      }
    }

    if (orderedResult.length != graph.length) {
      throw Exception("Graph sequence cycle detected during sort.");
    }
    return orderedResult;
  }
}
