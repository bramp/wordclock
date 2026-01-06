import 'package:wordclock/languages/language.dart';
import 'package:wordclock/logic/time_to_words.dart';

/// Mock TimeToWords implementation for testing
class MockTimeToWords extends TimeToWords {
  final List<String> phrases;

  MockTimeToWords(this.phrases);

  @override
  String convert(DateTime time) {
    // Simple mock: return phrases in order based on minutes
    final index = time.minute % phrases.length;
    return phrases[index];
  }
}

WordClockLanguage createMockLanguage({
  required String id,
  required List<String> phrases,
  int minuteIncrement = 5,
  String paddingAlphabet = ' ',
  bool requiresPadding = true,
}) {
  return WordClockLanguage(
    id: id,
    languageCode: 'en-TEST',
    displayName: 'Test Language',
    englishName: 'Test',
    timeToWords: MockTimeToWords(phrases),
    minuteIncrement: minuteIncrement,
    requiresPadding: requiresPadding,
    paddingAlphabet: paddingAlphabet,
    atomizePhrases: false,
  );
}
