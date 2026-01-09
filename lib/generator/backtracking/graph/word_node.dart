import 'package:wordclock/generator/backtracking/graph/phrase_trie.dart';
import 'package:wordclock/model/types.dart';

/// Maps cell strings to unique integer codes for fast comparison.
/// -1 is reserved for empty cells.
class CellCodec {
  final Map<Cell, int> _cellToCode = {};
  final List<Cell> _codeToCell = [];

  /// Get or create an integer code for a cell string.
  int encode(Cell cell) {
    var code = _cellToCode[cell];
    if (code == null) {
      code = _codeToCell.length;
      _cellToCode[cell] = code;
      _codeToCell.add(cell);
    }
    return code;
  }

  /// Convert integer code back to cell string.
  Cell decode(int code) => _codeToCell[code];

  /// Encode a list of cells to codes.
  List<int> encodeAll(List<Cell> cells) {
    final result = List<int>.filled(cells.length, 0);
    for (var i = 0; i < cells.length; i++) {
      result[i] = encode(cells[i]);
    }
    return result;
  }
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

  /// Integer codes for cells (for fast comparison in hot path)
  final List<int> cellCodes;

  /// Which phrases use this word node
  final Set<String> phrases;

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

  /// Index in the overlap matrix for O(1) lookup.
  /// Set by [IndexedGraph.build], -1 if not set.
  int matrixIndex = -1;

  /// Unique identifier for this node (e.g., "FIVE", "FIVE#1", "FIVE#2")
  String get id => instance == 0 ? word : '$word#$instance';

  /// Frequency: how many phrases use this word node
  int get frequency => phrases.length;

  /// Priority score for placement order
  double get priority => frequency * 10.0 + (cellCodes.length / 10.0);

  WordNode({
    required this.word,
    required this.instance,
    required this.cellCodes,
    required this.phrases,
  });

  @override
  String toString() =>
      'WordNode($id, freq=$frequency, len=${cellCodes.length})';
}
