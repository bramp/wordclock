import 'package:wordclock/generator/backtracking/graph/word_node.dart';
import 'package:wordclock/generator/backtracking/graph/cell_codec.dart';
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

  /// Inverted edges (parents): node ID → set of predecessor node IDs
  final Map<WordNode, Set<WordNode>> inEdges;

  /// All phrases: phrase text -> ordered list of nodes
  final Map<String, List<WordNode>> phrases;

  /// Language this graph was built for
  final WordClockLanguage language;

  /// Cell codec for encoding/decoding cells to integers
  final CellCodec codec;

  WordDependencyGraph({
    required this.nodes,
    required this.edges,
    required this.inEdges,
    required this.phrases,
    required this.language,
    required this.codec,
  });

  /// All word nodes in the graph
  List<WordNode> get allNodes => nodes.values.expand((i) => i).toList();

  /// Compute topological ranks for all word instances in this graph.
  /// Ranks represent the longest path from a root node to this node.
  Map<WordNode, int> computeRanks() {
    final inDegree = <WordNode, int>{};
    final nodes = allNodes;

    for (final node in nodes) {
      inDegree[node] = 0;
    }

    for (final entry in edges.entries) {
      for (final succ in entry.value) {
        inDegree[succ] = (inDegree[succ] ?? 0) + 1;
      }
    }

    final ranks = <WordNode, int>{};
    var queue = inDegree.entries
        .where((e) => e.value == 0)
        .map((e) => e.key)
        .toList();

    // Sort initial queue for deterministic results
    queue.sort((a, b) => a.id.compareTo(b.id));

    int currentRank = 0;
    while (queue.isNotEmpty) {
      final nextQueue = <WordNode>[];
      for (final node in queue) {
        ranks[node] = currentRank;
        for (final succ in edges[node] ?? {}) {
          inDegree[succ] = inDegree[succ]! - 1;
          if (inDegree[succ] == 0) nextQueue.add(succ);
        }
      }
      queue = nextQueue;
      queue.sort((a, b) => a.id.compareTo(b.id));
      currentRank++;
    }

    // Nodes in cycles might not be in ranks; assign them a rank
    for (final node in nodes) {
      if (!ranks.containsKey(node)) ranks[node] = currentRank;
    }
    return ranks;
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
