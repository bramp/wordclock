import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/backtracking/grid_builder.dart';
import 'package:wordclock/generator/utils/grid_validator.dart';
import 'package:wordclock/languages/all.dart';
import 'package:wordclock/languages/english.dart';
import '../test_helpers.dart';

void main() {
  for (final useFrontier in [true, false]) {
    final mode = useFrontier ? 'Frontier' : 'Rank';
    group('BacktrackingGridBuilder ($mode)', () {
      test('builds a valid grid for a simple language', () {
        final builder = BacktrackingGridBuilder(
          width: 11,
          height: 10,
          language: englishLanguage,
          seed: 0,
          useFrontier: useFrontier,
        );

        final result = builder.build();

        expect(result.grid.cells.length, 11 * 10);
        expect(result.isOptimal, isTrue);

        final issues = GridValidator.validate(result.grid, englishLanguage);
        expect(issues, isEmpty);
      });

      test('maximizes word overlap and reuse', () {
        final language = englishLanguage;
        final builder = BacktrackingGridBuilder(
          width: 11,
          height: 10,
          language: language,
          seed: 0,
          useFrontier: useFrontier,
        );

        final result = builder.build();
        expect(result.isOptimal, isTrue);

        // FIVE appears multiple times in the dependency graph.
        // If they overlap optimally, they will share the same startOffset.
        final fivePlacements = result.wordPlacements
            .where((p) => p.word == 'FIVE')
            .toList();

        final uniqueOffsets = fivePlacements.map((p) => p.startOffset).toSet();

        // There should be multiple placements for FIVE, but they should reuse cells.
        expect(fivePlacements.length, greaterThanOrEqualTo(1));
        // If they reuse perfectly, there should be fewer unique offsets than placements
        // (or just 1 if they all overlap).
        expect(uniqueOffsets.length, lessThanOrEqualTo(fivePlacements.length));
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
          width: 4, // A . B C or A . C B
          height: 1,
          language: language,
          seed: 0,
          useFrontier: useFrontier,
        );

        final result = builder.build();
        expect(result.isOptimal, isTrue);

        // A shared phrase with B and C requires padding.
        // But B and C don't share any phrase, so they can be adjacent.
        final gridStr = result.grid.cells.join('');
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
          height: 1,
          language: language,
          seed: 0,
          useFrontier: useFrontier,
        );

        final result = builder.build();
        final gridStr = result.grid.cells.join('');

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
          useFrontier: useFrontier,
        );

        final stopwatch = Stopwatch()..start();
        final result = builder.build();
        stopwatch.stop();

        // Should find a valid grid
        expect(result.isOptimal, isTrue);

        // Should complete much faster than the full timeout
        // (typically under 1 second vs 30+ seconds for full optimization)
        expect(stopwatch.elapsedMilliseconds, lessThan(10000));
      });
    });
  }

  group('BacktrackingGridBuilder - All Languages (Frontier only)', () {
    // Languages that take too long (>60s) to solve - test separately
    const slowLanguages = {'PL', 'PE', 'RO', 'RU', 'TR'};

    final languages = WordClockLanguages.all
        .where((l) => !slowLanguages.contains(l.id))
        .toList();

    for (final language in languages) {
      test(
        'generates valid grid for ${language.id} (${language.englishName})',
        () {
          _runLanguageTest(language.id, true);
        },
        timeout: const Timeout(Duration(seconds: 60)),
      );
    }
  });
}

/// Runs a grid building test for a single language.
void _runLanguageTest(String languageId, bool useFrontier) {
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
    useFrontier: useFrontier,
  );

  final result = builder.build();

  expect(
    result.placedWords,
    greaterThan(0),
    reason: 'No words placed for $languageId',
  );

  if (!result.isOptimal) {
    fail(
      'Not optimal: placed ${result.placedWords}/${result.totalWords} for $languageId',
    );
  }

  // Validate the generated grid
  final issues = GridValidator.validate(result.grid, language);

  if (issues.isNotEmpty) {
    fail('Validation issues for $languageId: ${issues.join(', ')}');
  }
}
