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
                color: Colors.red,
                isActive: true,
                top: 10,
                left: 10,
              ),
            ],
          ),
        ),
      );

      final containerFinder = find.byType(AnimatedContainer);
      expect(containerFinder, findsOneWidget);

      final container = tester.widget<AnimatedContainer>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.red);
      expect(decoration.shape, BoxShape.circle);
    });

    testWidgets('renders transparent when inactive', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Stack(
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
      );

      final containerFinder = find.byType(AnimatedContainer);
      expect(containerFinder, findsOneWidget);

      final container = tester.widget<AnimatedContainer>(containerFinder);
      final decoration = container.decoration as BoxDecoration;

      // Color should be transparent version of red
      expect(decoration.color, Colors.red.withValues(alpha: 0.0));
    });

    // TODO: Figure out how to test implicit animation transitions
    // Usually via tester.pump(duration) and checking intermediate values
    testWidgets('animates color change', (WidgetTester tester) async {
      // TODO: Implement robust animation testing
    });
  });
}
