import 'package:wordclock/languages/language.dart';

class WordClockUtils {
  /// Generates the set of all unique words required to display any time
  /// supported by the language.
  static Set<String> collectAllWords(WordClockLanguage language) {
    final words = <String>{};
    final timeConverter = language.timeToWords;
    final increment = language.minuteIncrement;

    for (int h = 0; h < 24; h++) {
      for (int m = 0; m < 60; m += increment) {
        final time = DateTime(2025, 1, 1, h, m);
        final phrase = timeConverter.convert(time);
        words.addAll(phrase.split(' ').where((w) => w.isNotEmpty));
      }
    }
    return words;
  }

  /// Iterates over every possible time supported by the language, providing
  /// the time and the corresponding word phrase.
  ///
  /// This is useful for validation, graph building, and testing.
  static void forEachTime(
    WordClockLanguage language,
    void Function(DateTime time, String phrase) visitor,
  ) {
    final timeConverter = language.timeToWords;
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
}
