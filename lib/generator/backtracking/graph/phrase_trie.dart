import 'package:wordclock/languages/language.dart';

/// A node in the global phrase trie.
///
/// Each path from root represents a prefix of one or more phrases.
/// Nodes cache their grid position when the corresponding word is placed,
/// enabling O(1) lookups instead of grid scanning.
class PhraseTrieNode {
  /// Children keyed by next word
  final Map<String, PhraseTrieNode> children = {};

  /// The grid position where this word ends: 1D offset (row * width + col).
  /// -1 if the word is not currently placed.
  int endOffset = -1;
}

/// Global trie containing all phrase prefixes.
///
/// Built once from all language phrases. Each path represents a sequence
/// of words that can precede some target word.
class PhraseTrie {
  /// Root-level children keyed by first word
  final Map<String, PhraseTrieNode> roots = {};

  PhraseTrie();

  /// Get or create a root node for the given word
  PhraseTrieNode getOrCreateRoot(String word) {
    return roots.putIfAbsent(word, () => PhraseTrieNode());
  }

  /// Get or create a child node
  PhraseTrieNode getOrCreateChild(PhraseTrieNode parent, String word) {
    return parent.children.putIfAbsent(word, () => PhraseTrieNode());
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
      if (words.isEmpty) continue;

      var current = trie.getOrCreateRoot(words[0]);
      for (int i = 1; i < words.length; i++) {
        current = trie.getOrCreateChild(current, words[i]);
      }
    }
    return trie;
  }
}
