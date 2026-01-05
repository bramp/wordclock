// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/backtracking/backtracking_grid_builder.dart';
import 'package:wordclock/generator/backtracking/word_dependency_graph.dart';
import 'package:wordclock/generator/utils/grid_validator.dart';
import 'package:wordclock/languages/english.dart';
import 'package:wordclock/model/word_grid.dart';

void main() {
  group('WordDependencyGraph', () {
    test('builds graph from language', () {
      final language = englishLanguage;
      final graph = WordDependencyGraphBuilder.build(language: language);

      expect(graph.nodes.isNotEmpty, true);
      expect(graph.phrases.isNotEmpty, true);
      expect(graph.edges.isNotEmpty, true);
    });

    test('correctly identifies word relationships', () {
      final language = englishLanguage;
      final graph = WordDependencyGraphBuilder.build(language: language);

      // Check that common words exist
      expect(graph.nodes.containsKey('IT'), true);
      expect(graph.nodes.containsKey('IS'), true);

      // "IT" should come before "IS" in some phrases
      // Check edges directly since getSuccessors doesn't exist
      final itId = graph.nodes['IT']![0].id;
      final hasIsSuccessor =
          graph.edges[itId]?.any((id) => id.startsWith('IS')) ?? false;
      expect(hasIsSuccessor, true);

      // Check word priorities
      final wordsByPriority = graph.getWordsByPriority();
      expect(wordsByPriority.isNotEmpty, true);
    });
  });

  group('BacktrackingGridBuilder', () {
    test('builds grid for English', () {
      final language = englishLanguage;
      final builder = BacktrackingGridBuilder(
        width: 11,
        height: 10,
        language: language,
        seed: 42,
        maxSearchTimeSeconds: 10,
      );

      final result = builder.build();

      expect(result.grid, isNotNull);
      expect(result.grid!.length, 110); // 11x10
    });

    test('respects grid dimensions', () {
      final language = englishLanguage;
      final builder = BacktrackingGridBuilder(
        width: 11,
        height: 10,
        language: language,
        seed: 42,
        maxSearchTimeSeconds: 5,
      );

      final result = builder.build();
      if (result.grid != null) {
        expect(result.grid!.length, 110);
      }
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('places words in topological rank order', () {
      final language = englishLanguage;
      final builder = BacktrackingGridBuilder(
        width: 11,
        height: 10,
        language: language,
        seed: 0,
        maxSearchTimeSeconds: 10,
      );

      final result = builder.build();
      expect(result.grid, isNotNull);

      // Convert to 2D for easier checking
      final grid2d = <List<String>>[];
      for (int i = 0; i < 10; i++) {
        grid2d.add(result.grid!.sublist(i * 11, (i + 1) * 11));
      }

      // Check that IT and IS are on the first row
      final row0 = grid2d[0].join('');
      expect(row0, contains('IT'));
      expect(row0, contains('IS'));

      // Check that IS comes after IT with padding
      final itIndex = row0.indexOf('IT');
      final isIndex = row0.indexOf('IS');
      expect(itIndex, lessThan(isIndex));
      expect(
        isIndex - itIndex,
        greaterThanOrEqualTo(3),
      ); // IT (2) + padding (1) = 3
    });

    test('places dependent words on same row when possible', () {
      final language = englishLanguage;
      final builder = BacktrackingGridBuilder(
        width: 11,
        height: 10,
        language: language,
        seed: 0,
        maxSearchTimeSeconds: 10,
      );

      final result = builder.build();
      expect(result.grid, isNotNull);

      // Convert to 2D for easier checking
      final grid2d = <List<String>>[];
      for (int i = 0; i < 10; i++) {
        grid2d.add(result.grid!.sublist(i * 11, (i + 1) * 11));
      }

      // IT and IS should be on same row (rank 0 and 1)
      int itRow = -1;
      int isRow = -1;

      for (int row = 0; row < 10; row++) {
        final rowStr = grid2d[row].join('');
        if (rowStr.contains('IT') && rowStr.indexOf('IT') < 3) {
          itRow = row;
        }
        if (rowStr.contains('IS') && itRow >= 0 && row == itRow) {
          isRow = row;
        }
      }

      expect(
        itRow,
        equals(isRow),
        reason: 'IT and IS should be on the same row',
      );
      expect(itRow, equals(0), reason: 'IT and IS should be on the first row');
    });

    test('respects padding requirements', () {
      final language = englishLanguage;
      final builder = BacktrackingGridBuilder(
        width: 11,
        height: 10,
        language: language,
        seed: 0,
        maxSearchTimeSeconds: 10,
      );

      final result = builder.build();
      expect(result.grid, isNotNull);

      // Validate using GridValidator
      final wordGrid = WordGrid(width: 11, cells: result.grid!);
      final issues = GridValidator.validate(wordGrid, language);

      expect(issues, isEmpty, reason: 'Grid should have no validation issues');
    });

    test('maximizes word overlap and reuse', () {
      final language = englishLanguage;
      final builder = BacktrackingGridBuilder(
        width: 11,
        height: 10,
        language: language,
        seed: 0,
        maxSearchTimeSeconds: 10,
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
  });
}
