import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/utils/grid_validator.dart';
import 'package:wordclock/languages/all.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';

void main() {
  group('Grid Consistency Tests', () {
    for (final lang in WordClockLanguages.all) {
      group('Language: ${lang.displayName} (${lang.id})', () {
        if (lang.defaultGrid != null) {
          test(
            'defaultGrid valid',
            () {
              _validateGrid(lang, lang.defaultGrid!);
            },
            skip: ['PL'].contains(lang.id) ? 'Needs fixing' : null,
          );

          test(
            'defaultGrid size is 11x10',
            () {
              expect(lang.defaultGrid!.width, 11);
              expect(lang.defaultGrid!.height, 10);
            },
            skip: ['PL', 'PE', 'RU', 'RO'].contains(lang.id)
                ? 'Needs fixing to fit 11x10'
                : null,
          );
        }

        if (lang.timeCheckGrid != null) {
          test('timeCheckGrid valid', () {
            _validateGrid(lang, lang.timeCheckGrid!);
          });
        }
      });
    }
  });
}

void _validateGrid(WordClockLanguage lang, WordGrid grid) {
  final issues = GridValidator.validate(grid, lang);
  if (issues.isNotEmpty) {
    fail('Grid validation failed for ${lang.id}:\n${issues.join('\n')}');
  }
}
