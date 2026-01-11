import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/backtracking/graph/graph_builder.dart';
import 'package:wordclock/generator/utils/word_clock_utils.dart';
import 'package:wordclock/languages/all.dart';
import 'package:wordclock/languages/language.dart';

/*
This table shows the word node count for each language using different building strategies.
Optimal is the theoretical minimum number of nodes (max occurrences of each word in any phrase).

Strategies:
- Ascending: Phrase list sorted by length ascending.
- Descending: Phrase list sorted by length descending.
- Trie: Phrase list built into a Trie and traversed BFS.
- Best: The strategy (or strategies) that resulted in the fewest nodes.

To regenerate this table, run:
  dart test/generator/backtracking/graph/analyze_graph_strategies.dart

ID      Optimal Asc     Desc    Trie    Best
CH      21      21      21      21      Asc Desc Trie
CA      26      42      28      39      Desc
CS      28      28      36      29      Asc
CT      28      28      36      29      Asc
CZ      22      22      27      22      Asc Trie
DK      22      25      25      23      Trie
NL      21      22      21      22      Desc
D4      23      24      23      24      Desc
E2      24      24      26      24      Asc Trie
EN      23      23      25      23      Asc Trie
FR      27      28      27      28      Desc
D2      23      24      23      24      Desc
DE      23      24      25      24      Asc Trie
GR      22      24      25      22      Trie
IT      24      26      24      24      Desc Trie
JP      28      32      37      32      Asc Trie
NO      20      21      20      21      Desc
PL      33      33      33      33      Asc Desc Trie
PE      28      31      32      28      Trie
RO      23      26      28      23      Trie
RU      29      29      36      30      Asc
ES      24      26      24      24      Desc Trie
D3      21      21      21      21      Asc Desc Trie
SE      21      23      23      22      Trie
TR      29      31      29      29      Desc Trie
*/

void main() {
  group('Graph Builder Efficiency', () {
    // Known non-optimal languages can be tracked here with their allowed excess nodes.
    // Ideally this map should be empty.
    final allowedExcess = <String, int>{
      'DK': 1,
      'JP': 4,
      'CA': 2, // Improved from 13 to 2 with multi-strategy
      'DE': 1,
      'SE': 1,
      // All others default to 0
    };

    for (final language in WordClockLanguages.all) {
      test('Language ${language.id} graph is near optimal', () {
        final graph = WordDependencyGraphBuilder.build(language: language);

        final actualNodeCount = graph.nodes.values.fold<int>(
          0,
          (sum, list) => sum + list.length,
        );
        final optimalNodeCount = _calculateOptimalNodeCount(language);
        final excess = actualNodeCount - optimalNodeCount;

        final allowed = allowedExcess[language.id] ?? 0;

        expect(
          excess,
          allowed,
          reason:
              'Language ${language.id}: Actual=$actualNodeCount, Optimal=$optimalNodeCount, Excess=$excess. Graph has unnecessary nodes (allowed: $allowed).',
        );
      });
    }
  });
}

int _calculateOptimalNodeCount(WordClockLanguage language) {
  final phrases = <String>{};
  WordClockUtils.forEachTime(language, (time, phrase) {
    phrases.add(phrase);
  });

  final maxOccurrences = <String, int>{};
  for (final phrase in phrases) {
    final words = language.tokenize(phrase);
    final counts = <String, int>{};
    for (final word in words) {
      counts[word] = (counts[word] ?? 0) + 1;
    }
    for (final entry in counts.entries) {
      if (entry.value > (maxOccurrences[entry.key] ?? 0)) {
        maxOccurrences[entry.key] = entry.value;
      }
    }
  }

  return maxOccurrences.values.fold(0, (sum, count) => sum + count);
}
