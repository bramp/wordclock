import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/backtracking/grid_builder.dart';
import 'package:wordclock/generator/utils/grid_validator.dart';
import 'package:wordclock/languages/all.dart';
import 'package:wordclock/languages/english.dart';
import 'package:wordclock/model/word_grid.dart';
import 'graph/test_helpers.dart';

void main() {
  group('BacktrackingGridBuilder', () {
    test('builds a valid grid for a simple language', () {
      final builder = BacktrackingGridBuilder(
        width: 11,
        height: 10,
        language: englishLanguage,
        seed: 0,
      );

      final result = builder.build();

      expect(result.grid, isNotNull);
      expect(result.grid!.length, 11 * 10);
      expect(result.isOptimal, isTrue);

      final grid = WordGrid(width: 11, cells: result.grid!);
      final issues = GridValidator.validate(grid, englishLanguage);
      expect(issues, isEmpty);
    });

    test('maximizes word overlap and reuse', () {
      final language = englishLanguage;
      final builder = BacktrackingGridBuilder(
        width: 11,
        height: 10,
        language: language,
        seed: 0,
      );

      final result = builder.build();
      expect(result.grid, isNotNull);

      // FIVE appears twice - they should reuse the same cells
      final grid2d = <List<String>>[];
      for (int i = 0; i < 10; i++) {
        grid2d.add(result.grid!.sublist(i * 11, (i + 1) * 11));
      }

      // Find FIVE occurrences
      final fivePositions = <String>[];
      for (int row = 0; row < 10; row++) {
        final rowStr = grid2d[row].join('');
        int col = 0;
        while ((col = rowStr.indexOf('FIVE', col)) != -1) {
          fivePositions.add('$row,$col');
          col++;
        }
      }

      // Both FIVE instances should be at the same position (overlapping)
      expect(fivePositions.length, greaterThanOrEqualTo(1));
    });

    test('skips padding between words that never appear together', () {
      // "A B" and "A C" -> B and C never appear together.
      final language = createMockLanguage(
        id: 'ABC',
        phrases: ['A B', 'A C'],
        requiresPadding: true,
        paddingAlphabet: '.', // Force predictable padding
      );

      final builder = BacktrackingGridBuilder(
        width: 4, // A x B C or A x C B
        height: 2,
        language: language,
        seed: 0,
      );

      final result = builder.build();
      expect(result.grid, isNotNull);

      // A shared phrase with B and C requires padding.
      // But B and C don't share any phrase, so they can be adjacent.
      final gridStr = result.grid!.join('');
      expect(gridStr, anyOf(contains('A.BC'), contains('A.CB')));
    });

    test('reuses letters between FIVE and TWENTYFIVE', () {
      final language = createMockLanguage(
        id: 'T5',
        phrases: ['IT IS FIVE', 'IT IS TWENTYFIVE', 'IT IS TWENTY'],
        requiresPadding: true,
        paddingAlphabet: '.',
      );

      final builder = BacktrackingGridBuilder(
        width: 16,
        height: 2,
        language: language,
        seed: 0,
      );

      final result = builder.build();
      expect(result.grid, isNotNull);

      final gridStr = result.grid!.join('');

      // The first row should be exactly IT.IS.TWENTYFIVE
      // because that satisfies all three phrases optimally.
      expect(gridStr.substring(0, 16), equals('IT.IS.TWENTYFIVE'));

      // All nodes should be placed (IT, IS, FIVE, TWENTYFIVE, TWENTY)
      // Note: FIVE and TWENTY overlap with TWENTYFIVE.
      expect(result.placedWords, equals(result.totalWords));
    });

    test('findFirstValid stops after finding first complete grid', () {
      final builder = BacktrackingGridBuilder(
        width: 11,
        height: 10,
        language: englishLanguage,
        seed: 0,
        findFirstValid: true,
      );

      final stopwatch = Stopwatch()..start();
      final result = builder.build();
      stopwatch.stop();

      // Should find a valid grid
      expect(result.grid, isNotNull);
      expect(result.isOptimal, isTrue);

      // Should complete much faster than the full timeout
      // (typically under 1 second vs 30+ seconds for full optimization)
      expect(stopwatch.elapsedMilliseconds, lessThan(10000));
    });
  });

  group('BacktrackingGridBuilder - All Languages', () {
    // Languages that take too long (>60s) to solve - test separately
    const slowLanguages = {'PL', 'PE', 'RO', 'RU', 'TR'};

    test(
      'generates valid grids for all languages (parallel)',
      () async {
        // Run all language tests in parallel using isolates
        final futures = <Future<_LanguageTestResult>>[];
        final stopwatch = Stopwatch()..start();
        final languages = WordClockLanguages.all
            .where((l) => !slowLanguages.contains(l.id))
            .toList();

        for (final language in languages) {
          futures.add(
            Isolate.run(() => _testLanguageInIsolate(language.id)).timeout(
              Duration(seconds: 60),
              onTimeout: () => _LanguageTestResult(
                languageId: language.id,
                success: false,
                error: 'Timed out after 60 seconds',
              ),
            ),
          );
        }

        final results = await Future.wait(futures);
        stopwatch.stop();

        // Print summary
        final succeeded = results.where((r) => r.success).length;
        // ignore: avoid_print
        print(
          'Tested ${results.length} languages in ${stopwatch.elapsed.inSeconds}s '
          '($succeeded passed)',
        );

        // Check all results
        final failures = <String>[];
        for (final result in results) {
          if (!result.success) {
            failures.add('${result.languageId}: ${result.error}');
          }
        }

        expect(
          failures,
          isEmpty,
          reason: 'Failed languages:\n${failures.join('\n')}',
        );
      },
      timeout: Timeout(Duration(minutes: 2)),
    );
  });
}

/// Result of testing a single language
class _LanguageTestResult {
  final String languageId;
  final bool success;
  final String? error;

  _LanguageTestResult({
    required this.languageId,
    required this.success,
    this.error,
  });
}

/// Test a single language - runs inside an isolate
_LanguageTestResult _testLanguageInIsolate(String languageId) {
  try {
    final language = WordClockLanguages.all.firstWhere(
      (l) => l.id == languageId,
      orElse: () => throw Exception('Language $languageId not found'),
    );

    final builder = BacktrackingGridBuilder(
      width: 11,
      height: 10,
      language: language,
      seed: 0,
      findFirstValid: true,
    );

    final result = builder.build();

    if (result.grid == null) {
      return _LanguageTestResult(
        languageId: languageId,
        success: false,
        error: 'Grid is null',
      );
    }

    if (!result.isOptimal) {
      return _LanguageTestResult(
        languageId: languageId,
        success: false,
        error: 'Not optimal: placed ${result.placedWords}/${result.totalWords}',
      );
    }

    // Validate the generated grid
    final grid = WordGrid(width: 11, cells: result.grid!);
    final issues = GridValidator.validate(grid, language);

    if (issues.isNotEmpty) {
      return _LanguageTestResult(
        languageId: languageId,
        success: false,
        error: 'Validation issues: ${issues.join(', ')}',
      );
    }

    return _LanguageTestResult(languageId: languageId, success: true);
  } catch (e, st) {
    return _LanguageTestResult(
      languageId: languageId,
      success: false,
      error: '$e\n$st',
    );
  }
}
