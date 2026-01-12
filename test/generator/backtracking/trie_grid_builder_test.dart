import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/backtracking/trie_grid_builder.dart';
import 'package:wordclock/generator/model/grid_build_result.dart';
import 'package:wordclock/generator/utils/grid_validator.dart';
import '../test_helpers.dart';

void main() {
  group('TrieGridBuilder', () {
    test('solves single word phrase', () {
      // Simplest possible case: one phrase with one word
      final language = createMockLanguage(
        id: 'SIMPLE',
        phrases: ['HELLO'],
        requiresPadding: true,
      );

      final builder = TrieGridBuilder(
        width: 10,
        height: 5,
        language: language,
        seed: 0,
      );

      final result = builder.build();

      expect(result.stopReason, StopReason.completed);
      expect(result.wordPlacements, isNotEmpty);
      expect(result.wordPlacements.first.word, 'HELLO');

      final issues = GridValidator.validate(result.grid, language);
      expect(issues, isEmpty);
    });

    test('solves two word phrase', () {
      // Two words in sequence
      final language = createMockLanguage(
        id: 'TWO',
        phrases: ['HELLO WORLD'],
        requiresPadding: true,
      );

      final builder = TrieGridBuilder(
        width: 15,
        height: 5,
        language: language,
        seed: 0,
      );

      final result = builder.build();

      expect(result.stopReason, StopReason.completed);
      expect(result.wordPlacements.length, 2);

      final words = result.wordPlacements.map((p) => p.word).toSet();
      expect(words, containsAll(['HELLO', 'WORLD']));

      final issues = GridValidator.validate(result.grid, language);
      expect(issues, isEmpty);
    });

    test('solves multiple phrases with shared first word', () {
      // "IT IS ONE" and "IT IS TWO" share "IT IS"
      final language = createMockLanguage(
        id: 'SHARED',
        phrases: ['IT IS ONE', 'IT IS TWO'],
        requiresPadding: true,
      );

      final builder = TrieGridBuilder(
        width: 12,
        height: 5,
        language: language,
        seed: 0,
      );

      final result = builder.build();

      expect(result.stopReason, StopReason.completed);

      final issues = GridValidator.validate(result.grid, language);
      expect(issues, isEmpty);
    });

    test('solves phrases with different first words', () {
      // Different starting words
      final language = createMockLanguage(
        id: 'DIFF',
        phrases: ['ONE TWO', 'THREE FOUR'],
        requiresPadding: true,
      );

      final builder = TrieGridBuilder(
        width: 12,
        height: 5,
        language: language,
        seed: 0,
      );

      final result = builder.build();

      expect(result.stopReason, StopReason.completed);

      final issues = GridValidator.validate(result.grid, language);
      expect(issues, isEmpty);
    });

    test('handles word reuse across phrases', () {
      // "A B" and "C B" - B appears in both but after different words
      // Note: B needs to come after A (at offset >= A.end+2) AND after C (at offset >= C.end+2)
      // The solver currently uses minOffset from the minimum parentEndOffset,
      // which may not satisfy all constraints - this is a known limitation.
      final language = createMockLanguage(
        id: 'REUSE',
        phrases: ['A B', 'C B'],
        requiresPadding: true,
      );

      final builder = TrieGridBuilder(
        width: 10,
        height: 3,
        language: language,
        seed: 0,
      );

      final result = builder.build();

      expect(result.stopReason, StopReason.completed);

      final issues = GridValidator.validate(result.grid, language);
      expect(issues, isEmpty);
    });

    test('handles three word phrases', () {
      final language = createMockLanguage(
        id: 'THREE',
        phrases: ['A B C', 'A B D'],
        requiresPadding: true,
      );

      final builder = TrieGridBuilder(
        width: 8,
        height: 4,
        language: language,
        seed: 0,
      );

      final result = builder.build();

      expect(result.stopReason, StopReason.completed);

      final issues = GridValidator.validate(result.grid, language);
      expect(issues, isEmpty);
    });

    test('respects word ordering in phrases', () {
      // HELLO must come before WORLD in the grid
      final language = createMockLanguage(
        id: 'ORDER',
        phrases: ['HELLO WORLD'],
        requiresPadding: true,
      );

      final builder = TrieGridBuilder(
        width: 15,
        height: 5,
        language: language,
        seed: 0,
      );

      final result = builder.build();

      expect(result.stopReason, StopReason.completed);

      final hello = result.wordPlacements.firstWhere((p) => p.word == 'HELLO');
      final world = result.wordPlacements.firstWhere((p) => p.word == 'WORLD');

      // HELLO must appear before WORLD
      expect(hello.startOffset, lessThan(world.startOffset));

      final issues = GridValidator.validate(result.grid, language);
      expect(issues, isEmpty);
    });

    test('can stop early when solution found', () {
      final language = createMockLanguage(
        id: 'EARLY',
        phrases: ['A B'],
        requiresPadding: true,
      );

      final builder = TrieGridBuilder(
        width: 6,
        height: 3,
        language: language,
        seed: 0,
        findFirstValid: true,
      );

      final result = builder.build();

      expect(result.stopReason, StopReason.completed);
      expect(result.wordPlacements, isNotEmpty);
    });

    test('handles language without padding requirement', () {
      final language = createMockLanguage(
        id: 'NOPAD',
        phrases: ['AB CD'],
        requiresPadding: false,
      );

      final builder = TrieGridBuilder(
        width: 6,
        height: 3,
        language: language,
        seed: 0,
      );

      final result = builder.build();

      expect(result.stopReason, StopReason.completed);

      final issues = GridValidator.validate(result.grid, language);
      expect(issues, isEmpty);
    });

    test('handles identical phrases (deduplication)', () {
      // Same phrase repeated should still work
      final language = createMockLanguage(
        id: 'DUP',
        phrases: ['A B', 'A B', 'A B'],
        requiresPadding: true,
      );

      final builder = TrieGridBuilder(
        width: 6,
        height: 3,
        language: language,
        seed: 0,
      );

      final result = builder.build();

      expect(result.stopReason, StopReason.completed);

      final issues = GridValidator.validate(result.grid, language);
      expect(issues, isEmpty);
    });
  });
}
