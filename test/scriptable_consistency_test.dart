import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/scriptable_time_to_words.dart';
import 'package:wordclock/logic/time_to_words.dart';
import 'package:wordclock/logic/english_time_to_word.dart';
import 'package:wordclock/logic/japanese_time_to_words.dart';
import 'package:wordclock/logic/spanish_time_to_words.dart';
import 'package:wordclock/logic/german_time_to_word.dart';
import 'package:wordclock/logic/french_time_to_words.dart';
import 'package:wordclock/logic/portuguese_time_to_words.dart';
import 'package:wordclock/logic/italian_time_to_words.dart';
import 'package:wordclock/logic/dutch_time_to_words.dart';
import 'package:wordclock/logic/russian_time_to_words.dart';
import 'package:wordclock/logic/catalan_time_to_words.dart';
import 'package:wordclock/logic/chinese_time_to_words.dart';
import 'package:wordclock/logic/czech_time_to_words.dart';
import 'package:wordclock/logic/danish_time_to_words.dart';
import 'package:wordclock/logic/greek_time_to_words.dart';
import 'package:wordclock/logic/hebrew_time_to_words.dart';
import 'package:wordclock/logic/norwegian_time_to_words.dart';
import 'package:wordclock/logic/romanian_time_to_words.dart';
import 'package:wordclock/logic/swedish_time_to_words.dart';
import 'package:wordclock/logic/turkish_time_to_words.dart';

void main() {
  final jsonFile = File('assets/scriptable_languages.json');
  final jsonStr = jsonFile.readAsStringSync();
  final Map<String, dynamic> jsonMap = jsonDecode(jsonStr);

  group('Scriptable Consistency Tests', () {
    // Keep the following list sorted
    final languagesToTest = {
      'JP': JapaneseTimeToWords(),
      'EN': EnglishTimeToWords(),
      'E2': EnglishAlternativeTimeToWords(),
      'E3': EnglishDigitalTimeToWords(),
      'ES': SpanishTimeToWords(),
      'DE': GermanTimeToWords(),
      'D2': GermanAlternativeETimeToWords(),
      'D3': SwabianGermanTimeToWords(),
      'D4': EastGermanTimeToWords(),
      'CH': BerneseGermanTimeToWords(),
      'FR': FrenchTimeToWords(),
      'PE': PortugueseTimeToWords(),
      'IT': ItalianTimeToWords(),
      'NL': DutchTimeToWords(),
      'RU': RussianTimeToWords(),
      'CA': CatalanTimeToWords(),
      'CS': ChineseSimplifiedTimeToWords(),
      'CT': ChineseTraditionalTimeToWords(),
      'CZ': CzechTimeToWords(),
      'DK': DanishTimeToWords(),
      'GR': GreekTimeToWords(),
      'HE': HebrewTimeToWords(),
      'NO': NorwegianTimeToWords(),
      'RO': RomanianTimeToWords(),
      'SE': SwedishTimeToWords(),
      'TR': TurkishTimeToWords(),
    };

    languagesToTest.forEach((code, implementation) {
      test('Language $code matches scriptable data', () {
        final data = ScriptableLanguageData.fromJson(jsonMap[code]);
        final scriptable = ScriptableTimeToWords(data);

        // Test every 5 minutes (since scriptable data is 5-minute based)
        for (int h = 0; h < 24; h++) {
          for (int m = 0; m < 60; m += 5) {
            final time = DateTime(2024, 1, 1, h, m);
            final expected = scriptable.convert(time);
            final actual = implementation.convert(time);

            expect(
              actual,
              expected,
              reason:
                  'Mismatch at $h:${m.toString().padLeft(2, "0")} for $code',
            );
          }
        }
      });
    });
  });
}
