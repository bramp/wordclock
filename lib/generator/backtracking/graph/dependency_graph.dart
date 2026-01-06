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

  /// Get words sorted by priority (higher priority first)
  /// Returns unique words with their highest priority instance
  List<String> getWordsByPriority() {
    final Map<String, double> wordPriorities = {};
    for (final entry in nodes.entries) {
      final word = entry.key;
      final instances = entry.value;
      // Get max priority across all instances
      final maxPriority = instances
          .map((n) => n.priority)
          .reduce((a, b) => a > b ? a : b);
      wordPriorities[word] = maxPriority;
    }

    final words = wordPriorities.keys.toList();
    words.sort((a, b) => wordPriorities[b]!.compareTo(wordPriorities[a]!));
    return words;
  }

  /// Get all unique words
  Set<String> getUniqueWords() {
    return nodes.keys.toSet();
  }

  /// Get all nodes for a given word
  List<WordNode> getNodesForWord(String word) {
    return nodes[word] ?? [];
  }

  /// Get all phrases that contain [word]
  Set<String> getPhrasesContaining(String word) {
    final instances = nodes[word];
    if (instances == null) return {};

    final allPhrases = <String>{};
    for (final node in instances) {
      allPhrases.addAll(node.phrases);
    }
    return allPhrases;
  }

  /// Get the position(s) of [word] in [phrase]
  List<int> getPositionsInPhrase(String word, String phrase) {
    final phraseNodes = phrases[phrase];
    if (phraseNodes == null) return [];

    final instances = nodes[word];
    if (instances == null) return [];

    // Build set of nodes for this word
    final wordNodes = instances.toSet();

    final positions = <int>[];
    for (int i = 0; i < phraseNodes.length; i++) {
      if (wordNodes.contains(phraseNodes[i])) {
        positions.add(i);
      }
    }
    return positions;
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
