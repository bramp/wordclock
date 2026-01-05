// ignore_for_file: avoid_print

import 'package:wordclock/generator/utils/word_clock_utils.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';

/// Represents a word node in the word-level dependency graph.
///
/// Each node represents a word, potentially with an instance number if the word
/// appears multiple times in the same phrase (e.g., "FIVE TO FIVE").
class WordNode {
  /// The actual word text (e.g., "FIVE", "OCLOCK")
  final String word;

  /// Instance number (0 for first occurrence, 1 for second, etc.)
  /// Only non-zero when word appears multiple times in the same phrase
  final int instance;

  /// The word split into cells (usually characters, but can be multi-char)
  final List<String> cells;

  /// Which phrases use this word node
  final Set<String> phrases;

  /// Unique identifier for this node (e.g., "FIVE", "FIVE#1", "FIVE#2")
  String get id => instance == 0 ? word : '$word#$instance';

  /// Frequency: how many phrases use this word node
  int get frequency => phrases.length;

  /// Priority score for placement order
  double get priority => frequency * 10.0 + (cells.length / 10.0);

  WordNode({
    required this.word,
    required this.instance,
    required this.cells,
    required this.phrases,
  });

  @override
  String toString() => 'WordNode($id, freq=$frequency, len=${cells.length})';
}

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
  /// Node IDs are computed as word or word#instance
  final Map<String, Set<String>> edges;

  /// All phrases: phrase text -> ordered list of node IDs
  final Map<String, List<String>> phrases;

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

  /// Get all node IDs for a given word
  List<String> getNodeIdsForWord(String word) {
    final instances = nodes[word];
    if (instances == null) return [];
    return instances.map((n) => n.id).toList();
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
    final phraseNodeIds = phrases[phrase];
    if (phraseNodeIds == null) return [];

    final instances = nodes[word];
    if (instances == null) return [];

    // Build set of node IDs for this word
    final wordNodeIds = instances.map((n) => n.id).toSet();

    final positions = <int>[];
    for (int i = 0; i < phraseNodeIds.length; i++) {
      if (wordNodeIds.contains(phraseNodeIds[i])) {
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

/// Builds a word-level dependency graph from a language.
class WordDependencyGraphBuilder {
  /// Builds a [WordDependencyGraph] for the given [language].
  ///
  /// Creates separate node instances for words that appear multiple times.
  /// For example, in "IT IS FIVE PAST TEN TO FIVE":
  /// - First FIVE uses FIVE#0
  /// - Second FIVE uses FIVE#1
  ///
  /// Nodes are reused across phrases when they don't create conflicting edges.
  static WordDependencyGraph build({required WordClockLanguage language}) {
    final Map<String, List<WordNode>> nodes = {};
    final Map<String, Set<String>> edges = {};
    final Map<String, List<String>> phrases = {};
    final Set<String> processedPhrases = {};

    // Helper to check if adding edge from->to would create a cycle
    bool wouldCreateCycle(String fromId, String toId) {
      // Check if there's already a path from toId to fromId
      // If so, adding fromId->toId would create a cycle
      final visited = <String>{};
      final queue = <String>[toId];

      while (queue.isNotEmpty) {
        final current = queue.removeAt(0);
        if (current == fromId) {
          return true; // Found path from toId to fromId
        }

        if (visited.contains(current)) continue;
        visited.add(current);

        final successors = edges[current] ?? {};
        queue.addAll(successors);
      }

      return false;
    }

    // 1. Process all phrases
    WordClockUtils.forEachTime(language, (time, phraseText) {
      final words = language.tokenize(phraseText);
      if (words.isEmpty) return;

      if (processedPhrases.contains(phraseText)) return;
      processedPhrases.add(phraseText);

      final phraseNodeIds = <String>[];
      // Track which instance we should use for each word we've seen in this phrase
      final Map<String, int> wordInstanceInPhrase = {};

      // Process each word in the phrase
      for (int i = 0; i < words.length; i++) {
        final word = words[i];
        final predNodeId = i > 0 ? phraseNodeIds[i - 1] : null;

        // Check if this word appeared before in this phrase
        final minInstance = wordInstanceInPhrase[word] ?? 0;
        wordInstanceInPhrase[word] = minInstance + 1;

        // Try to find/create a node instance that doesn't create cycles
        WordNode? selectedNode;
        for (int tryInstance = minInstance; tryInstance <= 100; tryInstance++) {
          final nodeId = tryInstance == 0 ? word : '$word#$tryInstance';

          // Check if this instance already exists
          final instances = nodes[word] ?? [];
          WordNode? existingNode;
          for (final node in instances) {
            if (node.instance == tryInstance) {
              existingNode = node;
              break;
            }
          }

          // Check if using this node would create a cycle
          if (predNodeId != null && wouldCreateCycle(predNodeId, nodeId)) {
            // This would create a cycle, try next instance
            continue;
          }

          // This instance works!
          if (existingNode != null) {
            // Reuse existing node
            existingNode.phrases.add(phraseText);
            selectedNode = existingNode;
          } else {
            // Create new instance
            final cells = WordGrid.splitIntoCells(word);
            final newNode = WordNode(
              word: word,
              instance: tryInstance,
              cells: cells,
              phrases: {phraseText},
            );
            instances.add(newNode);
            nodes[word] = instances;
            selectedNode = newNode;
          }
          break;
        }

        if (selectedNode == null) {
          throw StateError('Could not find valid node instance for $word');
        }

        phraseNodeIds.add(selectedNode.id);
      }

      // Now add edges between consecutive nodes in this phrase
      for (int i = 0; i < phraseNodeIds.length - 1; i++) {
        final fromNodeId = phraseNodeIds[i];
        final toNodeId = phraseNodeIds[i + 1];
        edges.putIfAbsent(fromNodeId, () => {});
        edges[fromNodeId]!.add(toNodeId);
      }

      phrases[phraseText] = phraseNodeIds;
    });

    return WordDependencyGraph(
      nodes: nodes,
      edges: edges,
      phrases: phrases,
      language: language,
    );
  }

  /// Debug: Print graph statistics
  static void printStatistics(WordDependencyGraph graph) {
    print(graph);
    print('\nTop 10 nodes by priority:');
    final sortedNodes = graph.getNodesByPriority().take(10);
    for (final node in sortedNodes) {
      print(
        '  ${node.id}: word=${node.word}, priority=${node.priority.toStringAsFixed(2)}, '
        'freq=${node.frequency}, len=${node.cells.length}',
      );
    }

    print('\nSample phrases:');
    int count = 0;
    for (final entry in graph.phrases.entries) {
      if (count++ >= 5) break;
      print('  "${entry.key}" -> ${entry.value}');
    }
  }
}
