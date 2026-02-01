import 'package:flutter_test/flutter_test.dart';

import '../../bin/utils/language_file_updater.dart';
import '../generator/test_helpers.dart';

void main() {
  group('GridGenerationMetadata', () {
    test('stores all metadata fields', () {
      final metadata = GridGenerationMetadata(
        algorithm: 'Trie',
        seed: 42,
        timestamp: DateTime(2026, 1, 12, 10, 30, 0),
        iterationCount: 1000,
        duration: Duration(milliseconds: 500),
      );

      expect(metadata.algorithm, 'Trie');
      expect(metadata.seed, 42);
      expect(metadata.timestamp, DateTime(2026, 1, 12, 10, 30, 0));
      expect(metadata.iterationCount, 1000);
      expect(metadata.duration, Duration(milliseconds: 500));
    });
  });

  group('generateDefaultGridCode', () {
    test('generates code with @generated markers', () {
      final grid = WordGrid.fromLetters(width: 5, letters: 'HELLOWORLD');
      final metadata = GridGenerationMetadata(
        algorithm: 'Trie',
        seed: 0,
        timestamp: DateTime(2026, 1, 12, 10, 30, 0),
        iterationCount: 100,
        duration: Duration(milliseconds: 50),
      );
      final lang = createMockLanguage(paddingAlphabet: 'X');

      final code = generateGridCode(lang, grid, metadata);

      expect(code, contains('// @generated begin - do not edit manually'));
      expect(code, contains('// @generated end'));
      expect(code, contains('// Algorithm: Trie'));
      expect(code, contains('// Seed: 0'));
      expect(code, contains('// Iterations: 100, Duration: 50ms'));
      expect(code, contains("WordClockGrid("));
      expect(code, contains("isDefault: true,"));
      expect(code, contains("paddingAlphabet: 'X'"));
      expect(code, contains("width: 5,"));
      expect(code, contains("'HELLO'"));
      expect(code, contains("'WORLD'"));
    });

    test('escapes single quotes in grid letters', () {
      // WordGrid merges apostrophes with previous char, so O'CLOCK becomes 6 cells
      final grid = WordGrid.fromLetters(width: 6, letters: "O'CLOCK");
      final metadata = GridGenerationMetadata(
        algorithm: 'Test',
        seed: 0,
        timestamp: DateTime(2026, 1, 1),
        iterationCount: 1,
        duration: Duration.zero,
      );
      final lang = createMockLanguage();
      final code = generateGridCode(lang, grid, metadata);

      // The grid escapes apostrophes in output
      expect(code, contains(r"O\'CLOCK"));
    });
  });

  group('_replaceDefaultGridForLanguage (via updateLanguageFileContent)', () {
    final testGrid = WordGrid.fromLetters(width: 5, letters: 'NEWGDRIDAG');
    final testMetadata = GridGenerationMetadata(
      algorithm: 'Test',
      seed: 99,
      timestamp: DateTime(2026, 1, 12),
      iterationCount: 50,
      duration: Duration(milliseconds: 25),
    );

    test('replaces plain defaultGrid in single-language file', () {
      const originalContent = '''
import 'package:wordclock/languages/language.dart';

final testLanguage = WordClockLanguage(
  id: 'TE',
  languageCode: 'te-ST',
  displayName: 'Test',
  defaultGrid: WordGrid.fromLetters(
    width: 5,
    letters:
        "OLDGR"
        "IDABC",
  ),
  minuteIncrement: 5,
);
''';

      final result = updateLanguageFileContent(
        originalContent,
        createMockLanguage(id: 'TE'),
        testGrid,
        testMetadata,
      );

      expect(result, isNotNull);
      expect(result, contains('// @generated begin'));
      expect(result, contains('// @generated end'));
      expect(result, contains('// Algorithm: Test'));
      expect(result, contains('// Seed: 99'));
      expect(result, contains("'NEWGD'"));
      expect(result, contains("'RIDAG'"));
      expect(result, isNot(contains('OLDGR')));
      // Verify structure is preserved
      expect(result, contains("id: 'TE'"));
      expect(result, contains('minuteIncrement: 5'));
    });

    test('replaces WordClockGrid with isDefault: true in grids list', () {
      const originalContent = '''
final testLanguage = WordClockLanguage(
  id: 'TE',
  languageCode: 'te-ST',
  displayName: 'Test',
  grids: [
    WordClockGrid(
      isDefault: true,
      timeToWords: TestTimeToWords(),
      paddingAlphabet: 'X',
      grid: WordGrid.fromLetters(
        width: 3,
        letters: "OLD",
      ),
    ),
    WordClockGrid(
      isReference: true,
      timeToWords: TestTimeToWords(),
      paddingAlphabet: 'X',
      grid: WordGrid.fromLetters(
        width: 3,
        letters: "CHK",
      ),
    ),
  ],
  minuteIncrement: 5,
);
''';

      final result = updateLanguageFileContent(
        originalContent,
        createMockLanguage(id: 'TE'),
        testGrid,
        testMetadata,
      );

      expect(result, isNotNull);
      expect(result, contains('// @generated begin'));
      expect(result, contains('isDefault: true'));
      expect(result, contains("'NEWGD'"));
      expect(result, contains("'RIDAG'"));
      expect(result, isNot(contains('"OLD"')));
      // The time check grid should still be there
      expect(result, contains('"CHK"'));
      expect(result, contains('isReference: true'));
    });

    test('replaces WordClockGrid in a complex list structure', () {
      const originalContent = '''
final lang = WordClockLanguage(
  id: 'EN',
  grids: [
    WordClockGrid(
      isDefault: true,
      grid: WordGrid.fromLetters(width: 3, letters: "OLD"),
    ),
    WordClockGrid(
      isReference: true,
      grid: WordGrid.fromLetters(width: 3, letters: "CHK"),
    ),
  ],
);
''';
      final result = updateLanguageFileContent(
        originalContent,
        createMockLanguage(id: 'EN'),
        testGrid,
        testMetadata,
      );

      expect(result, isNotNull);
      expect(result, contains('// @generated begin'));
      expect(result, contains("'NEWGD'"));
      // Check that the second grid is preserved and properly separated
      expect(result, contains('// @generated end,'));
      expect(result, contains('WordClockGrid(\n      isReference: true'));
    });

    test('replaces existing @generated block', () {
      const originalContent = '''
final testLanguage = WordClockLanguage(
  id: 'TE',
  // @generated begin - do not edit manually
  // Generated: 2025-01-01T00:00:00.000000
  // Algorithm: Old
  // Seed: 1
  // Iterations: 10, Duration: 5ms
  defaultGrid: WordGrid.fromLetters(
    width: 5,
    letters:
        'OLDGR'
        'IDOLD'
  ),
  // @generated end
  minuteIncrement: 5,
);
''';

      final result = updateLanguageFileContent(
        originalContent,
        createMockLanguage(id: 'TE'),
        testGrid,
        testMetadata,
      );

      expect(result, isNotNull);
      expect(result, contains('// Algorithm: Test'));
      expect(result, contains('// Seed: 99'));
      expect(result, contains("'NEWGD'"));
      expect(result, isNot(contains('// Algorithm: Old')));
      expect(result, isNot(contains('OLDGR')));
    });

    test('handles multiple languages in same file', () {
      const originalContent = '''
final langOne = WordClockLanguage(
  id: 'L1',
  defaultGrid: WordGrid.fromLetters(
    width: 3,
    letters: "ONEAAA",
  ),
);

final langTwo = WordClockLanguage(
  id: 'L2',
  defaultGrid: WordGrid.fromLetters(
    width: 3,
    letters: "TWOBBB",
  ),
);
''';

      // Update only L2
      final result = updateLanguageFileContent(
        originalContent,
        createMockLanguage(id: 'L2'),
        testGrid,
        testMetadata,
      );

      expect(result, isNotNull);
      // L1 should be unchanged
      expect(result, contains("id: 'L1'"));
      expect(result, contains('ONEAAA'));
      // L2 should be updated
      expect(result, contains("id: 'L2'"));
      expect(result, contains("'NEWGD'"));
      expect(result, isNot(contains('TWOBBB')));
    });

    test('returns null for non-existent language ID', () {
      const originalContent = '''
final testLanguage = WordClockLanguage(
  id: 'TE',
  defaultGrid: WordGrid.fromLetters(width: 3, letters: "ABC"),
);
''';

      final result = updateLanguageFileContent(
        originalContent,
        createMockLanguage(
          id: 'XX',
        ), // Non-existent ID info for matcher (though our function uses language.id)
        testGrid,
        testMetadata,
      );

      expect(result, isNull);
    });

    test('returns null if defaultGrid not found', () {
      const originalContent = '''
final testLanguage = WordClockLanguage(
  id: 'TE',
  displayName: 'Test',
);
''';

      final result = updateLanguageFileContent(
        originalContent,
        createMockLanguage(id: 'TE'),
        testGrid,
        testMetadata,
      );

      expect(result, isNull);
    });

    test('preserves content before and after language block', () {
      const originalContent = '''
// File header comment
import 'package:something/something.dart';

final testLanguage = WordClockLanguage(
  id: 'TE',
  defaultGrid: WordGrid.fromLetters(
    width: 3,
    letters: "OLD",
  ),
);

// Footer comment
void someFunction() {}
''';

      final result = updateLanguageFileContent(
        originalContent,
        createMockLanguage(id: 'TE'),
        testGrid,
        testMetadata,
      );

      expect(result, isNotNull);
      expect(result, contains('// File header comment'));
      expect(result, contains("import 'package:something/something.dart'"));
      expect(result, contains('// Footer comment'));
      expect(result, contains('void someFunction() {}'));
    });

    test('handles grid with special characters', () {
      // WordGrid merges apostrophes with previous char, so O'CLOCK becomes 6 cells
      final gridWithSpecial = WordGrid.fromLetters(
        width: 6,
        letters: "O'CLOCK",
      );

      const originalContent = '''
final testLanguage = WordClockLanguage(
  id: 'TE',
  defaultGrid: WordGrid.fromLetters(
    width: 3,
    letters: "OLD",
  ),
);
''';

      final result = updateLanguageFileContent(
        originalContent,
        createMockLanguage(id: 'TE'),
        gridWithSpecial,
        testMetadata,
      );

      expect(result, isNotNull);
      // The grid should contain the escaped O'CLOCK text
      expect(result, contains(r"O\'CLOCK"));
    });

    test('preserves indentation of next field after first-time insertion', () {
      const originalContent = '''
final testLanguage = WordClockLanguage(
  id: 'TE',
  defaultGrid: WordGrid.fromLetters(
    width: 3,
    letters: "OLD",
  ),
  nextField: 'value',
);
''';

      final result = updateLanguageFileContent(
        originalContent,
        createMockLanguage(id: 'TE'),
        testGrid,
        testMetadata,
      );

      expect(result, isNotNull);
      // The next field should have proper indentation (2 spaces)
      expect(result, contains('  // @generated end,\n  nextField:'));
    });

    test(
      'preserves indentation of next field when replacing @generated block',
      () {
        const originalContent = '''
final testLanguage = WordClockLanguage(
  id: 'TE',
  // @generated begin - do not edit manually
  // Generated: 2025-01-01T00:00:00.000000
  // Algorithm: Old
  // Seed: 1
  // Iterations: 10, Duration: 5ms
  defaultGrid: WordGrid.fromLetters(
    width: 5,
    letters:
        'OLDGR'
        'IDOLD'
  ),
  // @generated end,
  nextField: 'value',
);
''';

        final result = updateLanguageFileContent(
          originalContent,
          createMockLanguage(id: 'TE'),
          testGrid,
          testMetadata,
        );

        expect(result, isNotNull);
        // The next field should have proper indentation (2 spaces) with no extra blank line
        expect(result, contains('  // @generated end,\n  nextField:'));
      },
    );

    test('handles 4-space indentation', () {
      const originalContent = '''
final testLanguage = WordClockLanguage(
    id: 'TE',
    defaultGrid: WordGrid.fromLetters(
        width: 3,
        letters: "OLD",
    ),
    nextField: 'value',
);
''';

      final result = updateLanguageFileContent(
        originalContent,
        createMockLanguage(id: 'TE'),
        testGrid,
        testMetadata,
      );

      expect(result, isNotNull);
      // Should preserve the 4-space indentation for next field
      expect(result, contains('// @generated end,\n    nextField:'));
    });
  });

  group('getAllLanguageIds', () {
    test('returns non-empty list of language IDs', () {
      final ids = getAllLanguageIds();

      expect(ids, isNotEmpty);
      expect(ids, contains('EN')); // English should exist
    });
  });
}
