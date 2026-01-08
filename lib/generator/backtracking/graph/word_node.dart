import 'package:wordclock/model/types.dart';

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
