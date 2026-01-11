import 'dart:collection';
import 'dart:developer' as developer;
import 'package:wordclock/generator/backtracking/graph/dependency_graph.dart';
import 'package:wordclock/generator/backtracking/graph/phrase_trie.dart';
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
    return buildBest(language: language);
  }

  /// Tries different construction strategies (Trie-based, various orderings)
  /// and returns the graph with the fewest nodes.
  static WordDependencyGraph buildBest({required WordClockLanguage language}) {
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

    // 2. Try multiple phrase orderings
    final orderings = <String, List<String>>{
      'length_asc': List.from(allPhrases)
        ..sort((a, b) => a.length.compareTo(b.length)),
      'length_desc': List.from(allPhrases)
        ..sort((a, b) => b.length.compareTo(a.length)),
    };

    WordDependencyGraph? bestGraph;
    var bestNodeCount = 999999;

    for (final entry in orderings.entries) {
      final graph = buildByPhrases(
        orderedPhrases: entry.value,
        language: language,
      );
      final nodeCount = graph.nodes.values.fold(0, (s, l) => s + l.length);

      if (nodeCount < bestNodeCount) {
        bestNodeCount = nodeCount;
        bestGraph = graph;
      }

      // Early exit if optimal
      if (nodeCount == optimalNodeCount) break;
    }

    // 3. Try Trie-based construction (BFS)
    if (bestNodeCount > optimalNodeCount) {
      final trieGraph = buildWithTrie(language: language, phrases: allPhrases);
      final trieNodeCount = trieGraph.nodes.values.fold(
        0,
        (s, l) => s + l.length,
      );

      if (trieNodeCount < bestNodeCount) {
        bestNodeCount = trieNodeCount;
        bestGraph = trieGraph;
      }
    }

    // Check if we achieved optimal node count
    _warnIfSuboptimal(bestGraph!.nodes, maxOccurrences, optimalNodeCount);

    return bestGraph;
  }

  /// Builds a graph by constructing a phrase Trie and then traversing it with BFS.
  static WordDependencyGraph buildWithTrie({
    required WordClockLanguage language,
    List<String>? phrases,
  }) {
    final allPhrases =
        phrases ?? WordClockUtils.getAllPhrases(language).toList();
    final trie = PhraseTrie.fromPhrases(allPhrases, language);

    // BFS to build Graph - Assign graph nodes to trie nodes
    final Map<String, List<WordNode>> nodes = {};
    final Map<WordNode, Set<WordNode>> edges = {};
    final Map<WordNode, Set<WordNode>> inEdges = {};
    final codec = CellCodec();
    final trieToGraph = <PhraseTrieNode, WordNode>{};

    // Queue stores: (TrieNode, Word, ParentGraphNode)
    final queue =
        ListQueue<({PhraseTrieNode node, String word, WordNode? parent})>();

    for (final entry in trie.roots.entries) {
      queue.add((node: entry.value, word: entry.key, parent: null));
    }

    while (queue.isNotEmpty) {
      final item = queue.removeFirst();
      final trieNode = item.node;
      final word = item.word;
      final parentGraphNode = item.parent;

      WordNode? selectedNode;
      final existingInstances = nodes[word] ??= [];

      // Try reuse
      for (final candidate in existingInstances) {
        if (parentGraphNode == null) {
          selectedNode = candidate;
          break;
        } else {
          if (!_wouldCreateCycle(edges, parentGraphNode, candidate)) {
            selectedNode = candidate;
            break;
          }
        }
      }

      if (selectedNode == null) {
        final cells = WordGrid.splitIntoCells(word);
        selectedNode = WordNode(
          word: word,
          instance: existingInstances.length,
          cellCodes: codec.encodeAll(cells),
          phrases: {}, // Populated later
        );
        existingInstances.add(selectedNode);
      }

      trieToGraph[trieNode] = selectedNode;

      if (parentGraphNode != null) {
        edges.putIfAbsent(parentGraphNode, () => {}).add(selectedNode);
        inEdges.putIfAbsent(selectedNode, () => {}).add(parentGraphNode);
      }

      for (final entry in trieNode.children.entries) {
        queue.add((node: entry.value, word: entry.key, parent: selectedNode));
      }
    }

    // Reconstruct Phrases map and link phrases to nodes
    final phraseMap = <String, List<WordNode>>{};
    for (final phrase in allPhrases) {
      final words = language.tokenize(phrase);
      if (words.isEmpty) continue;

      final phraseNodes = <WordNode>[];
      var current = trie.roots[words[0]]!;
      var graphNode = trieToGraph[current]!;
      graphNode.phrases.add(phrase);
      phraseNodes.add(graphNode);

      for (int i = 1; i < words.length; i++) {
        current = current.children[words[i]]!;
        graphNode = trieToGraph[current]!;
        graphNode.phrases.add(phrase);
        phraseNodes.add(graphNode);
      }
      phraseMap[phrase] = phraseNodes;
    }

    _buildPredecessorTries(phraseMap, trie: trie);

    return WordDependencyGraph(
      nodes: nodes,
      edges: edges,
      inEdges: inEdges,
      phrases: phraseMap,
      language: language,
      codec: codec,
    );
  }

  static WordDependencyGraph buildByPhrases({
    required List<String> orderedPhrases,
    required WordClockLanguage language,
  }) {
    final Map<String, List<WordNode>> nodes = {};
    final Map<WordNode, Set<WordNode>> edges = {};
    final Map<WordNode, Set<WordNode>> inEdges = {};
    final Map<String, List<WordNode>> phrases = {};
    final codec = CellCodec();

    // Helper to check if adding edge from->to would create a cycle
    bool wouldCreateCycle(WordNode fromNode, WordNode toNode) {
      return _wouldCreateCycle(edges, fromNode, toNode);
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
          if (predNode != null && wouldCreateCycle(predNode, node)) continue;

          selectedNode = node;
          break;
        }

        if (selectedNode != null) {
          selectedNode.phrases.add(phraseText);
        } else {
          final cells = WordGrid.splitIntoCells(word);
          selectedNode = WordNode(
            word: word,
            instance: instances.length,
            cellCodes: codec.encodeAll(cells),
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

    // Build the phrase trie and link nodes
    _buildPredecessorTries(phrases);

    return WordDependencyGraph(
      nodes: nodes,
      edges: edges,
      inEdges: inEdges,
      phrases: phrases,
      language: language,
      codec: codec,
    );
  }

  /// Checks if adding an edge from [fromNode] to [toNode] would create a cycle.
  static bool _wouldCreateCycle(
    Map<WordNode, Set<WordNode>> edges,
    WordNode fromNode,
    WordNode toNode,
  ) {
    if (fromNode == toNode) return true;
    final visited = <WordNode>{};
    final queue = ListQueue<WordNode>()..add(toNode);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      if (current == fromNode) return true;

      if (visited.add(current)) {
        final successors = edges[current];
        if (successors != null) queue.addAll(successors);
      }
    }
    return false;
  }

  /// Builds a trie from predecessor sequences to deduplicate common prefixes.
  /// Also links nodes to their predecessor terminals and owned trie nodes.
  static void _buildPredecessorTries(
    Map<String, List<WordNode>> phrases, {
    PhraseTrie? trie,
  }) {
    // Build the global phrase trie (or use existing)
    final globalTrie = trie ?? PhraseTrie();

    // Process each phrase to build trie paths and link to WordNodes
    for (final entry in phrases.entries) {
      final phraseNodes = entry.value;
      if (phraseNodes.isEmpty) continue;

      // Mark first word as having empty predecessor
      phraseNodes[0].hasEmptyPredecessor = true;

      // For words at position 1+, build predecessor trie path
      for (int targetIdx = 1; targetIdx < phraseNodes.length; targetIdx++) {
        final targetNode = phraseNodes[targetIdx];

        // Build trie path for predecessors [0..targetIdx-1]
        var currentTrieNode = globalTrie.getOrCreateRoot(phraseNodes[0].word);
        // First node owns this root trie node
        if (!phraseNodes[0].ownedTrieNodes.contains(currentTrieNode)) {
          phraseNodes[0].ownedTrieNodes.add(currentTrieNode);
        }

        for (int predIdx = 1; predIdx < targetIdx; predIdx++) {
          final predNode = phraseNodes[predIdx];
          currentTrieNode = globalTrie.getOrCreateChild(
            currentTrieNode,
            predNode.word,
          );
          // This predecessor node owns this trie node
          if (!predNode.ownedTrieNodes.contains(currentTrieNode)) {
            predNode.ownedTrieNodes.add(currentTrieNode);
          }
        }

        // Link node to target node
        if (!targetNode.phraseTrieNodes.contains(currentTrieNode)) {
          targetNode.phraseTrieNodes.add(currentTrieNode);
        }
      }
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
      developer.log(
        'Graph has $actualNodeCount nodes, but optimal is $optimalNodeCount',
        name: 'WordDependencyGraphBuilder',
        level: 900, // Warning level
      );
      developer.log(
        '  Extra instances created:',
        name: 'WordDependencyGraphBuilder',
        level: 900,
      );
      for (final entry in nodes.entries) {
        final word = entry.key;
        final instances = entry.value;
        final optimal = maxOccurrences[word] ?? 1;
        if (instances.length > optimal) {
          developer.log(
            '    $word: ${instances.length} nodes (optimal: $optimal)',
            name: 'WordDependencyGraphBuilder',
            level: 900,
          );
        }
      }
    }
  }
}
