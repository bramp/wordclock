import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/ui/clock_layout.dart';
import 'package:wordclock/ui/letter_grid.dart';

void main() {
  final testGrid = WordGrid.fromLetters(width: 2, letters: 'ABCD');

  group('ClockLayout', () {
    testWidgets('insets the grid when showDots is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClockLayout(
              grid: testGrid,
              remainder: 0,
              showDots: true,
              dotColor: Colors.white,
              child: LetterGrid(
                grid: WordGrid(width: 1, cells: ['A']),
                locale: const Locale('en'),
                activeIndices: const {},
                activeColor: Colors.white,
                inactiveColor: Colors.grey,
              ),
            ),
          ),
        ),
      );

      // We expect at least two Padding widgets: one from ClockLayout (outer 20.0),
      // and one for the grid (inner 24.0).

      final innerPaddingFinder = find
          .ancestor(of: find.byType(LetterGrid), matching: find.byType(Padding))
          .first;

      final paddingWidget = tester.widget<Padding>(innerPaddingFinder);
      expect(paddingWidget.padding, const EdgeInsets.all(24.0));
    });

    testWidgets('removes inset when showDots is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClockLayout(
              grid: testGrid,
              remainder: 0,
              showDots: false,
              dotColor: Colors.white,
              child: LetterGrid(
                grid: WordGrid(width: 1, cells: ['A']),
                locale: const Locale('en'),
                activeIndices: const {},
                activeColor: Colors.white,
                inactiveColor: Colors.grey,
              ),
            ),
          ),
        ),
      );

      final innerPaddingFinder = find
          .ancestor(of: find.byType(LetterGrid), matching: find.byType(Padding))
          .first;

      final paddingWidget = tester.widget<Padding>(innerPaddingFinder);
      expect(paddingWidget.padding, EdgeInsets.zero);
    });
  });
}
