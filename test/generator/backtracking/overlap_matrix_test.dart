import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/backtracking/overlap_matrix.dart';
import 'package:wordclock/generator/backtracking/graph/word_node.dart';

void main() {
  group('OverlapMatrix', () {
    // Helper to create a simple WordNode for testing
    WordNode makeNode(String word, List<int> codes) {
      return WordNode(
        word: word,
        instance: 0,
        cellCodes: codes,
        phrases: {word},
      );
    }

    test('identical words can overlap', () {
      final a = makeNode('AA', [1, 1]);
      final b = makeNode('AA2', [1, 1]);
      final matrix = OverlapMatrix.build([a, b]);

      expect(matrix.canOverlap(a, b), isTrue);
    });

    test('completely different words cannot overlap', () {
      final a = makeNode('AA', [1, 1]);
      final b = makeNode('BB', [2, 2]);
      final matrix = OverlapMatrix.build([a, b]);

      expect(matrix.canOverlap(a, b), isFalse);
    });

    test('words with shared character can overlap', () {
      final ab = makeNode('AB', [1, 2]);
      final bc = makeNode('BC', [2, 3]);
      final matrix = OverlapMatrix.build([ab, bc]);

      // AB and BC can overlap where B matches B
      // AB at position 0: A B
      // BC at position 1:   B C
      expect(matrix.canOverlap(ab, bc), isTrue);
    });

    test('words with partial overlap possibility', () {
      final abc = makeNode('ABC', [1, 2, 3]);
      final bcd = makeNode('BCD', [2, 3, 4]);
      final matrix = OverlapMatrix.build([abc, bcd]);

      // ABC and BCD can overlap:
      // ABC: A B C
      // BCD:   B C D
      expect(matrix.canOverlap(abc, bcd), isTrue);
    });

    test('words with no valid overlap alignment', () {
      // ACE and BDF have no shared characters
      final ace = makeNode('ACE', [1, 3, 5]);
      final bdf = makeNode('BDF', [2, 4, 6]);
      final matrix = OverlapMatrix.build([ace, bdf]);

      expect(matrix.canOverlap(ace, bdf), isFalse);
    });

    test('self-overlap is always true', () {
      final a = makeNode('ABC', [1, 2, 3]);
      final matrix = OverlapMatrix.build([a]);

      expect(matrix.canOverlap(a, a), isTrue);
    });

    test('matrix is symmetric', () {
      final a = makeNode('AB', [1, 2]);
      final b = makeNode('BC', [2, 3]);
      final c = makeNode('DE', [4, 5]);
      final matrix = OverlapMatrix.build([a, b, c]);

      // AB <-> BC should be symmetric
      expect(matrix.canOverlap(a, b), matrix.canOverlap(b, a));
      // AB <-> DE should be symmetric
      expect(matrix.canOverlap(a, c), matrix.canOverlap(c, a));
    });

    test('getStats returns reasonable information', () {
      final a = makeNode('AA', [1, 1]);
      final b = makeNode('BB', [2, 2]);
      final c = makeNode('AB', [1, 2]);
      final matrix = OverlapMatrix.build([a, b, c]);

      final stats = matrix.getStats();
      expect(stats, contains('OverlapMatrix'));
      expect(stats, contains('pairs'));
    });

    test('handles single-character words', () {
      final a = makeNode('A', [1]);
      final b = makeNode('B', [2]);
      final c = makeNode('A2', [1]);
      final matrix = OverlapMatrix.build([a, b, c]);

      expect(matrix.canOverlap(a, c), isTrue); // Same character
      expect(matrix.canOverlap(a, b), isFalse); // Different characters
    });

    test('complex overlap with repeated characters', () {
      // ABAB and BABA - can they overlap?
      // ABAB at 0: A B A B
      // BABA at 1:   B A B A - check: B=B, A=A, B=B -> yes!
      final abab = makeNode('ABAB', [1, 2, 1, 2]);
      final baba = makeNode('BABA', [2, 1, 2, 1]);
      final matrix = OverlapMatrix.build([abab, baba]);

      expect(matrix.canOverlap(abab, baba), isTrue);
    });
  });
}
