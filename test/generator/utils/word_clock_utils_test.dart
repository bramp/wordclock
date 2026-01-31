import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/utils/word_clock_utils.dart';
import '../test_helpers.dart';

void main() {
  group('WordClockUtils', () {
    test('getAllWords returns all unique words in the language', () {
      final language = createMockLanguage(
        phrases: ['IT IS FIVE', 'IT IS TEN'],
        minuteIncrement: 30 * 60, // Every 30 hours? No, it takes minutes.
      );
      // forEachTime circles through 24 hours * (60 / minuteIncrement) times.
      // With increment 30, it's 24 * 2 = 48 times.
      // Phrases: 'IT', 'IS', 'FIVE', 'TEN'

      final words = WordClockUtils.getAllWords(language);
      expect(words, containsAll(['IT', 'IS', 'FIVE', 'TEN']));
    });

    test('getAllPhrases returns all unique phrases', () {
      final language = createMockLanguage(
        phrases: ['IT IS FIVE', 'IT IS TEN'],
        minuteIncrement: 30,
      );
      final phrases = WordClockUtils.getAllPhrases(language);
      expect(phrases, containsAll(['IT IS FIVE', 'IT IS TEN']));
      expect(phrases.length, 2);
    });

    test('calculateMaxWordOccurrences returns correct counts', () {
      final language = createMockLanguage();
      final phrases = ['A B A', 'B C', 'A'];
      final counts = WordClockUtils.calculateMaxWordOccurrences(
        phrases,
        language,
      );

      expect(counts['A'], 2);
      expect(counts['B'], 1);
      expect(counts['C'], 1);
    });

    test('estimateMinimumCells handles overlapping substrings', () {
      final occurrences = {'HEURES': 1, 'HEURE': 1, 'TEN': 2};

      // HEURES (6) - can contain HEURE (5).
      // If we have 1 HEURES and 1 HEURE, we need 6 cells (HEURES) and HEURE is covered.
      // TEN (3) * 2 = 6 cells.
      // Total = 6 + 6 = 12.
      final estimate = WordClockUtils.estimateMinimumCells(occurrences);
      expect(estimate, 12);
    });

    test('estimateMinimumCells handles multiple overlaps', () {
      final occurrences = {'ABC': 2, 'AB': 1, 'BC': 1};
      // ABC (3) * 2 = 6 cells.
      // AB (2) can be covered by one ABC. BC (2) can be covered by the other ABC.
      // Total = 6.
      final estimate = WordClockUtils.estimateMinimumCells(occurrences);
      expect(estimate, 6);
    });

    test('estimateMinimumCells with no overlaps', () {
      final occurrences = {'ONE': 1, 'TWO': 1};
      expect(WordClockUtils.estimateMinimumCells(occurrences), 6);
    });
  });
}
