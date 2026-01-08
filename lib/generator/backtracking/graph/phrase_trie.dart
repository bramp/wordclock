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

  /// The WordNode that this trie node belongs to (set during graph building)
  /// This creates a bidirectional link: WordNode -> PhraseTrieNode -> WordNode
  dynamic wordNode; // Use dynamic to avoid circular import

  PhraseTrieNode(this.wordCells, {this.parent}) : wordKey = wordCells.join();

  /// Clear cached position for this node and all descendants
  void invalidateCache() {
    cachedPosition = null;

    // TODO Check if children ever need to be invalidated - as we always place
    // in parent -> child order
    for (final child in children.values) {
      child.invalidateCache();
    }
  }

  /// Get the cached end position, or null if any node in path is not cached
  (int, int)? get pathEndPosition {
    if (cachedPosition == null) return null;
    return cachedPosition;
  }
}

/// Global trie containing all phrase prefixes.
///
/// Built once from all language phrases. Each path represents a sequence
/// of words that can precede some target word. Terminal nodes mark complete
/// predecessor sequences.
class PhraseTrie {
  /// Root-level children keyed by first word's key
  final Map<String, PhraseTrieNode> roots = {};

  /// Reverse index: wordKey -> all trie nodes with that word
  /// Used to quickly find nodes to update when a word is placed/removed
  // TODO This should not be needed, as we can map from WordNode to PhraseTrieNode
  final Map<String, List<PhraseTrieNode>> _nodesByWordKey = {};

  /// Get or create a root node for the given word
  PhraseTrieNode getOrCreateRoot(Word wordCells) {
    final key = wordCells.join();
    return roots.putIfAbsent(key, () {
      final node = PhraseTrieNode(wordCells);
      _addToIndex(node);
      return node;
    });
  }

  /// Get or create a child node
  PhraseTrieNode getOrCreateChild(PhraseTrieNode parent, Word wordCells) {
    final key = wordCells.join();
    return parent.children.putIfAbsent(key, () {
      final node = PhraseTrieNode(wordCells, parent: parent);
      _addToIndex(node);
      return node;
    });
  }

  void _addToIndex(PhraseTrieNode node) {
    _nodesByWordKey.putIfAbsent(node.wordKey, () => []).add(node);
  }

  /// Get all trie nodes for a given word key
  List<PhraseTrieNode> getNodesForWord(String wordKey) {
    return _nodesByWordKey[wordKey] ?? const [];
  }

  /// Update cached positions for all nodes matching wordKey.
  /// Only updates nodes whose parent path is satisfied (has cached position).
  void updatePositionsForWord(String wordKey, int row, int endCol) {
    final nodes = _nodesByWordKey[wordKey];
    if (nodes == null) return;

    for (final node in nodes) {
      // Root nodes can always be updated
      if (node.parent == null) {
        node.cachedPosition = (row, endCol);
      }
      // Child nodes only if parent is satisfied and position is after parent
      else if (node.parent!.cachedPosition != null) {
        final parentPos = node.parent!.cachedPosition!;
        // This word must come after parent in reading order
        if (row > parentPos.$1 ||
            (row == parentPos.$1 && endCol > parentPos.$2)) {
          node.cachedPosition = (row, endCol);
        }
      }
    }
  }

  /// Clear cached positions for all nodes matching wordKey and their descendants
  void clearPositionsForWord(String wordKey) {
    final nodes = _nodesByWordKey[wordKey];
    if (nodes == null) return;

    for (final node in nodes) {
      node.invalidateCache();
    }
  }

  /// Clear all cached positions in the entire trie
  void clearAllPositions() {
    for (final root in roots.values) {
      root.invalidateCache();
    }
  }

  /// Debug: count total nodes
  int get totalNodes {
    int count = 0;
    void countNodes(PhraseTrieNode node) {
      count++;
      for (final child in node.children.values) {
        countNodes(child);
      }
    }

    for (final root in roots.values) {
      countNodes(root);
    }
    return count;
  }
}
