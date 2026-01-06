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
  static WordDependencyGraph build({required WordClockLanguage language}) {
    final Map<String, List<WordNode>> nodes = {};
    final Map<WordNode, Set<WordNode>> edges = {};
    final Map<WordNode, Set<WordNode>> inEdges = {};
    final Map<String, List<WordNode>> phrases = {};
    final Set<String> processedPhrases = {};

    // Helper to check if adding edge from->to would create a cycle
    bool wouldCreateCycle(WordNode fromNode, WordNode toNode) {
      // Check if there's already a path from toNode to fromNode
      // If so, adding fromNode->toNode would create a cycle
      final visited = <WordNode>{};
      final queue = <WordNode>[toNode];

      while (queue.isNotEmpty) {
        final current = queue.removeAt(0);
        if (current == fromNode) {
          return true; // Found path from toNode to fromNode
        }

        if (visited.contains(current)) continue;
        visited.add(current);

        final successors = edges[current] ?? {};
        queue.addAll(successors);
      }

      return false;
    }

    // 1. Collect all unique phrases first
    
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

    // 2. Sort phrases by length (shortest first)
    // This optimization reduces the number of node instances needed.
    // By processing short phrases first (e.g., "JE PĚT" before "JE JEDNA DVACET PĚT"),
    // we establish base nodes that can be reused without creating cycles.
    allPhrases.sort((a, b) => a.length.compareTo(b.length));

    // 3. Process all phrases in optimized order
    for (final phraseText in allPhrases) {
      final words = language.tokenize(phraseText);
      if (words.isEmpty) continue;

      final phraseNodes = <WordNode>[];

      // Process each word in the phrase
      for (int i = 0; i < words.length; i++) {
        final word = words[i];
        final predNode = i > 0 ? phraseNodes[i - 1] : null;

        // Try to find/create a node instance that doesn't create cycles.
        WordNode? selectedNode;
        final instances = nodes[word] ??= [];

        // Try to find an existing instance that doesn't create a cycle.
        selectedNode = null;
        for (final node in instances) {
          if (predNode == null || !wouldCreateCycle(predNode, node)) {
            selectedNode = node;
            break;
          }
        }

        if (selectedNode != null) {
          // Reuse existing node
          selectedNode.phrases.add(phraseText);
        } else {
          // Create new instance
          selectedNode = WordNode(
            word: word,
            instance: instances.length,
            cells: WordGrid.splitIntoCells(word),
            phrases: {phraseText},
          );
          instances.add(selectedNode);
        }

        phraseNodes.add(selectedNode);

        // Add edge from the previous node to the selected node
        if (predNode != null) {
          edges.putIfAbsent(predNode, () => {}).add(selectedNode);
          inEdges.putIfAbsent(selectedNode, () => {}).add(predNode);
        }
      }

      phrases[phraseText] = phraseNodes;
    }

    // Check if we achieved optimal node count
    _warnIfSuboptimal(nodes, maxOccurrences, optimalNodeCount);

    return WordDependencyGraph(
      nodes: nodes,
      edges: edges,
      inEdges: inEdges,
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
