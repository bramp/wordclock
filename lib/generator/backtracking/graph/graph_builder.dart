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

    // 1. Process all phrases
    WordClockUtils.forEachTime(language, (time, phraseText) {
      final words = language.tokenize(phraseText);
      if (words.isEmpty) return;

      if (processedPhrases.contains(phraseText)) return;
      processedPhrases.add(phraseText);

      final phraseNodes = <WordNode>[];
      // Track which instance we should use for each word we've seen in this phrase
      final Map<String, int> wordInstanceInPhrase = {};

      // Process each word in the phrase
      for (int i = 0; i < words.length; i++) {
        final word = words[i];
        final predNode = i > 0 ? phraseNodes[i - 1] : null;

        // Check if this word appeared before in this phrase
        final minInstance = wordInstanceInPhrase[word] ?? 0;
        wordInstanceInPhrase[word] = minInstance + 1;

        // Try to find/create a node instance that doesn't create cycles
        WordNode? selectedNode;
        for (int tryInstance = minInstance; tryInstance <= 100; tryInstance++) {
          // Check if this instance already exists
          final instances = nodes[word] ?? [];
          WordNode? existingNode;
          for (final node in instances) {
            if (node.instance == tryInstance) {
              existingNode = node;
              break;
            }
          }

          // Temporary node for cycle checking if it doesn't exist yet
          final tempNode =
              existingNode ??
              WordNode(
                word: word,
                instance: tryInstance,
                cells: [], // Dummy
                phrases: {},
              );

          // Check if using this node would create a cycle
          if (predNode != null && wouldCreateCycle(predNode, tempNode)) {
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

        phraseNodes.add(selectedNode);
      }

      // Now add edges between consecutive nodes in this phrase
      for (int i = 0; i < phraseNodes.length - 1; i++) {
        final fromNode = phraseNodes[i];
        final toNode = phraseNodes[i + 1];
        edges.putIfAbsent(fromNode, () => {});
        edges[fromNode]!.add(toNode);
      }

      phrases[phraseText] = phraseNodes;
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
      final nodeIds = entry.value.map((n) => n.id).toList();
      print('  "${entry.key}" -> $nodeIds');
    }
  }
}
