import 'dart:collection';
import 'dart:developer' as developer;
import 'package:wordclock/generator/backtracking/graph/dependency_graph.dart';
import 'package:wordclock/generator/backtracking/graph/phrase_trie.dart';
import 'package:wordclock/generator/backtracking/graph/word_node.dart';
import 'package:wordclock/generator/backtracking/graph/cell_codec.dart';
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
    final allPhrases = WordClockUtils.getAllPhrases(language).toList();

    // Calculate the optimal (minimum) number of nodes needed for these phrases
    final maxOccurrences = _calculateMaxWordOccurrences(allPhrases, language);
    final optimalNodeCount = maxOccurrences.values.fold(
      0,
      (sum, count) => sum + count,
    );

    // 2. Try multiple strategies
    final orderings = <String, List<String>>{
      'length_asc': allPhrases.toList()
        ..sort((a, b) => a.length.compareTo(b.length)),
      'length_desc': allPhrases.toList()
        ..sort((a, b) => b.length.compareTo(a.length)),
    };

    WordDependencyGraph? bestGraph;
    int bestNodeCount = 999999;

    for (final entry in orderings.entries) {
      final graph = buildByPhrases(
        orderedPhrases: entry.value,
        language: language,
      );
      final nodeCount = graph.allNodes.length;

      if (nodeCount < bestNodeCount) {
        bestNodeCount = nodeCount;
        bestGraph = graph;
      }

      // Early exit if optimal
      if (nodeCount == optimalNodeCount) break;
    }

    // 3. Try Trie-based construction (BFS) if not already optimal
    if (bestNodeCount > optimalNodeCount) {
      final trieGraph = buildWithTrie(language: language, phrases: allPhrases);
      final trieNodeCount = trieGraph.allNodes.length;

      if (trieNodeCount < bestNodeCount) {
        bestNodeCount = trieNodeCount;
        bestGraph = trieGraph;
      }
    }

    // Check if we achieved optimal node count
    _warnIfSuboptimal(bestGraph!.nodes, maxOccurrences, optimalNodeCount);

    return bestGraph;
  }

  static WordDependencyGraph buildWithTrie({
    required WordClockLanguage language,
    List<String>? phrases,
  }) {
    final allPhrases =
        phrases ?? WordClockUtils.getAllPhrases(language).toList();
    final trie = PhraseTrie.fromPhrases(allPhrases, language);
    final state = _GraphState(language);
    final trieToGraph = <PhraseTrieNode, WordNode>{};

    // BFS to build Graph - Assign graph nodes to trie nodes
    final queue = ListQueue<_TrieBfsItem>();

    for (final entry in trie.roots.entries) {
      queue.add(_TrieBfsItem(node: entry.value, word: entry.key, parent: null));
    }

    while (queue.isNotEmpty) {
      final item = queue.removeFirst();
      final graphNode = state.getOrCreateNode(item.word, item.parent);
      trieToGraph[item.node] = graphNode;

      if (item.parent != null) state.addEdge(item.parent!, graphNode);

      for (final entry in item.node.children.entries) {
        queue.add(
          _TrieBfsItem(node: entry.value, word: entry.key, parent: graphNode),
        );
      }
    }

    // Reconstruct Phrases map and link phrases to nodes
    final phraseMap = <String, List<WordNode>>{};
    for (final phrase in allPhrases) {
      final words = language.tokenize(phrase);
      if (words.isEmpty) continue;

      final phraseNodes = <WordNode>[];
      var currentTrieNode = trie.roots[words[0]]!;

      for (int i = 0; i < words.length; i++) {
        if (i > 0) currentTrieNode = currentTrieNode.children[words[i]]!;
        final graphNode = trieToGraph[currentTrieNode]!;
        graphNode.phrases.add(phrase);
        phraseNodes.add(graphNode);
      }
      phraseMap[phrase] = phraseNodes;
    }

    _buildPredecessorTries(phraseMap, language: language, trie: trie);

    return state.createGraph(phraseMap);
  }

  static WordDependencyGraph buildByPhrases({
    required List<String> orderedPhrases,
    required WordClockLanguage language,
  }) {
    final state = _GraphState(language);
    final phraseMap = <String, List<WordNode>>{};

    // Process all phrases in the given order
    for (final phraseText in orderedPhrases) {
      final words = language.tokenize(phraseText);
      if (words.isEmpty) continue;

      state.addPhraseSequence(phraseText, words, phraseMap);
    }

    // Build the phrase trie and link nodes
    _buildPredecessorTries(phraseMap, language: language);

    return state.createGraph(phraseMap);
  }

  /// Checks if adding an edge from [fromNode] to [toNode] would create a cycle.
  static bool _wouldCreateCycle(
    Map<WordNode, Set<WordNode>> edges,
    WordNode fromNode,
    WordNode toNode,
  ) {
    if (fromNode == toNode) return true;

    // BFS to see if fromNode is reachable from toNode
    final visited = <WordNode>{};
    final queue = ListQueue<WordNode>()..add(toNode);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      if (current == fromNode) return true;

      for (final successor in edges[current] ?? {}) {
        if (visited.add(successor)) {
          queue.add(successor);
        }
      }
    }
    return false;
  }

  /// Builds a trie from predecessor sequences to deduplicate common prefixes.
  /// Also links nodes to their predecessor terminals and owned trie nodes.
  static void _buildPredecessorTries(
    Map<String, List<WordNode>> phrases, {
    required WordClockLanguage language,
    PhraseTrie? trie,
  }) {
    // Build the global phrase trie (or use existing)
    final globalTrie = trie ?? PhraseTrie.fromPhrases(phrases.keys, language);

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

/// Helper to maintain build state for the word dependency graph.
class _GraphState {
  final WordClockLanguage language;
  final CellCodec codec = CellCodec();
  final Map<String, List<WordNode>> nodes = {};
  final Map<WordNode, Set<WordNode>> edges = {};
  final Map<WordNode, Set<WordNode>> inEdges = {};

  _GraphState(this.language);

  WordNode getOrCreateNode(String word, WordNode? predecessor) {
    final instances = nodes[word] ??= [];

    // Try to find an existing instance that doesn't create a cycle
    for (final node in instances) {
      if (predecessor == null ||
          !WordDependencyGraphBuilder._wouldCreateCycle(
            edges,
            predecessor,
            node,
          )) {
        return node;
      }
    }

    // Create new node
    final cells = WordGrid.splitIntoCells(word);
    final newNode = WordNode(
      word: word,
      instance: instances.length,
      cellCodes: codec.encodeAll(cells),
      phrases: {},
    );
    instances.add(newNode);
    return newNode;
  }

  void addEdge(WordNode from, WordNode to) {
    edges.putIfAbsent(from, () => {}).add(to);
    inEdges.putIfAbsent(to, () => {}).add(from);
  }

  /// Adds a sequence of words as a phrase, reusing or creating nodes.
  void addPhraseSequence(
    String phraseText,
    List<String> words,
    Map<String, List<WordNode>> phraseMap,
  ) {
    final phraseNodes = <WordNode>[];
    WordNode? predNode;

    for (final word in words) {
      final node = getOrCreateNode(word, predNode);
      node.phrases.add(phraseText);
      phraseNodes.add(node);

      if (predNode != null) addEdge(predNode, node);
      predNode = node;
    }

    phraseMap[phraseText] = phraseNodes;
  }

  WordDependencyGraph createGraph(Map<String, List<WordNode>> phrases) {
    return WordDependencyGraph(
      nodes: nodes,
      edges: edges,
      inEdges: inEdges,
      phrases: phrases,
      language: language,
      codec: codec,
    );
  }
}

/// A helper class for the BFS traversal in [WordDependencyGraphBuilder.buildWithTrie].
class _TrieBfsItem {
  final PhraseTrieNode node;
  final String word;
  final WordNode? parent;

  _TrieBfsItem({required this.node, required this.word, this.parent});
}
