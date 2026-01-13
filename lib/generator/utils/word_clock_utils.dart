import 'package:wordclock/logic/time_to_words.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';

class WordClockUtils {
  /// Generates the set of all unique words required to display any time
  /// supported by the language. These words typically serve as the "atoms"
  /// for the dependency graph and grid layout.
  static Set<String> getAllWords(WordClockLanguage language) {
    final words = <String>{};
    forEachTime(language, (time, phrase) {
      words.addAll(language.tokenize(phrase));
    });
    return words;
  }

  /// Generates the set of all unique phrases required to display any time
  /// supported by the language.
  static Set<String> getAllPhrases(WordClockLanguage language) {
    final phrases = <String>{};
    forEachTime(language, (time, phrase) {
      phrases.add(phrase);
    });
    return phrases;
  }

  /// Iterates over every possible time supported by the language, providing
  /// the time and the corresponding word phrase.
  ///
  /// This is useful for validation, graph building, and testing.
  static void forEachTime(
    WordClockLanguage language,
    void Function(DateTime time, String phrase) visitor, {
    TimeToWords? timeToWords,
  }) {
    assert(
      timeToWords != null || language.defaultGridRef != null,
      'If timeToWords is not provided, language.defaultGridRef must not be null.',
    );
    final timeConverter = timeToWords ?? language.defaultGridRef!.timeToWords;
    final increment = language.minuteIncrement;

    for (int h = 0; h < 24; h++) {
      for (int m = 0; m < 60; m += increment) {
        final time = DateTime(2025, 1, 1, h, m);
        String phrase;
        try {
          phrase = timeConverter.convert(time);
        } catch (e) {
          // You might want to handle this or let it bubble up,
          // but here we just pass it as if it returned successfully or empty?
          // To be consistent with validation logic, we might need to fail.
          // For now, let's catch and rethrow with context or let caller handle.
          rethrow;
        }
        visitor(time, phrase);
      }
    }
  }

  /// Calculates the maximum number of times each word appears in any single phrase.
  /// This determines the minimum number of node instances needed for each word.
  static Map<String, int> calculateMaxWordOccurrences(
    Iterable<String> phrases,
    WordClockLanguage language,
  ) {
    final maxOccurrences = <String, int>{};
    for (final phraseText in phrases) {
      final words = language.tokenize(phraseText);
      final counts = <String, int>{};
      for (final word in words) {
        counts[word] = (counts[word] ?? 0) + 1;
      }
      for (final entry in counts.entries) {
        final current = maxOccurrences[entry.key] ?? 0;
        if (entry.value > current) {
          maxOccurrences[entry.key] = entry.value;
        }
      }
    }
    return maxOccurrences;
  }

  /// Heuristic to estimate minimum cells by allowing substrings to overlap.
  /// For example, "HEURE" is a substring of "HEURES", so we only count "HEURES"
  /// if they occur sufficiently often.
  static int estimateMinimumCells(Map<String, int> occurrences) {
    final sortedWords = occurrences.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    final available = Map<String, int>.from(occurrences);
    int total = 0;

    for (final word in sortedWords) {
      int count = available[word]!;
      if (count <= 0) continue;

      total += WordGrid.splitIntoCells(word).length * count;

      // See if this word can satisfy other shorter words
      for (final other in sortedWords) {
        if (word == other || other.length >= word.length) continue;
        // Only overlap if it's a complete substring (to be safe)
        if (word.contains(other)) {
          // We can satisfy at most 'count' instances of 'other' using this 'word'
          int covered = available[other]!;
          if (covered > count) covered = count;
          available[other] = available[other]! - covered;
        }
      }
    }
    return total;
  }
}
