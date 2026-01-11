import 'package:wordclock/generator/backtracking/grid_builder.dart';
import 'package:wordclock/generator/backtracking/grid_state.dart';
import 'package:wordclock/generator/backtracking/graph/dependency_graph.dart';
import 'package:wordclock/generator/backtracking/graph/word_node.dart';
import 'package:wordclock/generator/backtracking/graph/cell_codec.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/logic/time_to_words.dart';

export 'package:wordclock/generator/backtracking/graph/dependency_graph.dart';
export 'package:wordclock/generator/backtracking/graph/word_node.dart';
export 'package:wordclock/generator/backtracking/graph/cell_codec.dart';
export 'package:wordclock/languages/language.dart';
export 'package:wordclock/logic/time_to_words.dart';

/// Mock TimeToWords implementation for testing
class MockTimeToWords extends TimeToWords {
  final List<String> phrases;

  MockTimeToWords(this.phrases);

  @override
  String convert(DateTime time) {
    if (phrases.isEmpty) return "";
    // Return phrases in order based on minutes
    // To allow stateless behavior:
    // 00:00 -> phrases[0]
    // 00:01 -> phrases[0] (if minuteIncrement > 1)
    // We'll use minute buckets if we can, but simpler is just round robin based on index or time
    // For predictability in tests, we usually want specific mapping.
    // The previous implementation used `time.minute % length`.
    int idx = (time.hour * 60 + time.minute) ~/ 1; // Default to per-minute
    return phrases[idx % phrases.length];
  }
}

/// A simpler stateless converter that matches some existing tests
class SimpleConverter extends TimeToWords {
  final List<String> phrases;
  final int minuteIncrement;

  SimpleConverter(this.phrases, {this.minuteIncrement = 5});

  @override
  String convert(DateTime time) {
    int idx = (time.hour * 60 + time.minute) ~/ minuteIncrement;
    if (idx >= phrases.length) {
      // Loop or stick to last? greedy tests stuck to last.
      // Backtracking tests looped.
      // Let's loop for safety in most cases, or stick to last if desired.
      return phrases.last;
    }
    return phrases[idx];
  }
}

WordClockLanguage createMockLanguage({
  String? id,
  List<String>? phrases,
  TimeToWords? timeToWords,
  String? languageCode,
  String? displayName,
  String? englishName,
  String paddingAlphabet = '·',
  int minuteIncrement = 5,
  bool requiresPadding = true,
  bool atomizePhrases = false,
}) {
  final converter = timeToWords ?? SimpleConverter(phrases ?? []);

  return WordClockLanguage(
    id: id ?? 'TEST',
    languageCode: languageCode ?? 'en-TEST',
    displayName: displayName ?? 'Test Language',
    englishName: englishName ?? 'Test',
    timeToWords: converter,
    minuteIncrement: minuteIncrement,
    requiresPadding: requiresPadding,
    paddingAlphabet: paddingAlphabet,
    atomizePhrases: atomizePhrases,
  );
}

/// Helper to create a Placement manually
Placement createPlacement(
  String word,
  int row,
  int col,
  int gridWidth, {
  CellCodec? codec,
  String? phrase,
}) {
  final c = codec ?? CellCodec();
  final node = WordNode(
    word: word,
    instance: 0,
    cellCodes: c.encodeAll(word.split('')),
    phrases: {phrase ?? 'PHRASE'},
  );
  return Placement(
    node: node,
    startOffset: row * gridWidth + col,
    width: gridWidth,
  );
}

/// Helper to set up builder with graph
void setupBuilder(BacktrackingGridBuilder builder, WordDependencyGraph graph) {
  builder.graph = graph;
  builder.codec = graph.codec;
}

/// Helper to place a word and update the trie cache (mimics what _solve does)
Placement? placeWordWithCache(GridState state, WordNode node, int offset) {
  final placement = state.placeWord(node, offset);
  if (placement != null) {
    // Update trie cache with end offset
    final endOffset = offset + placement.length - 1;
    for (final trieNode in node.ownedTrieNodes) {
      trieNode.endOffset = endOffset;
    }
  }
  return placement;
}

/// Helper to convert 1D offset to (row, col)
(int row, int col) offsetToRowCol(int offset, int width) {
  if (offset == -1) return (-1, -1);
  return (offset ~/ width, offset % width);
}
