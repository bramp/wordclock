import 'package:wordclock/generator/greedy/graph_types.dart';

/// An exporter that converts a [Graph] into a DOT format string,
/// which can be visualized using Graphviz.
class DotExporter {
  /// Exports the given [graph] to a DOT string.
  ///
  /// The output includes:
  /// - Nodes grouped into clusters by their word.
  /// - Sequential edges within words.
  /// - Dependency edges between words.
  ///
  /// Example:
  /// ```dart
  /// final dot = DotExporter.export(graph);
  /// // Use 'dot -Tpng graph.dot -o graph.png' to visualize.
  /// ```
  static String export(Graph graph) {
    final sb = StringBuffer();
    sb.writeln('digraph G {');
    sb.writeln('  rankdir=LR;');
    sb.writeln('  node [shape=box];');

    // Group nodes by word to make it look more like a railroad diagram
    final Map<String, List<Node>> words = {};
    for (final node in graph.keys) {
      words.putIfAbsent(node.word, () => []).add(node);
    }

    // Sort nodes within each word by their index (if we had it, but Node has char and word)
    // Wait, Node in graph_types.dart has char, word, and index.

    for (final entry in words.entries) {
      final word = entry.key;
      final nodes = entry.value
        ..sort((a, b) => a.charIndex.compareTo(b.charIndex));

      sb.writeln('  subgraph "cluster_$word" {');
      sb.writeln('    label="$word";');
      for (int i = 0; i < nodes.length; i++) {
        final node = nodes[i];
        final nodeId = _nodeId(node);
        sb.writeln('    $nodeId [label="${node.char}"];');
        if (i > 0) {
          final prevId = _nodeId(nodes[i - 1]);
          sb.writeln('    $prevId -> $nodeId;');
        }
      }
      sb.writeln('  }');
    }

    // Add edges between words
    for (final entry in graph.entries) {
      final source = entry.key;
      for (final target in entry.value) {
        // Only add edges that are NOT internal to a word (those are handled above)
        if (source.word != target.word ||
            target.charIndex != source.charIndex + 1) {
          sb.writeln('  ${_nodeId(source)} -> ${_nodeId(target)};');
        }
      }
    }

    sb.writeln('}');
    return sb.toString();
  }

  /// Generates a unique identifier for a [Node] to be used in the DOT file.
  ///
  /// Uses the node's hash code to ensure uniqueness while remaining a valid
  /// DOT identifier.
  static String _nodeId(Node node) {
    return 'n${node.hashCode.toString().replaceAll('-', 'n')}';
  }
}
