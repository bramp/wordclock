// ignore_for_file: avoid_print

import 'package:graphs/graphs.dart';
import 'package:wordclock/generator/backtracking/graph/dependency_graph.dart';
import 'package:wordclock/generator/backtracking/graph/word_node.dart';

/// Exports a [WordDependencyGraph] to DOT format for Graphviz visualization.
class WordGraphDotExporter {
  /// Exports the word dependency graph to DOT format.
  ///
  /// Creates a directed graph showing:
  /// - Nodes representing words (sized by frequency, colored by priority)
  /// - Edges showing word ordering dependencies
  /// - Topologically sorted so edges flow left-to-right
  ///
  /// Usage:
  /// ```bash
  /// dart run bin/grid_builder.dart -l EN --dot --algorithm backtracking > graph.dot
  /// dot -Tpng graph.dot -o graph.png
  /// ```
  static String export(WordDependencyGraph graph) {
    final sb = StringBuffer();
    sb.writeln('digraph WordDependencies {');
    sb.writeln('  rankdir=LR;');
    sb.writeln('  node [shape=box, style=filled];');
    sb.writeln('');

    // Perform topological sort to assign ranks
    final ranks = _topologicalRanks(graph);

    // Get all nodes in a flat list
    final allNodes = <WordNode>[];
    for (final instances in graph.nodes.values) {
      allNodes.addAll(instances);
    }

    // Build a map from node ID to node for quick lookup
    final Map<String, WordNode> nodeById = {};
    for (final node in allNodes) {
      nodeById[node.id] = node;
    }

    // Group nodes by rank for subgraph organization
    final Map<int, List<String>> nodesByRank = {};
    for (final entry in ranks.entries) {
      nodesByRank.putIfAbsent(entry.value, () => []).add(entry.key);
    }

    // Create nodes with visual properties, organized by rank
    final sortedRanks = nodesByRank.keys.toList()..sort();
    for (final rank in sortedRanks) {
      sb.writeln('  // Rank $rank');
      sb.writeln('  { rank=same;');

      for (final nodeId in nodesByRank[rank]!) {
        final node = nodeById[nodeId]!;

        // Size by length
        final fontSize = 12;

        final label = '${node.id}\\nlen=${node.cellCodes.length}';

        sb.writeln(
          '    "$nodeId" [label="$label", fontsize=$fontSize, fillcolor="#ffffff"];',
        );
      }

      sb.writeln('  }');
    }

    sb.writeln('');

    // Create edges
    for (final entry in graph.edges.entries) {
      final from = entry.key;
      final successors = entry.value;
      for (final to in successors) {
        sb.writeln('  "${from.id}" -> "${to.id}";');
      }
    }

    sb.writeln('}');
    return sb.toString();
  }

  /// Performs topological sort and assigns ranks to nodes.
  ///
  /// Returns a map from node ID to its rank (0-based, where rank 0 has no dependencies).
  /// Nodes with the same rank can be placed at the same horizontal position.
  ///
  /// Uses the graphs package for robust topological sorting with cycle detection.
  static Map<String, int> _topologicalRanks(WordDependencyGraph graph) {
    final Map<String, int> ranks = {};

    // Get all nodes flat list and map ID -> Node
    final allNodes = <WordNode>[];
    final nodeById = <String, WordNode>{};
    for (final instances in graph.nodes.values) {
      for (final node in instances) {
        allNodes.add(node);
        nodeById[node.id] = node;
      }
    }

    final allNodeIds = allNodes.map((n) => n.id).toList();

    // Use the graphs package to do topological sorting
    Iterable<String> successorsOf(String nodeId) {
      final node = nodeById[nodeId];
      if (node == null) return {};
      final successors = graph.edges[node] ?? {};
      return successors.map((n) => n.id);
    }

    try {
      // Get topological ordering
      final ordering = topologicalSort<String>(allNodeIds, successorsOf);

      // Assign ranks based on longest path from sources
      // Process nodes in topological order
      for (final nodeId in ordering) {
        // Find all predecessors and take max rank + 1
        int maxPredRank = -1;

        // This is inefficient (O(E)), but fine for graph export visualization
        for (final entry in graph.edges.entries) {
          final fromNode = entry.key;
          final successors = entry.value;
          // check if fromNode -> nodeId exists
          if (successors.any((n) => n.id == nodeId)) {
            final predId = fromNode.id;
            if (ranks.containsKey(predId)) {
              maxPredRank = maxPredRank > ranks[predId]!
                  ? maxPredRank
                  : ranks[predId]!;
            }
          }
        }

        ranks[nodeId] = maxPredRank + 1;
      }
    } catch (e) {
      // If topological sort fails (cycles), use strongly connected components
      print(
        'DEBUG: Topological sort failed (cycles detected), using fallback: $e',
      );

      // Fall back to assigning ranks based on in-degree
      final Map<String, int> inDegree = {};
      for (final nodeId in allNodeIds) {
        inDegree[nodeId] = 0;
      }
      for (final successors in graph.edges.values) {
        for (final successor in successors) {
          inDegree[successor.id] = (inDegree[successor.id] ?? 0) + 1;
        }
      }

      // Assign ranks: nodes with lower in-degree get lower ranks
      int currentRank = 0;
      final processed = <String>{};

      while (processed.length < allNodeIds.length) {
        // Find nodes with minimum in-degree among unprocessed
        final candidates = allNodeIds
            .where((n) => !processed.contains(n))
            .toList();

        if (candidates.isEmpty) break;

        // Assign same rank to all candidates with minimum in-degree
        int minInDegree = candidates
            .map((n) => inDegree[n]!)
            .reduce((a, b) => a < b ? a : b);
        final nodesAtRank = candidates
            .where((n) => inDegree[n] == minInDegree)
            .toList();

        for (final nodeId in nodesAtRank) {
          ranks[nodeId] = currentRank;
          processed.add(nodeId);

          // Decrement in-degree of successors
          final node = nodeById[nodeId];
          if (node != null) {
            final successors = graph.edges[node] ?? {};
            for (final succ in successors) {
              if (!processed.contains(succ.id)) {
                inDegree[succ.id] = inDegree[succ.id]! - 1;
              }
            }
          }
        }

        currentRank++;
      }
    }

    return ranks;
  }
}
