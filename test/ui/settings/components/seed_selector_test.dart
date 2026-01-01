import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/ui/settings/components/seed_selector.dart';

void main() {
  testWidgets('SeedSelector displays "Default" when value is null', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SeedSelector(value: null, onChanged: (val) {})),
      ),
    );

    expect(find.text('Default'), findsOneWidget);
  });

  testWidgets('SeedSelector displays value when provided', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SeedSelector(value: 42, onChanged: (val) {})),
      ),
    );

    expect(find.text('42'), findsOneWidget);
  });

  testWidgets('SeedSelector increments value', (WidgetTester tester) async {
    int? changedValue;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SeedSelector(value: 42, onChanged: (val) => changedValue = val),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.add));
    expect(changedValue, 43);
  });

  testWidgets('SeedSelector decrements value', (WidgetTester tester) async {
    int? changedValue;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SeedSelector(value: 42, onChanged: (val) => changedValue = val),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.remove));
    expect(changedValue, 41);
  });

  testWidgets('SeedSelector treats null as 0 for increment/decrement', (
    WidgetTester tester,
  ) async {
    int? changedValue;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SeedSelector(
            value: null,
            onChanged: (val) => changedValue = val,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.add));
    expect(changedValue, 1);

    await tester.tap(find.byIcon(Icons.remove));
    expect(changedValue, -1);
  });

  testWidgets('SeedSelector opens dialog and accepts input', (
    WidgetTester tester,
  ) async {
    int? changedValue;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SeedSelector(
            value: 123,
            onChanged: (val) => changedValue = val,
          ),
        ),
      ),
    );

    // Tap the text to open dialog
    await tester.tap(find.text('123'));
    await tester.pumpAndSettle();

    // Verify dialog is open
    expect(find.text('Enter Grid Seed'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // Enter text
    await tester.enterText(find.byType(TextField), '789');
    await tester.pump();

    // Tap OK
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(changedValue, 789);
  });

  testWidgets('SeedSelector dialog handles empty input as null', (
    WidgetTester tester,
  ) async {
    int? changedValue = 123;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SeedSelector(
            value: 123,
            onChanged: (val) => changedValue = val,
          ),
        ),
      ),
    );

    await tester.tap(find.text('123'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(changedValue, null);
  });

  testWidgets('SeedSelector shuffle button generates value', (
    WidgetTester tester,
  ) async {
    int? changedValue;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SeedSelector(
            value: 100,
            onChanged: (val) => changedValue = val,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.shuffle));
    // Since it uses DateTime.now().millisecondsSinceEpoch, we just check it's not null and changed
    expect(changedValue, isNotNull);
    expect(changedValue, isNot(100));
  });
}
