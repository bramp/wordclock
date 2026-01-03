import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/ui/letter_grid.dart';

final _testGrid = WordGrid.fromLetters(
  width: 4,
  letters:
      "ABCD"
      "EFGH"
      "IJKL"
      "MNOP", // 4x4
);

void main() {
  group('LetterGrid', () {
    testWidgets('renders all letters from grid', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LetterGrid(
            grid: _testGrid,
            activeIndices: const {},
            activeColor: Colors.white,
            inactiveColor: Colors.grey,
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('P'), findsOneWidget);
      expect(find.text('Z'), findsNothing);
    });

    testWidgets('active letters have active style', (
      WidgetTester tester,
    ) async {
      const activeColor = Colors.red;
      const inactiveColor = Colors.grey;
      final activeIndices = {0, 5, 15}; // A, F, P

      await tester.pumpWidget(
        MaterialApp(
          home: LetterGrid(
            grid: _testGrid,
            activeIndices: activeIndices,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
          ),
        ),
      );

      // Helper function to get style
      TextStyle getStyle(String char) {
        final textFinder = find.text(char);
        final animatedStyleFinder = find.ancestor(
          of: textFinder,
          matching: find.byType(AnimatedDefaultTextStyle),
        );
        expect(animatedStyleFinder, findsOneWidget);
        final widget = tester.widget<AnimatedDefaultTextStyle>(
          animatedStyleFinder,
        );
        return widget.style;
      }

      // Check 'A' (Index 0) - Active
      final styleA = getStyle('A');
      expect(styleA.color, activeColor);
      expect(styleA.fontWeight, FontWeight.w900);

      // Check 'B' (Index 1) - Inactive
      final styleB = getStyle('B');
      expect(styleB.color, inactiveColor);
      expect(styleB.fontWeight, FontWeight.w300);

      // Check 'P' (Index 15) - Active
      final styleP = getStyle('P');
      expect(styleP.color, activeColor);
    });
  });
}
