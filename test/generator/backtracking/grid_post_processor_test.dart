import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/backtracking/grid_post_processor.dart';
import '../test_helpers.dart';

void main() {
  group('GridPostProcessor', () {
    late WordClockLanguage language;
    late CellCodec codec;
    late Random random;

    setUp(() {
      language = createMockLanguage(
        id: 'TEST',
        phrases: ['WORD'],
        requiresPadding: false,
        paddingAlphabet: '.',
      );
      codec = CellCodec();
      random = Random(0);
    });

    test('pushes first row words to the left', () {
      final processor = GridPostProcessor(
        width: 10,
        height: 2,
        language: language,
        paddingAlphabet: '.',
        random: random,
        codec: codec,
      );

      final p1 = createPlacement('WORD', 0, 5, 10, codec: codec); // Row 0
      final p2 = createPlacement(
        'END',
        1,
        0,
        10,
        codec: codec,
      ); // Row 1 (last row)
      final result = processor.process([p1, p2]);

      // Row 0 is first row with words -> push left -> startCol 0
      expect(
        result.placements.firstWhere((p) => p.row == 0).startCol,
        equals(0),
      );
      expect(result.grid.sublist(0, 10).join(''), equals('WORD......'));
    });

    test('pushes last row words to the right', () {
      final processor = GridPostProcessor(
        width: 10,
        height: 2,
        language: language,
        paddingAlphabet: '.',
        random: random,
        codec: codec,
      );

      final p1 = createPlacement(
        'WORD',
        0,
        0,
        10,
        codec: codec,
      ); // Row 0 (first row)
      final p2 = createPlacement(
        'END',
        1,
        0,
        10,
        codec: codec,
      ); // Row 1 (last row)
      final result = processor.process([p1, p2]);

      // Row 1 is last row with words -> push right -> startCol 7
      expect(
        result.placements.firstWhere((p) => p.row == 1).startCol,
        equals(7),
      );
      expect(result.grid.sublist(10, 20).join(''), equals('.......END'));
    });

    test('distributes padding fairly on middle rows', () {
      final processor = GridPostProcessor(
        width: 10,
        height: 3,
        language: language, // requiresPadding: false
        paddingAlphabet: '.',
        random: random,
        codec: codec,
      );

      final p1 = createPlacement(
        'START',
        0,
        0,
        10,
        codec: codec,
      ); // Row 0 (first)
      final p2 = createPlacement('A', 1, 0, 10, codec: codec); // Row 1 (middle)
      final p3 = createPlacement('B', 1, 2, 10, codec: codec); // Row 1 (middle)
      final p4 = createPlacement('END', 2, 0, 10, codec: codec); // Row 2 (last)

      final result = processor.process([p1, p2, p3, p4]);

      // Middle row (Row 1): Fair distribution.
      // Occupied: 2. Padding: 8. Slots: 2.
      // 8 ~/ 2 = 4 per slot.
      // A starts at 4.
      // B starts at 4 + 1 (A) + 4 (padding) = 9.
      final a = result.placements.firstWhere((p) => p.node.word == 'A');
      final b = result.placements.firstWhere((p) => p.node.word == 'B');
      expect(a.startCol, equals(4));
      expect(b.startCol, equals(9));

      expect(result.grid.sublist(10, 20).join(''), equals('....A....B'));
    });

    test('respects mandatory gaps on middle rows', () {
      final langPadding = createMockLanguage(
        id: 'PADDING',
        phrases: ['A B'],
        requiresPadding: true,
        paddingAlphabet: '.',
      );
      final processor = GridPostProcessor(
        width: 10,
        height: 3,
        language: langPadding,
        paddingAlphabet: '.',
        random: random,
        codec: codec,
      );

      final pStart = createPlacement('START', 0, 0, 10, codec: codec);
      final p1 = createPlacement('A', 1, 0, 10, codec: codec);
      final p2 = createPlacement('B', 1, 2, 10, codec: codec);
      final pEnd = createPlacement('END', 2, 0, 10, codec: codec);

      final result = processor.process([pStart, p1, p2, pEnd]);

      // Row 1 is a middle row -> Fair distribution.
      // Occupied: 2. Padding: 8. Slots: 2.
      // Mandatory gap: 1. Extra padding: 7.
      // Distribution: slot 0 = 4, slot 1 = 3.
      // A starts at 4.
      // B starts at 4 + 1 (A) + 3 (extra) + 1 (mandatory) = 9.
      final a = result.placements.firstWhere((p) => p.node.word == 'A');
      final b = result.placements.firstWhere((p) => p.node.word == 'B');
      expect(a.startCol, equals(4));
      expect(b.startCol, equals(9));
    });

    test('clusters overlapping words', () {
      final processor = GridPostProcessor(
        width: 10,
        height: 3,
        language: language,
        paddingAlphabet: '.',
        random: random,
        codec: codec,
      );

      final pStart = createPlacement('START', 0, 0, 10, codec: codec);
      // Row 1 (middle): overlap
      final p1 = createPlacement('ABC', 1, 0, 10, codec: codec);
      final p2 = createPlacement('B', 1, 1, 10, codec: codec);
      final pEnd = createPlacement('END', 2, 0, 10, codec: codec);

      final result = processor.process([pStart, p1, p2, pEnd]);

      // Row 1 is middle row -> Fair distribution.
      // Together they form a cluster of length 3 (ABC).
      // Padding = 7. Slot = 1.
      // Fair: slot 0 = 7.
      // Both shift by 7.
      // ABC at 7, B at 8.
      final abc = result.placements.firstWhere((p) => p.node.word == 'ABC');
      final b = result.placements.firstWhere((p) => p.node.word == 'B');
      expect(abc.startCol, equals(7));
      expect(b.startCol, equals(8));
    });

    test('fills remaining space with padding alphabet', () {
      final processor = GridPostProcessor(
        width: 5,
        height: 1,
        language: language,
        paddingAlphabet: '.',
        random: random,
        codec: codec,
      );

      final result = processor.process([]);
      expect(result.grid.length, equals(5));
      expect(result.grid.every((cell) => cell == '.'), isTrue);
    });
  });
}
