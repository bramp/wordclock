/// A node in the global phrase trie.
///
/// Each path from root represents a prefix of one or more phrases.
/// Nodes cache their grid position when the corresponding word is placed,
/// enabling O(1) lookups instead of grid scanning.
class PhraseTrieNode {
  /// Children keyed by next word
  final Map<String, PhraseTrieNode> children = {};

  /// True if this node is the end of a complete predecessor sequence
  /// (i.e., the next word after this would be a WordNode we're trying to place)
  bool isTerminal = false;

  /// Cached grid position: 1D offset (row * width + endCol) where this word ends.
  /// -1 if not yet found or invalidated.
  int cachedEndOffset = -1;

  /// Parent node (null for root-level nodes)
  final PhraseTrieNode? parent;

  PhraseTrieNode({this.parent});
}

/// Global trie containing all phrase prefixes.
///
/// Built once from all language phrases. Each path represents a sequence
/// of words that can precede some target word. Terminal nodes mark complete
/// predecessor sequences.
class PhraseTrie {
  /// Root-level children keyed by first word
  final Map<String, PhraseTrieNode> roots = {};

  /// Get or create a root node for the given word
  PhraseTrieNode getOrCreateRoot(String word) {
    return roots.putIfAbsent(word, () => PhraseTrieNode());
  }

  /// Get or create a child node
  PhraseTrieNode getOrCreateChild(PhraseTrieNode parent, String word) {
    return parent.children.putIfAbsent(
      word,
      () => PhraseTrieNode(parent: parent),
    );
  }
}
