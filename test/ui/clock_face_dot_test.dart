import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/ui/clock_face_dot.dart';

void main() {
  group('ClockFaceDot', () {
    testWidgets('renders correctly when active', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Stack(
            children: [
              ClockFaceDot(
                color: Colors.white,
                isActive: true,
                top: 10,
                left: 10,
              ),
            ],
          ),
        ),
      );

      // Verify opacity is 1.0 (fully visible)
      final opacityFinder = find.byType(AnimatedOpacity);
      expect(opacityFinder, findsOneWidget);
      final animatedOpacity = tester.widget<AnimatedOpacity>(opacityFinder);
      expect(animatedOpacity.opacity, 1.0);

      // Verify container decoration has correct color/shadow
      final containerFinder = find.descendant(
        of: opacityFinder,
        matching: find.byType(Container),
      );
      expect(containerFinder, findsOneWidget);
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.white);
      expect(decoration.boxShadow, isNotEmpty);
    });

    testWidgets('renders transparent when inactive', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                ClockFaceDot(
                  color: Colors.red,
                  isActive: false,
                  top: 10,
                  left: 10,
                ),
              ],
            ),
          ),
        ),
      );

      // Verify opacity is 0.0 (invisible)
      final opacityFinder = find.byType(AnimatedOpacity);
      expect(opacityFinder, findsOneWidget);
      final animatedOpacity = tester.widget<AnimatedOpacity>(opacityFinder);
      expect(animatedOpacity.opacity, 0.0);
    });

    // TODO: Figure out how to test implicit animation transitions
    // Usually via tester.pump(duration) and checking intermediate values
    testWidgets('animates color change', (WidgetTester tester) async {
      // TODO: Implement robust animation testing
    });
  });
}
