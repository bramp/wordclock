import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/backtracking/graph/word_node.dart';
import 'package:wordclock/generator/backtracking/indexed_word_list.dart';

void main() {
  group('IndexedWordList.computeMaxIncomingOverlaps', () {
    List<int> computeOverlaps(List<String> words) {
      // Create mock WordNodes with the given words as cell codes
      final nodes = words.map((word) {
        return WordNode(
          word: word,
          instance: 0,
          cellCodes: word.codeUnits,
          phrases: {},
        );
      }).toList();

      return IndexedWordList.computeMaxIncomingOverlaps(nodes);
    }

    test('no overlap possible between completely different words', () {
      final overlaps = computeOverlaps(['ABC', 'XYZ']);
      expect(overlaps[0], 0); // ABC can't overlap with XYZ
      expect(overlaps[1], 0); // XYZ can't overlap with ABC
    });

    test('single character overlap', () {
      final overlaps = computeOverlaps(['AB', 'BC']);
      expect(overlaps[0], 0); // AB prefix doesn't match BC suffix
      expect(overlaps[1], 1); // BC prefix 'B' matches AB suffix 'B'
    });

    test('multi-character overlap', () {
      final overlaps = computeOverlaps(['ABC', 'BCD']);
      expect(overlaps[0], 0); // ABC prefix doesn't match BCD suffix
      expect(overlaps[1], 2); // BCD prefix 'BC' matches ABC suffix 'BC'
    });

    test('full overlap - word is suffix of another', () {
      final overlaps = computeOverlaps(['ABCD', 'CD']);
      expect(overlaps[0], 0); // ABCD prefix doesn't match CD suffix
      expect(overlaps[1], 2); // CD fully matches ABCD suffix
    });

    test('identical words have full overlap', () {
      final overlaps = computeOverlaps(['ABC', 'ABC']);
      expect(overlaps[0], 3); // ABC can fully overlap with itself
      expect(overlaps[1], 3); // ABC can fully overlap with itself
    });

    test('self-overlap within single word - AA pattern', () {
      // With just one word, it can overlap with itself
      final overlaps = computeOverlaps(['AA']);
      expect(overlaps[0], 0); // Only one word, no other word to overlap with
    });

    test('best overlap is chosen from multiple candidates', () {
      // 'BCD' can overlap with 'ABC' (2 chars) or 'XBC' (2 chars)
      final overlaps = computeOverlaps(['ABC', 'XBC', 'BCD']);
      expect(overlaps[2], 2); // BCD gets max overlap of 2 from either
    });

    test('longer overlap preferred', () {
      // 'BCDE' can get 1-char overlap with 'XB' or 3-char with 'ABCD'
      final overlaps = computeOverlaps(['XB', 'ABCD', 'BCDE']);
      expect(overlaps[2], 3); // BCDE prefix 'BCD' matches ABCD suffix 'BCD'
    });

    test('real word example - FIVE and TWENTYFIVE', () {
      final overlaps = computeOverlaps(['FIVE', 'TWENTYFIVE']);
      expect(
        overlaps[0],
        4,
      ); // FIVE can fully overlap (TWENTYFIVE ends with FIVE)
      expect(overlaps[1], 0); // TWENTYFIVE prefix 'T' doesn't match FIVE suffix
    });

    test('real word example - overlapping time words', () {
      final overlaps = computeOverlaps(['TEN', 'TWENTY', 'ENTY']);
      expect(overlaps[0], 0); // TEN: no word ends with T, TE, or TEN
      expect(overlaps[1], 0); // TWENTY: no word ends with T, TW, etc.
      expect(overlaps[2], 4); // ENTY: fully matches TWENTY suffix
    });
  });

  group('minContribution calculation', () {
    test('minContribution = length - maxOverlap', () {
      // If word is 5 chars and can overlap 2, contribution is 3
      final nodes = [
        WordNode(
          word: 'ABCDE',
          instance: 0,
          cellCodes: 'ABCDE'.codeUnits,
          phrases: {},
        ),
        WordNode(
          word: 'DEFGH',
          instance: 0,
          cellCodes: 'DEFGH'.codeUnits,
          phrases: {},
        ),
      ];

      // DEFGH prefix 'DE' matches ABCDE suffix 'DE' = 2 char overlap
      final overlaps = IndexedWordList.computeMaxIncomingOverlaps(nodes);
      expect(overlaps[0], 0); // ABCDE: no overlap
      expect(overlaps[1], 2); // DEFGH: 2 char overlap

      // minContribution = length - overlap
      expect(5 - overlaps[0], 5); // ABCDE contributes 5
      expect(5 - overlaps[1], 3); // DEFGH contributes 3

      // Total min space needed for both = 5 + 3 = 8
    });

    test('word with full overlap has minContribution of 0', () {
      final nodes = [
        WordNode(
          word: 'ABCD',
          instance: 0,
          cellCodes: 'ABCD'.codeUnits,
          phrases: {},
        ),
        WordNode(
          word: 'ABCD',
          instance: 1,
          cellCodes: 'ABCD'.codeUnits,
          phrases: {},
        ),
      ];

      final overlaps = IndexedWordList.computeMaxIncomingOverlaps(nodes);
      expect(overlaps[0], 4); // Full overlap
      expect(overlaps[1], 4); // Full overlap

      // Both have 0 minContribution - they can fully overlap
      expect(4 - overlaps[0], 0);
      expect(4 - overlaps[1], 0);
    });
  });

  group('space pruning scenarios', () {
    test('two non-overlapping words need full space', () {
      // Grid: 1x10, words ABC (3) and XYZ (3)
      // No overlap possible, need 6 cells minimum
      // Remaining space must be >= 6

      final overlaps = _computeOverlapsForStrings(['ABC', 'XYZ']);
      final minContributions = [3 - overlaps[0], 3 - overlaps[1]];
      final totalMinSpace = minContributions.reduce((a, b) => a + b);

      expect(totalMinSpace, 6); // Need 6 cells
    });

    test('overlapping words need less space', () {
      // Grid: 1x10, words ABC (3) and BCD (3)
      // BCD can overlap 2 chars with ABC, needs only 1 new cell

      final overlaps = _computeOverlapsForStrings(['ABC', 'BCD']);
      final minContributions = [3 - overlaps[0], 3 - overlaps[1]];
      final totalMinSpace = minContributions.reduce((a, b) => a + b);

      expect(overlaps[1], 2); // BCD overlaps 2 with ABC
      expect(totalMinSpace, 4); // ABC(3) + BCD(1) = 4 cells
    });

    test('chain of overlapping words', () {
      // Words: AB, BC, CD - each can overlap 1 char with predecessor
      final overlaps = _computeOverlapsForStrings(['AB', 'BC', 'CD']);
      final lengths = [2, 2, 2];
      final minContributions = List.generate(
        3,
        (i) => lengths[i] - overlaps[i],
      );
      final totalMinSpace = minContributions.reduce((a, b) => a + b);

      // AB: 0 overlap, contributes 2
      // BC: 1 overlap (B matches AB suffix), contributes 1
      // CD: 1 overlap (C matches BC suffix), contributes 1
      expect(totalMinSpace, 4); // 2 + 1 + 1 = 4
    });

    test('your example: A placed, AA to place in 1x2 grid', () {
      // Grid 1x2, "A" placed at position 0
      // "AA" needs to fit, can overlap 1 char with "A"

      final overlaps = _computeOverlapsForStrings(['A', 'AA']);
      // AA prefix 'A' matches A suffix 'A' = 1 char overlap
      expect(overlaps[1], 1);

      // minContribution for AA = 2 - 1 = 1
      final minContribution = 2 - overlaps[1];
      expect(minContribution, 1);

      // If A is at position 0, maxEndOffset = 0
      // Remaining space = 2 - 0 - 1 = 1
      // Can AA fit? minContribution(1) <= remainingSpace(1) ✓
      expect(minContribution <= 1, true);
    });

    test('impossible case: long word in small remaining space', () {
      // Grid 1x5, "AB" placed at position 0-1
      // "WXYZ" needs to fit, no overlap possible with "AB"

      final overlaps = _computeOverlapsForStrings(['AB', 'WXYZ']);
      expect(overlaps[1], 0); // No overlap

      final minContribution = 4 - overlaps[1]; // = 4

      // If AB ends at position 1, maxEndOffset = 1
      // Remaining space = 5 - 1 - 1 = 3
      // Can WXYZ fit? minContribution(4) <= remainingSpace(3) ✗
      expect(minContribution <= 3, false);
    });
  });
}

/// Helper to compute overlaps from string words
List<int> _computeOverlapsForStrings(List<String> words) {
  final nodes = words.map((word) {
    return WordNode(
      word: word,
      instance: 0,
      cellCodes: word.codeUnits,
      phrases: {},
    );
  }).toList();

  return IndexedWordList.computeMaxIncomingOverlaps(nodes);
}
