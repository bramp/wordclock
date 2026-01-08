import 'package:wordclock/generator/backtracking/graph/phrase_trie.dart';
import 'package:wordclock/model/types.dart';

/// A trie node for efficient predecessor sequence lookup.
/// Each path from root to leaf represents a valid predecessor sequence.
/// @deprecated Use [PhraseTrie] and [PhraseTrieNode] instead.
class PredecessorTrieNode {
  /// Children keyed by word string (cells joined)
  final Map<String, PredecessorTrieNode> children = {};

  /// True if this node represents the end of at least one predecessor sequence
  bool isTerminal = false;

  /// The word cells at this trie node (for grid scanning)
  final Word wordCells;

  PredecessorTrieNode(this.wordCells);
}

/// Root of a predecessor trie - just a container for first-word children
/// @deprecated Use [PhraseTrie] instead.
class PredecessorTrie {
  /// Children keyed by first word string (cells joined)
  final Map<String, PredecessorTrieNode> roots = {};
}

/// Represents a word node in the word-level dependency graph.
///
/// Each node represents a word, potentially with an instance number if the word
/// appears multiple times in the same phrase (e.g., "FIVE TO FIVE").
class WordNode {
  /// The actual word text (e.g., "FIVE", "O'CLOCK")
  final String word;

  /// Instance number (0 for first occurrence, 1 for second, etc.)
  /// Only non-zero when word appears multiple times in the same phrase
  final int instance;

  /// The word split into cells (usually characters, but can be multi-char)
  final Word cells;

  /// Which phrases use this word node
  final Set<String> phrases;

  /// Pre-computed predecessor tokens for each phrase.
  /// Each inner list contains the tokens that must appear BEFORE this word
  /// in reading order for that phrase. Empty list means this is the first word.
  /// Populated by [WordDependencyGraphBuilder] after graph construction.
  final List<List<String>> predecessorTokens = [];

  /// Pre-computed predecessor cells for each phrase.
  /// Parallel to [predecessorTokens] - each inner list contains the cells
  /// for each predecessor token. Used for efficient grid scanning.
  /// Populated by [WordDependencyGraphBuilder] after graph construction.
  final List<Phrase> predecessorCells = [];

  /// Pre-computed trie of predecessor sequences for efficient scanning.
  /// Built from [predecessorCells] to deduplicate common prefixes.
  /// Populated by [WordDependencyGraphBuilder] after graph construction.
  /// @deprecated Use [phraseTrieNodes] instead.
  PredecessorTrie? predecessorTrie;

  /// Links to all PhraseTrieNode instances representing this word in phrases.
  /// These are the TERMINAL nodes of predecessor sequences - i.e., the last
  /// word before the word we're trying to place.
  /// Populated by [WordDependencyGraphBuilder] after graph construction.
  final List<PhraseTrieNode> phraseTrieNodes = [];

  /// Links to PhraseTrieNode instances that this WordNode "owns" - i.e., trie
  /// nodes where this WordNode IS the predecessor word. When this WordNode is
  /// placed, it should update these nodes' cachedPosition. When removed, clear them.
  /// Populated by [WordDependencyGraphBuilder] after graph construction.
  final List<PhraseTrieNode> ownedTrieNodes = [];

  /// True if any phrase has this word as the first word (no predecessors)
  bool hasEmptyPredecessor = false;

  /// Unique identifier for this node (e.g., "FIVE", "FIVE#1", "FIVE#2")
  String get id => instance == 0 ? word : '$word#$instance';

  /// Frequency: how many phrases use this word node
  int get frequency => phrases.length;

  /// Priority score for placement order
  double get priority => frequency * 10.0 + (cells.length / 10.0);

  WordNode({
    required this.word,
    required this.instance,
    required this.cells,
    required this.phrases,
  });

  @override
  String toString() => 'WordNode($id, freq=$frequency, len=${cells.length})';
}
