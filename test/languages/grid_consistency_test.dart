import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/utils/grid_validator.dart';
import 'package:wordclock/languages/all.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';

void main() {
  group('Grid Consistency Tests', () {
    for (final lang in WordClockLanguages.all) {
      group(
        'Language: ${lang.displayName} (${lang.id})',
        () {
          if (lang.defaultGrid != null) {
            test('defaultGrid valid', () {
              _validateGrid(lang, lang.defaultGrid!);
            });
          }

          if (lang.timeCheckGrid != null) {
            test(
              'timeCheckGrid valid',
              () {
                _validateGrid(lang, lang.timeCheckGrid!);
              },
              skip: (lang.id == 'E2')
                  ? 'Fix padding in E2 timeCheckGrid'
                  : null,
            );
          }
        },
        skip: () {
          if (lang.id == 'RO') return 'Fix grid issues for RO';
          if (lang.id == 'ES') return 'Fix invalid word order for ES';
          if (lang.id == 'D3') return 'Fix invalid word order for D3';
          if (lang.id == 'SE') return 'Fix invalid word order for SE';
          if (lang.id == 'RU') return 'Fix invalid word order for RU';
          if (lang.id == 'PL') return 'Fix invalid word order for PL';
          if (lang.id == 'PE') return 'Fix invalid word order for PE';
          if (lang.id == 'IT') return 'Fix invalid word order for IT';
          return null;
        }(),
      );
    }
  });
}

void _validateGrid(WordClockLanguage lang, WordGrid grid) {
  final issues = GridValidator.validate(grid, lang);
  if (issues.isNotEmpty) {
    fail('Grid validation failed for ${lang.id}:\n${issues.join('\n')}');
  }
}
