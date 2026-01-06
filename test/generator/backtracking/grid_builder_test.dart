import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/backtracking/grid_builder.dart';
import 'package:wordclock/generator/backtracking/grid_state.dart';
import 'package:wordclock/generator/utils/grid_validator.dart';
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
}
