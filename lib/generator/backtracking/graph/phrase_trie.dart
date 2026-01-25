import 'package:meta/meta.dart';
import 'package:wordclock/languages/language.dart';

/// A node in the global phrase trie.
/// Used by both:
/// 1. DAG Solver: Cache predecessor placement positions (O(1) lookups).
/// 2. Trie Solver: Represents the search space state and frontier.
class PhraseTrieNode {
  /// The word at this node
  final String word;

  /// Depth in trie (1 for first word, etc.)
  final int depth;

  /// Children keyed by next word
  final Map<String, PhraseTrieNode> children = {};

  // --- Common State ---

  /// The grid position where this word ends: 1D offset (row * width + col).
  /// -1 if the word is not currently placed.
  int endOffset = -1;

  // --- Trie Solver Specifics ---

  /// Word index in lexicon (optimization for Trie solver bitsets)
  int wordId = -1;

  /// Pre-computed topological rank for sorting (lower = place earlier).
  int rank = 0;

  /// True if this node is the end of at least one phrase
  bool isTerminal = false;

  /// Which phrases end at this node
  final List<String> terminalPhrases = [];

  /// The end offset of the parent/predecessor word.
  /// This node's word must be placed at position >= parentEndOffset.
  /// For root nodes, this is -1.
  int parentEndOffset = -1;

  PhraseTrieNode({required this.word, this.depth = 0});

  @override
  String toString() =>
      'PhraseTrieNode($word, depth=$depth, terminal=$isTerminal, end=$endOffset)';
}

/// Global trie containing all phrase prefixes.
class PhraseTrie {
  /// Root nodes (first words of phrases)
  final Map<String, PhraseTrieNode> roots = {};

  /// Count of phrases added
  int phraseCount = 0;

  PhraseTrie();

  /// Get or create a root node for the given word
  PhraseTrieNode getOrCreateRoot(String word) {
    return roots.putIfAbsent(word, () => PhraseTrieNode(word: word, depth: 1));
  }

  /// Get or create a child node
  PhraseTrieNode getOrCreateChild(PhraseTrieNode parent, String word) {
    return parent.children.putIfAbsent(
      word,
      () => PhraseTrieNode(word: word, depth: parent.depth + 1),
    );
  }

  /// Adds a phrase to the trie.
  void addPhrase(String phrase, List<String> words) {
    if (words.isEmpty) return;

    var node = getOrCreateRoot(words[0]);

    for (int i = 1; i < words.length; i++) {
      node = getOrCreateChild(node, words[i]);
    }

    node.isTerminal = true;
    node.terminalPhrases.add(phrase);
    phraseCount++;
  }

  /// Builds a PhraseTrie from a list of phrases.
  ///
  /// Extracts words using the provided language's tokenizer and adds
  /// them to the trie.
  factory PhraseTrie.fromPhrases(
    Iterable<String> phrases,
    WordClockLanguage language,
  ) {
    final trie = PhraseTrie();
    for (final phrase in phrases) {
      final words = language.tokenize(phrase);
      if (words.isNotEmpty) {
        trie.addPhrase(phrase, words);
      }
    }
    return trie;
  }

  @override
  String toString() {
    int nodeCount = countNodes();
    final sorts = countTopologicalSorts();
    String sortsStr;
    if (sorts == BigInt.zero) {
      sortsStr = '0';
    } else {
      final s = sorts.toString();
      if (s.length <= 15) {
        sortsStr = s;
      } else {
        sortsStr = '${s[0]}.${s.substring(1, 4)}e+${s.length - 1}';
      }
    }

    return 'PhraseTrie:\n'
        '  ${roots.length} root words\n'
        '  $nodeCount total nodes\n'
        '  $phraseCount phrases ($sortsStr topological sorts)';
  }

  /// Returns the number of unique word sequences that can satisfy this trie.
  /// Implements Hook Length Formula: n! / PRODUCT(subtree_size(v))
  @visibleForTesting
  BigInt countTopologicalSorts() {
    final subtreeSize = <PhraseTrieNode, int>{};
    final allNodes = <PhraseTrieNode>[];

    int computeSize(PhraseTrieNode node) {
      allNodes.add(node);
      int size = 1;
      for (final child in node.children.values) {
        size += computeSize(child);
      }
      return subtreeSize[node] = size;
    }

    int totalNodes = 0;
    for (final root in roots.values) {
      totalNodes += computeSize(root);
    }

    if (totalNodes == 0) return BigInt.zero;

    var numerator = BigInt.one;
    for (int i = 2; i <= totalNodes; i++) {
      numerator *= BigInt.from(i);
    }

    var denominator = BigInt.one;
    for (final node in allNodes) {
      denominator *= BigInt.from(subtreeSize[node]!);
    }

    return numerator ~/ denominator;
  }

  /// Returns total nodes in trie.
  int countNodes() {
    int count = 0;
    void traverse(PhraseTrieNode node) {
      count++;
      for (final child in node.children.values) {
        traverse(child);
      }
    }

    for (final root in roots.values) {
      traverse(root);
    }
    return count;
  }
}
