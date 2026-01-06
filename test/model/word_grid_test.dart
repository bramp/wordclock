import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/model/word_grid.dart';

void main() {
  test('getIndices honors padding constraint for hardcoded grid', () {
    // Hardcoded grid based on the problematic PE grid structure
    // Width 11
    // Row 0: S Ã O E D U A S E L P
    // Row 1: M H N O V E O I T O A
    // ...
    final grid = WordGrid.fromLetters(
      width: 11,
      letters:
          "SÃOEDUASELP"
          "MHNOVEOITOA",
      mergeApostrophes: false,
    );

    // We break it down manually to ensure strict control
    final units = ["SÃO", "DUAS", "E"];

    // Validate expectation:
    // SÃO at 0,1,2
    // DUAS at 4,5,6,7
    // E at 8 (adjacent, bad)
    // E at 16 (next row, good)

    // With requiresPadding: false
    var indicesStart = grid.getIndices(units, requiresPadding: false);
    expect(
      indicesStart.contains(8),
      isTrue,
      reason: "Should pick adjacent E (8) when padding is disabled",
    );

    // With requiresPadding: true
    final indices = grid.getIndices(units, requiresPadding: true);
    expect(
      indices.contains(8),
      isFalse,
      reason: "Should NOT pick adjacent E (8) when padding is enabled",
    );
    expect(
      indices.contains(16),
      isTrue,
      reason: "Should pick E on next row (16)",
    );
  });
}
