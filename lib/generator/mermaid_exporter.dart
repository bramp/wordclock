import 'package:wordclock/generator/graph_types.dart';

class MermaidExporter {
  static String export(Graph graph) {
    final sb = StringBuffer();
    sb.writeln('graph LR');

    // To keep it readable, we'll group by words
    final Map<String, List<Node>> words = {};
    for (final node in graph.keys) {
      words.putIfAbsent(node.word, () => []).add(node);
    }

    for (final entry in words.entries) {
      final word = entry.key;
      final nodes = entry.value
        ..sort((a, b) => a.charIndex.compareTo(b.charIndex));

      final sanitizedWord = word
          .replaceAll(' ', '_')
          .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
      sb.writeln('  subgraph $sanitizedWord ["$word"]');
      for (int i = 0; i < nodes.length; i++) {
        final node = nodes[i];
        final nodeId = _nodeId(node);
        sb.writeln('    $nodeId["${node.char}"]');
        if (i > 0) {
          final prevId = _nodeId(nodes[i - 1]);
          sb.writeln('    $prevId --> $nodeId');
        }
      }
      sb.writeln('  end');
    }

    // Add edges between words
    for (final entry in graph.entries) {
      final source = entry.key;
      for (final target in entry.value) {
        if (source.word != target.word ||
            target.charIndex != source.charIndex + 1) {
          sb.writeln('  ${_nodeId(source)} --> ${_nodeId(target)}');
        }
      }
    }

    return sb.toString();
  }

  static String _nodeId(Node node) {
    // Mermaid IDs can't have certain characters, and should be unique
    return 'n${node.hashCode.toString().replaceAll('-', 'n')}';
  }
}
