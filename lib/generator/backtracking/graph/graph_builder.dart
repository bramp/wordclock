// ignore_for_file: avoid_print
// TODO Remove the prints

import 'package:wordclock/generator/backtracking/graph/dependency_graph.dart';
import 'package:wordclock/generator/backtracking/graph/word_node.dart';
import 'package:wordclock/generator/utils/word_clock_utils.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';

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
  /// Tries multiple phrase orderings and picks the one with fewest nodes.
  static WordDependencyGraph build({required WordClockLanguage language}) {
    // 1. Collect all unique phrases first
    final processedPhrases = <String>{};
    WordClockUtils.forEachTime(language, (time, phraseText) {
      if (!processedPhrases.contains(phraseText)) {
        processedPhrases.add(phraseText);
      }
    });

    final allPhrases = processedPhrases.toList();

    // Calculate the optimal (minimum) number of nodes needed for these phrases
    final maxOccurrences = _calculateMaxWordOccurrences(allPhrases, language);
    final optimalNodeCount = maxOccurrences.values.fold(
      0,
      (sum, count) => sum + count,
    );

    // 2. Try multiple phrase orderings and pick the best
    // Different languages benefit from different orderings due to cycle constraints
    final orderings = <String, List<String>>{
      'length_asc': List.from(allPhrases)
        ..sort((a, b) => a.length.compareTo(b.length)),
      'length_desc': List.from(allPhrases)
        ..sort((a, b) => b.length.compareTo(a.length)),
    };

    WordDependencyGraph? bestGraph;
    var bestNodeCount = 999999;

    for (final entry in orderings.entries) {
      final graph = _buildWithOrdering(entry.value, language);
      final nodeCount = graph.nodes.values.fold(0, (s, l) => s + l.length);

      if (nodeCount < bestNodeCount) {
        bestNodeCount = nodeCount;
        bestGraph = graph;
      }

      // Early exit if we achieved optimal
      if (nodeCount == optimalNodeCount) break;
    }

    // Check if we achieved optimal node count
    _warnIfSuboptimal(bestGraph!.nodes, maxOccurrences, optimalNodeCount);

    return bestGraph;
  }

  /// Builds a graph with phrases processed in the given order.
  static WordDependencyGraph _buildWithOrdering(
    List<String> orderedPhrases,
    WordClockLanguage language,
  ) {
    final Map<String, List<WordNode>> nodes = {};
    final Map<WordNode, Set<WordNode>> edges = {};
    final Map<WordNode, Set<WordNode>> inEdges = {};
    final Map<String, List<WordNode>> phrases = {};

    // Helper to check if adding edge from->to would create a cycle
    bool wouldCreateCycle(WordNode fromNode, WordNode toNode) {
      final visited = <WordNode>{};
      final queue = <WordNode>[toNode];

      while (queue.isNotEmpty) {
        final current = queue.removeAt(0);
        if (current == fromNode) {
          return true;
        }

        if (visited.contains(current)) continue;
        visited.add(current);

        final successors = edges[current] ?? {};
        queue.addAll(successors);
      }

      return false;
    }

    // Process all phrases in the given order
    for (final phraseText in orderedPhrases) {
      final words = language.tokenize(phraseText);
      if (words.isEmpty) continue;

      final phraseNodes = <WordNode>[];

      for (int i = 0; i < words.length; i++) {
        final word = words[i];
        final predNode = i > 0 ? phraseNodes[i - 1] : null;

        WordNode? selectedNode;
        final instances = nodes[word] ??= [];

        // Try to find an existing instance that doesn't create a cycle
        for (final node in instances) {
          if (predNode == null || !wouldCreateCycle(predNode, node)) {
            selectedNode = node;
            break;
          }
        }

        if (selectedNode != null) {
          selectedNode.phrases.add(phraseText);
        } else {
          selectedNode = WordNode(
            word: word,
            instance: instances.length,
            cells: WordGrid.splitIntoCells(word),
            phrases: {phraseText},
          );
          instances.add(selectedNode);
        }

        phraseNodes.add(selectedNode);

        if (predNode != null) {
          edges.putIfAbsent(predNode, () => {}).add(selectedNode);
          inEdges.putIfAbsent(selectedNode, () => {}).add(predNode);
        }
      }

      phrases[phraseText] = phraseNodes;
    }

    // Populate predecessorTokens for each node
    _populatePredecessorTokens(phrases, language);

    return WordDependencyGraph(
      nodes: nodes,
      edges: edges,
      inEdges: inEdges,
      phrases: phrases,
      language: language,
    );
  }

  /// Populates the predecessorTokens field for each node based on phrases.
  static void _populatePredecessorTokens(
    Map<String, List<WordNode>> phrases,
    WordClockLanguage language,
  ) {
    for (final entry in phrases.entries) {
      final phraseText = entry.key;
      final phraseNodes = entry.value;
      final tokens = language.tokenize(phraseText);

      for (int i = 0; i < phraseNodes.length; i++) {
        final node = phraseNodes[i];
        // Predecessors are all tokens before this node's position
        final predecessors = tokens.sublist(0, i);

        // Check if this predecessor list already exists (by value)
        bool alreadyExists = false;
        for (final existing in node.predecessorTokens) {
          if (_listEquals(existing, predecessors)) {
            alreadyExists = true;
            break;
          }
        }

        if (!alreadyExists) {
          node.predecessorTokens.add(predecessors);
        }
      }
    }
  }

  /// Compares two lists for value equality.
  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
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
      final nodeIds = entry.value.map((n) => n.id).toList();
      print('  "${entry.key}" -> $nodeIds');
    }
  }

  /// Calculates the maximum number of times each word appears in any single phrase.
  /// This determines the minimum number of node instances needed for each word.
  static Map<String, int> _calculateMaxWordOccurrences(
    List<String> phrases,
    WordClockLanguage language,
  ) {
    final maxOccurrences = <String, int>{};
    for (final phraseText in phrases) {
      final words = language.tokenize(phraseText);
      final counts = <String, int>{};
      for (final word in words) {
        counts[word] = (counts[word] ?? 0) + 1;
      }
      for (final entry in counts.entries) {
        final current = maxOccurrences[entry.key] ?? 0;
        if (entry.value > current) {
          maxOccurrences[entry.key] = entry.value;
        }
      }
    }
    return maxOccurrences;
  }

  /// Prints a warning if the graph has more nodes than the optimal count.
  static void _warnIfSuboptimal(
    Map<String, List<WordNode>> nodes,
    Map<String, int> maxOccurrences,
    int optimalNodeCount,
  ) {
    final actualNodeCount = nodes.values.fold(
      0,
      (sum, list) => sum + list.length,
    );
    if (actualNodeCount > optimalNodeCount) {
      print(
        'WARNING: Graph has $actualNodeCount nodes, '
        'but optimal is $optimalNodeCount',
      );
      print('  Extra instances created:');
      for (final entry in nodes.entries) {
        final word = entry.key;
        final instances = entry.value;
        final optimal = maxOccurrences[word] ?? 1;
        if (instances.length > optimal) {
          print('    $word: ${instances.length} nodes (optimal: $optimal)');
        }
      }
    }
  }
}
