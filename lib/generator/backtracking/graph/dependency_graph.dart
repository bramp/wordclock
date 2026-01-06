import 'package:wordclock/generator/backtracking/graph/word_node.dart';
import 'package:wordclock/languages/language.dart';

/// A word-level dependency graph for the word clock.
///
/// Unlike the character-level DAG in dependency_graph.dart, this represents
/// dependencies between entire words in phrases. Words appearing in different
/// contexts are represented as separate nodes to avoid cycles.
class WordDependencyGraph {
  /// All word nodes grouped by word: word → list of instances
  /// e.g., nodes["FIVE"] returns [FIVE (instance 0), FIVE#1 (instance 1)]
  final Map<String, List<WordNode>> nodes;

  /// Edges representing word ordering: node ID → set of successor node IDs
  final Map<WordNode, Set<WordNode>> edges;

  /// All phrases: phrase text -> ordered list of nodes
  final Map<String, List<WordNode>> phrases;

  /// Language this graph was built for
  final WordClockLanguage language;

  WordDependencyGraph({
    required this.nodes,
    required this.edges,
    required this.phrases,
    required this.language,
  });

  /// Get nodes sorted by priority (higher priority first)
  List<WordNode> getNodesByPriority() {
    final allNodes = <WordNode>[];
    for (final instances in nodes.values) {
      allNodes.addAll(instances);
    }
    allNodes.sort((a, b) => b.priority.compareTo(a.priority));
    return allNodes;
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('WordDependencyGraph:');
    int totalNodes = 0;
    for (final instances in nodes.values) {
      totalNodes += instances.length;
    }
    buffer.writeln('  ${nodes.length} unique words ($totalNodes total nodes)');
    buffer.writeln('  ${phrases.length} phrases');

    int totalEdges = 0;
    for (final successors in edges.values) {
      totalEdges += successors.length;
    }
    buffer.writeln('  $totalEdges dependencies');

    return buffer.toString();
  }
}
