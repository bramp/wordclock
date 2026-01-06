import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/backtracking/graph/word_node.dart';

void main() {
  group('WordNode', () {
    test('should have correct id from word and instance', () {
      final node0 = WordNode(
        word: 'TEST',
        instance: 0,
        cells: ['T', 'E', 'S', 'T'],
        phrases: {'phrase1'},
      );
      expect(node0.id, 'TEST');

      final node1 = WordNode(
        word: 'TEST',
        instance: 1,
        cells: ['T', 'E', 'S', 'T'],
        phrases: {'phrase1'},
      );
      expect(node1.id, 'TEST#1');

      final node2 = WordNode(
        word: 'FIVE',
        instance: 2,
        cells: ['F', 'I', 'V', 'E'],
        phrases: {'phrase1'},
      );
      expect(node2.id, 'FIVE#2');
    });

    test('should calculate frequency correctly', () {
      final node = WordNode(
        word: 'TEST',
        instance: 0,
        cells: ['T', 'E', 'S', 'T'],
        phrases: {'phrase1', 'phrase2', 'phrase3'},
      );

      expect(node.frequency, 3);
    });

    test('should calculate priority correctly', () {
      final node = WordNode(
        word: 'TEST',
        instance: 0,
        cells: ['T', 'E', 'S', 'T'],
        phrases: {'phrase1', 'phrase2'},
      );

      // Priority formula: (frequency * 10.0) + (cells.length / 10.0)
      final expectedPriority = (2 * 10.0) + (4 / 10.0);
      expect(node.priority, closeTo(expectedPriority, 0.01));
    });
  });
}
