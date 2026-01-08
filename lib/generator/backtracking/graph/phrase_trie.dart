import 'package:wordclock/model/types.dart';

/// A node in the global phrase trie.
///
/// Each path from root represents a prefix of one or more phrases.
/// Nodes cache their grid position when the corresponding word is placed,
/// enabling O(1) lookups instead of grid scanning.
class PhraseTrieNode {
  /// The word cells this node represents
  final Word wordCells;

  /// Key for this word (cells joined)
  final String wordKey;

  /// Children keyed by next word's key
  final Map<String, PhraseTrieNode> children = {};

  /// True if this node is the end of a complete predecessor sequence
  /// (i.e., the next word after this would be a WordNode we're trying to place)
  bool isTerminal = false;

  /// Cached grid position: (row, endCol) where this word was found
  /// in the context of this path. Null if not yet found or invalidated.
  (int row, int endCol)? cachedPosition;

  /// Parent node (null for root-level nodes)
  final PhraseTrieNode? parent;

  PhraseTrieNode(this.wordCells, {this.parent}) : wordKey = wordCells.join();
}

/// Global trie containing all phrase prefixes.
///
/// Built once from all language phrases. Each path represents a sequence
/// of words that can precede some target word. Terminal nodes mark complete
/// predecessor sequences.
class PhraseTrie {
  /// Root-level children keyed by first word's key
  final Map<String, PhraseTrieNode> roots = {};

  /// Get or create a root node for the given word
  PhraseTrieNode getOrCreateRoot(Word wordCells) {
    final key = wordCells.join();
    return roots.putIfAbsent(key, () => PhraseTrieNode(wordCells));
  }

  /// Get or create a child node
  PhraseTrieNode getOrCreateChild(PhraseTrieNode parent, Word wordCells) {
    final key = wordCells.join();
    return parent.children.putIfAbsent(
      key,
      () => PhraseTrieNode(wordCells, parent: parent),
    );
  }
}
