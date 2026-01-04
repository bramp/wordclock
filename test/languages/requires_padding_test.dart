import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/languages/all.dart';

/// Determines if a language traditionally uses spaces between words.
/// Accepts ISO 639-1 language codes (e.g., 'en', 'zh', 'th').
bool requiresSpaces(String languageCode) {
  // Normalize the input to lowercase and take the first 2 characters
  // to handle locale strings like 'en_US' or 'zh_Hans'.
  if (languageCode.length < 2) return true; // Fallback for safety
  final code = languageCode.toLowerCase().substring(0, 2);

  const nonSpacedLanguages = {
    'zh', // Chinese (Mandarin, Cantonese, etc.)
    'ja', // Japanese
    'th', // Thai
    'lo', // Lao
    'km', // Khmer (Cambodian)
    'my', // Burmese
    'bo', // Tibetan (uses dots, but not whitespace)
  };

  // If the language is in our set, it does NOT require spaces.
  return !nonSpacedLanguages.contains(code);
}

void main() {
  test('All languages have correct requiresPadding configuration', () {
    for (final language in WordClockLanguages.all) {
      final shouldRequirePadding = requiresSpaces(language.languageCode);

      expect(
        language.requiresPadding,
        shouldRequirePadding,
        reason:
            'Language ${language.languageCode} (${language.displayName}) requiresPadding should be $shouldRequirePadding',
      );
    }
  });
}
