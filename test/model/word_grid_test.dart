import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/model/word_grid.dart';

void main() {
  group('WordGrid.splitIntoCells', () {
    test('merges Tengwar Tehtar (always)', () {
      final cells = WordGrid.splitIntoCells('');
      expect(cells, ['', '', '']);
    });

    test('merges apostrophes when mergeApostrophes is true', () {
      final cells = WordGrid.splitIntoCells("O'CLOCK", mergeApostrophes: true);
      expect(cells, ["O'", "C", "L", "O", "C", "K"]);
    });

    test('does NOT merge apostrophes when mergeApostrophes is false', () {
      final cells = WordGrid.splitIntoCells("O'CLOCK", mergeApostrophes: false);
      expect(cells, ["O", "'", "C", "L", "O", "C", "K"]);
    });

    test('handles combined Tengwar and apostrophes', () {
      // Theoretical case
      final cells = WordGrid.splitIntoCells("'", mergeApostrophes: true);
      expect(cells, ["'"]);
    });
  });
}
