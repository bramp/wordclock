// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/languages/all.dart';

void main() {
  group('TimeToWords matches fixture', () {
    for (final language in WordClockLanguages.all) {
      final langCode = language.id.toUpperCase();
      final converter = language.timeToWords;

      test('Language $langCode', () {
        final fixturePath = 'test/fixtures/$langCode.json';
        final fixtureFile = File(fixturePath);

        if (!fixtureFile.existsSync()) {
          markTestSkipped('Fixture for $langCode not found at $fixturePath');
          return;
        }

        final Map<String, dynamic> expectations = jsonDecode(
          fixtureFile.readAsStringSync(),
        );

        expectations.forEach((timeStr, expected) {
          // Parse HH:MM from timecheck.txt format
          final parts = timeStr.split(':');
          final h = int.parse(parts[0]);
          final m = int.parse(parts[1]);
          final time = DateTime(2024, 1, 1, h, m);

          final actual = converter.convert(time);

          expect(
            actual,
            expected,
            reason:
                'Mismatch at $timeStr for ${language.englishName} ($langCode)',
          );
        });
      });
    }
  });
}
