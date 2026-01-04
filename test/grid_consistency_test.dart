import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/utils/word_clock_utils.dart';
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
  WordClockUtils.forEachTime(lang, (time, phrase) {
    if (phrase.isEmpty) return;

    try {
      final indices = grid.getIndices(phrase);
      expect(
        indices,
        isNotEmpty,
        reason:
            'Time ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} '
            '("$phrase") produced no indices in the grid.',
      );
    } catch (e) {
      fail(
        'Failed at ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}: "$phrase"\n$e',
      );
    }
  });
}
