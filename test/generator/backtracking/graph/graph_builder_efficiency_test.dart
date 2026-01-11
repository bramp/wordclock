import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/backtracking/graph/graph_builder.dart';
import 'package:wordclock/generator/utils/word_clock_utils.dart';
import 'package:wordclock/languages/all.dart';
import 'package:wordclock/languages/language.dart';

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
