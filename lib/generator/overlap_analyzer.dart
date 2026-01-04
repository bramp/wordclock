import 'package:wordclock/generator/graph_types.dart';

/// Analyzes the dependency graph to find opportunities for physical cell overlap.
class OverlapAnalyzer {
  /// Identifies groups of nodes that can share the same physical cell position.
  ///
  /// Returns a map from representative node to all equivalent nodes.
  /// Nodes are considered equivalent if they:
  /// 1. Have the same character
  /// 2. Are not in a dependency relationship (one doesn't come before/after the other)
  /// 3. Appear in non-overlapping time phrases
  static Map<Node, Set<Node>> findOverlapGroups(
    Graph graph,
    List<Node> sortedNodes,
  ) {
    // Group nodes by character
    final nodesByChar = <String, List<Node>>{};
    for (final node in sortedNodes) {
      nodesByChar.putIfAbsent(node.char, () => []).add(node);
    }

    final Map<Node, Set<Node>> overlapGroups = {};

    // For each character, try to merge nodes that don't have dependencies
    for (final entry in nodesByChar.entries) {
      final nodes = entry.value;
      if (nodes.length <= 1) continue;

      // Try to merge nodes that aren't in each other's dependency chain
      for (int i = 0; i < nodes.length; i++) {
        for (int j = i + 1; j < nodes.length; j++) {
          final node1 = nodes[i];
          final node2 = nodes[j];

          // Check if there's a path from node1 to node2 or vice versa
          if (!_hasPath(graph, node1, node2) &&
              !_hasPath(graph, node2, node1)) {
            // These nodes can potentially share a cell
            final representative = overlapGroups.keys.firstWhere(
              (k) => k == node1 || overlapGroups[k]!.contains(node1),
              orElse: () => node1,
            );
            overlapGroups.putIfAbsent(representative, () => {representative});
            overlapGroups[representative]!.add(node2);
          }
        }
      }
    }

    return overlapGroups;
  }

  static bool _hasPath(Graph graph, Node start, Node target) {
    final visited = <Node>{};
    final queue = <Node>[start];

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      if (current == target) return true;
      if (!visited.add(current)) continue;

      final neighbors = graph[current];
      if (neighbors != null) {
        queue.addAll(neighbors);
      }
    }

    return false;
  }
}
