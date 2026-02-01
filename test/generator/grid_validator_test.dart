import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/utils/grid_validator.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/languages/english.dart';
import 'package:wordclock/logic/english_time_to_word.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/time_to_words.dart';

class GridValidatorTestHelper {
  static WordClockGrid createMockGrid(TimeToWords timeToWords) {
    return WordClockGrid(
      isDefault: true,
      timeToWords: timeToWords,
      grid: WordGrid(width: 1, cells: []), // Placeholder
    );
  }
}

void main() {
  group('GridValidator', () {
    test('validates valid grid correctly', () {
      // Create a simple valid grid for English
      final grid = WordGrid.fromLetters(
        width: 11,
        letters:
            "ITEISDTENLF"
            "ARQUARTERFM"
            "TWENTYCFIVE"
            "TOHALFCPAST"
            "TWELVEEIGHT"
            "FIVETWONINE"
            "MSEVENEONEM"
            "ELEVENFTENA"
            "CSIXPTHREED"
            "FOURDO'CLOCK",
      );

      final issues = GridValidator.validate(grid, englishLanguage);
      expect(issues, isEmpty);
    });

    test('reports missing atoms', () {
      // Create a grid missing "TEN"
      // English grid has "TEN" at line 1 ("ITEISDTENLF") and line 8 ("ELEVENFTENA")
      // We must remove BOTH
      final grid = WordGrid.fromLetters(
        width: 11,
        letters:
            "ITEISDXYZLF" // TEN -> XYZ
            "ARQUARTERFM"
            "TWENTYCFIVE"
            "TOHALFCPAST"
            "TWELVEEIGHT"
            "FIVETWONINE"
            "MSEVENEONEM"
            "ELEVENFXYZA" // TEN -> XYZ
            "CSIXPTHREED"
            "FOURDO'CLOCK",
      );

      final issues = GridValidator.validate(grid, englishLanguage);
      expect(issues, contains(matches(r'Missing atom "TEN"')));
    });

    test('validates padding correctly', () {
      // Custom language that requires padding
      final customLanguage = WordClockLanguage(
        id: 'TEST',
        languageCode: 'en-test',
        displayName: 'Test',
        grids: [
          GridValidatorTestHelper.createMockGrid(ReferenceEnglishTimeToWords()),
        ],
        requiresPadding: true,
      );

      // Create a grid where "FIVE" and "O'CLOCK" are adjacent on the same row.
      // Expected phrase: "IT IS FIVE O'CLOCK"
      final grid = WordGrid.fromLetters(
        width: 20, // Wide enough
        letters:
            "ITISFIVEO'CLOCKXXXXX", // "FIVE" and "O'CLOCK" constitute a padding violation
        mergeApostrophes: false,
      );

      final issues = GridValidator.validate(grid, customLanguage);

      expect(
        issues,
        contains(
          matches(
            r"No padding/newline between .FIVE. and .O'CLOCK. in grid \(at 05:00\).*",
          ),
        ),
      );
    });
  });

  group('GridValidator.canPlaceAfter', () {
    test('allows placement on different rows', () {
      expect(
        GridValidator.canPlaceAfter(
          prevEndRow: 0,
          prevEndCol: 5,
          currStartRow: 1,
          currStartCol: 0,
          requiresPadding: true,
        ),
        isTrue,
      );
    });

    test('allows placement with gap on same row', () {
      expect(
        GridValidator.canPlaceAfter(
          prevEndRow: 0,
          prevEndCol: 5,
          currStartRow: 0,
          currStartCol: 7, // Gap of 1 (index 6 is empty)
          requiresPadding: true,
        ),
        isTrue,
      );
    });

    test(
      'disallows placement without gap on same row when padding required',
      () {
        expect(
          GridValidator.canPlaceAfter(
            prevEndRow: 0,
            prevEndCol: 5,
            currStartRow: 0,
            currStartCol: 6, // Adjacent!
            requiresPadding: true,
          ),
          isFalse,
        );
      },
    );

    test(
      'allows placement without gap on same row when padding NOT required',
      () {
        expect(
          GridValidator.canPlaceAfter(
            prevEndRow: 0,
            prevEndCol: 5,
            currStartRow: 0,
            currStartCol: 6,
            requiresPadding: false,
          ),
          isTrue,
        );
      },
    );

    test('disallows backward placement on same row', () {
      expect(
        GridValidator.canPlaceAfter(
          prevEndRow: 0,
          prevEndCol: 5,
          currStartRow: 0,
          currStartCol: 3,
          requiresPadding: false,
        ),
        isFalse,
      );
    });

    test('disallows backward placement on previous row', () {
      expect(
        GridValidator.canPlaceAfter(
          prevEndRow: 1,
          prevEndCol: 5,
          currStartRow: 0,
          currStartCol: 3,
          requiresPadding: false,
        ),
        isFalse,
      );
    });
  });

  group('GridValidator.hasSeparation', () {
    test('allows separation on different rows', () {
      expect(
        GridValidator.hasSeparation(
          word1Row: 0,
          word1StartCol: 0,
          word1EndCol: 5,
          word2Row: 1,
          word2StartCol: 0,
          word2EndCol: 5,
          requiresPadding: true,
        ),
        isTrue,
      );
    });

    test('allows separation with gap', () {
      expect(
        GridValidator.hasSeparation(
          word1Row: 0,
          word1StartCol: 0,
          word1EndCol: 5,
          word2Row: 0,
          word2StartCol: 7,
          word2EndCol: 10,
          requiresPadding: true,
        ),
        isTrue,
        reason: 'Gap between 5 and 7 is index 6, which is 1 cell',
      );
    });

    test('disallows adjacent words when padding required', () {
      expect(
        GridValidator.hasSeparation(
          word1Row: 0,
          word1StartCol: 0,
          word1EndCol: 5,
          word2Row: 0,
          word2StartCol: 6,
          word2EndCol: 10,
          requiresPadding: true,
        ),
        isFalse,
      );
    });
  });
}
