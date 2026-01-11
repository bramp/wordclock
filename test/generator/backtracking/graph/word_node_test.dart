import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/backtracking/graph/word_node.dart';
import 'package:wordclock/generator/backtracking/graph/cell_codec.dart';

void main() {
  group('WordNode', () {
    late CellCodec codec;

    setUp(() {
      codec = CellCodec();
    });

    test('should have correct id from word and instance', () {
      final cells0 = ['T', 'E', 'S', 'T'];
      final node0 = WordNode(
        word: 'TEST',
        instance: 0,
        cellCodes: codec.encodeAll(cells0),
        phrases: {'phrase1'},
      );
      expect(node0.id, 'TEST');

      final cells1 = ['T', 'E', 'S', 'T'];
      final node1 = WordNode(
        word: 'TEST',
        instance: 1,
        cellCodes: codec.encodeAll(cells1),
        phrases: {'phrase1'},
      );
      expect(node1.id, 'TEST#1');

      final cells2 = ['F', 'I', 'V', 'E'];
      final node2 = WordNode(
        word: 'FIVE',
        instance: 2,
        cellCodes: codec.encodeAll(cells2),
        phrases: {'phrase1'},
      );
      expect(node2.id, 'FIVE#2');
    });

    test('should calculate frequency correctly', () {
      final cells = ['T', 'E', 'S', 'T'];
      final node = WordNode(
        word: 'TEST',
        instance: 0,
        cellCodes: codec.encodeAll(cells),
        phrases: {'phrase1', 'phrase2', 'phrase3'},
      );

      expect(node.frequency, 3);
    });
  });
}
