import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/time_to_words.dart';
import 'package:wordclock/generator/utils/grid_validator.dart';
import 'package:wordclock/languages/all.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import '../../bin/utils/utils.dart'; // For printColoredGrid

void main() {
  group('Grid Consistency Tests', () {
    for (final lang in WordClockLanguages.all) {
      group('Language: ${lang.displayName} (${lang.id})', () {
        final defaultGrid = lang.defaultGridRef;
        if (defaultGrid != null) {
          test('defaultGrid valid', () {
            _validateGrid(
              lang,
              defaultGrid.grid,
              timeToWords: defaultGrid.timeToWords,
            );
          });

          test('defaultGrid size is 11x10', () {
            expect(defaultGrid.grid.width, 11);
            expect(defaultGrid.grid.height, 10);
          });
        }

        final timeCheckGrid = lang.referenceGridRef;
        if (timeCheckGrid != null) {
          test('timeCheckGrid valid', () {
            _validateGrid(
              lang,
              timeCheckGrid.grid,
              timeToWords: timeCheckGrid.timeToWords,
            );
          });
        }
      });
    }
  });
}

void _validateGrid(
  WordClockLanguage lang,
  WordGrid grid, {
  TimeToWords? timeToWords,
}) {
  final issues = GridValidator.validate(grid, lang, timeToWords: timeToWords);
  if (issues.isNotEmpty) {
    fail(
      'Grid validation failed for ${lang.id}:\n${formatGrid(grid)}\n${issues.join('\n')}',
    );
  }
}
