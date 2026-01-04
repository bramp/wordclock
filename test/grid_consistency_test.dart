import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/languages/all.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';

void main() {
  group('Grid Consistency Tests', () {
    for (final lang in WordClockLanguages.all) {
      group('Language: ${lang.displayName} (${lang.id})', () {
        if (lang.defaultGrid != null) {
          test('defaultGrid contains all possible times', () {
            _checkGrid(lang, lang.defaultGrid!);
          });
        }

        if (lang.timeCheckGrid != null) {
          test('timeCheckGrid contains all possible times', () {
            _checkGrid(lang, lang.timeCheckGrid!);
          });
        }
      });
    }
  });
}

void _checkGrid(WordClockLanguage lang, WordGrid grid) {
  for (int h = 0; h < 24; h++) {
    for (int m = 0; m < 60; m += lang.minuteIncrement) {
      final time = DateTime(2026, 1, 1, h, m);
      final phrase = lang.timeToWords.convert(time);
      if (phrase.isEmpty) continue;

      try {
        final indices = grid.getIndices(phrase);
        expect(
          indices,
          isNotEmpty,
          reason:
              'Time ${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} '
              '("$phrase") produced no indices in the grid.',
        );
      } catch (e) {
        fail(
          'Failed at ${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}: "$phrase"\n$e',
        );
      }
    }
  }
}
