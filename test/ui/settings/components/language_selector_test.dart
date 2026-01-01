import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/settings/settings_controller.dart';
import 'package:wordclock/ui/settings/components/language_selector.dart';

void main() {
  testWidgets('LanguageSelector displays supported languages', (
    WidgetTester tester,
  ) async {
    final controller = SettingsController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: LanguageSelector(controller: controller)),
      ),
    );

    expect(find.text('English'), findsOneWidget);
    expect(find.text('Español'), findsOneWidget);
    expect(find.text('Deutsch'), findsOneWidget);
    expect(find.text('日本語'), findsOneWidget);
  });

  testWidgets('LanguageSelector updates language when tapped', (
    WidgetTester tester,
  ) async {
    final controller = SettingsController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: LanguageSelector(controller: controller)),
      ),
    );

    // Initial language should be English
    expect(controller.currentLanguage.displayName, 'English');

    // Tap 日本語
    await tester.tap(find.text('日本語'));
    await tester.pumpAndSettle();

    expect(controller.currentLanguage.displayName, '日本語');

    // Tap English
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(controller.currentLanguage.displayName, 'English');
  });
}
