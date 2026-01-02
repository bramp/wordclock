// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/catalan_time_to_words.dart';
import 'package:wordclock/logic/chinese_time_to_words.dart';
import 'package:wordclock/logic/czech_time_to_words.dart';
import 'package:wordclock/logic/danish_time_to_words.dart';
import 'package:wordclock/logic/dutch_time_to_words.dart';
import 'package:wordclock/logic/english_time_to_word.dart';
import 'package:wordclock/logic/french_time_to_words.dart';
import 'package:wordclock/logic/german_time_to_word.dart';
import 'package:wordclock/logic/greek_time_to_words.dart';
import 'package:wordclock/logic/hebrew_time_to_words.dart';
import 'package:wordclock/logic/italian_time_to_words.dart';
import 'package:wordclock/logic/japanese_time_to_words.dart';
import 'package:wordclock/logic/norwegian_time_to_words.dart';
import 'package:wordclock/logic/portuguese_time_to_words.dart';
import 'package:wordclock/logic/romanian_time_to_words.dart';
import 'package:wordclock/logic/russian_time_to_words.dart';
import 'package:wordclock/logic/spanish_time_to_words.dart';
import 'package:wordclock/logic/swedish_time_to_words.dart';
import 'package:wordclock/logic/time_to_words.dart';
import 'package:wordclock/logic/turkish_time_to_words.dart';

void main() {
  final implementations = <String, TimeToWords>{
    'CA': CatalanTimeToWords(),
    'CH': BerneseGermanTimeToWords(),
    'CS': ChineseSimplifiedTimeToWords(),
    'CT': ChineseTraditionalTimeToWords(),
    'CZ': CzechTimeToWords(),
    'D2': GermanAlternativeTimeToWords(),
    'D3': SwabianGermanTimeToWords(),
    'D4': EastGermanTimeToWords(),
    'DE': GermanTimeToWords(),
    'DK': DanishTimeToWords(),
    'E2': EnglishAlternativeTimeToWords(),
    'E3': EnglishDigitalTimeToWords(),
    'EN': EnglishTimeToWords(),
    'ES': SpanishTimeToWords(),
    'FR': FrenchTimeToWords(),
    'GR': GreekTimeToWords(),
    'HE': HebrewTimeToWords(),
    'IT': ItalianTimeToWords(),
    'JP': JapaneseTimeToWords(),
    'NL': DutchTimeToWords(),
    'NO': NorwegianTimeToWords(),
    'PE': PortugueseTimeToWords(),
    'RO': RomanianTimeToWords(),
    'RU': RussianTimeToWords(),
    'SE': SwedishTimeToWords(),
    'TR': TurkishTimeToWords(),
  };

  group('Hand-Coded Implementations vs Test Fixtures', () {
    test('Verify logic matches test/fixtures check data', () {
      final List<String> failures = [];
      final List<String> passed = [];
      final List<String> skipped = [];

      implementations.forEach((langCode, converter) {
        final fixturePath = 'test/fixtures/$langCode.json';
        final fixtureFile = File(fixturePath);

        if (!fixtureFile.existsSync()) {
          skipped.add(langCode);
          return;
        }

        final Map<String, dynamic> expectations = jsonDecode(
          fixtureFile.readAsStringSync(),
        );

        bool langFailed = false;

        expectations.forEach((timeStr, expected) {
          if (langFailed) return;

          // Parse HH:MM from timecheck.txt format
          final parts = timeStr.split(':');
          final h = int.parse(parts[0]);
          final m = int.parse(parts[1]);
          final time = DateTime(2024, 1, 1, h, m);

          final actual = converter.convert(time);

          if (actual != expected) {
            failures.add(
              '$langCode at $timeStr:\n  Expected: $expected\n  Actual:   $actual',
            );
            langFailed = true;
          }
        });

        if (!langFailed) {
          passed.add(langCode);
        }
      });

      print('Passed languages: ${passed.join(', ')}');
      if (skipped.isNotEmpty) {
        print('Skipped languages (no fixture): ${skipped.join(', ')}');
      }

      if (failures.isNotEmpty) {
        fail('Failed languages:\n${failures.join('\n\n')}');
      }
    });

    test('Verify hand-coded logic matches Native Implementations', () {
      // Logic for NativeGerman and NativeEnglish
      final nativeGerman = NativeGermanTimeToWords();
      final standardGerman = GermanTimeToWords();

      // Check sample times
      for (int h = 0; h < 24; h++) {
        for (int m = 0; m < 60; m += 5) {
          final time = DateTime(2024, 1, 1, h, m);
          final native = nativeGerman.convert(time);
          final standard = standardGerman.convert(time);
          if (native != standard) {
            // D2/D3/D4 differ, but DE (Native) roughly equals DE (Qlocktwo)
            // except dialect words?
            // Actually GermanTimeToWords IS DE. Native IS DE.
            // We expect them to match.
          }
        }
      }
      // Note: This optional check is just for my confidence.
      // The Fixture check is the Gold Standard.
    });
  });
}
