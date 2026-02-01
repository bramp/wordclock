// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/languages/all.dart';

void main() {
  group('TimeToWords matches fixture', () {
    final testedClasses = <String>{};

    for (final language in WordClockLanguages.all) {
      // Iterate over all grids to find every unique TimeToWords implementation
      for (final grid in language.grids) {
        final converter = grid.timeToWords;
        final className = converter.runtimeType.toString();

        if (testedClasses.contains(className)) {
          continue;
        }
        testedClasses.add(className);

        test('$className (${language.englishName})', () {
          final fixturePath = 'test/fixtures/$className.json';
          final fixtureFile = File(fixturePath);

          if (!fixtureFile.existsSync()) {
            // Since we renamed fixtures to class names, missing file is likely an error or skipped test.
            markTestSkipped('Fixture for $className not found at $fixturePath');
            return;
          }

          final Map<String, dynamic> expectations = jsonDecode(
            fixtureFile.readAsStringSync(),
          );

          expectations.forEach((timeStr, expected) {
            final parts = timeStr.split(':');
            final h = int.parse(parts[0]);
            final m = int.parse(parts[1]);
            final time = DateTime(2024, 1, 1, h, m);

            final actual = converter.convert(time);

            expect(
              actual,
              expected,
              reason:
                  'Mismatch at $timeStr for $className (${language.englishName})',
            );
          });
        });
      }
    }
  });
}
