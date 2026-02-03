import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wordclock/settings/settings_controller.dart';
import 'package:wordclock/ui/settings/components/language_selector.dart';

void main() {
  testWidgets('LanguageSelector displays supported languages', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final controller = SettingsController();
    await controller.loadSettings();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: LanguageSelector(controller: controller)),
      ),
    );

    expect(find.text('English'), findsOneWidget);
    expect(find.text('Español'), findsNothing);
    expect(find.text('Deutsch'), findsNothing);
    expect(find.text('日本語'), findsNothing);

    // Open the language picker
    await tester.tap(find.byType(LanguageSelector));
    await tester.pumpAndSettle();

    // Now all languages should be visible in the sheet
    // English is present twice (in the selector and in the sheet)
    // TODO This assumes the app is in English. We should use the current language.
    expect(find.text('English'), findsWidgets);

    // Use search to find items instead of scrolling
    await tester.enterText(find.byType(TextField), 'Español');
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Español (Spanish)'), findsWidgets);

    await tester.enterText(find.byType(TextField), 'Deutsch');
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Deutsch (German)'), findsWidgets);

    await tester.enterText(find.byType(TextField), '日本語');
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, '日本語 (Japanese)'), findsWidgets);
  });

  testWidgets('LanguageSelector updates language when tapped', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final controller = SettingsController();
    await controller.loadSettings();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: LanguageSelector(controller: controller)),
      ),
    );

    // Initial language should be English
    expect(controller.currentLanguage.displayName, 'English');

    // Open the language picker
    await tester.tap(find.byType(LanguageSelector));
    await tester.pumpAndSettle();

    // Search and Tap 日本語
    await tester.enterText(find.byType(TextField), '日本語');
    await tester.pumpAndSettle();

    final jpItem = find.widgetWithText(ListTile, '日本語 (Japanese)').last;
    await tester.tap(jpItem);
    await tester.pumpAndSettle();

    expect(controller.currentLanguage.displayName, '日本語');

    // Open the language picker again
    await tester.tap(find.byType(LanguageSelector));
    await tester.pumpAndSettle();

    // Search and Tap English
    await tester.enterText(find.byType(TextField), 'English');
    await tester.pumpAndSettle();

    final enItem = find.widgetWithText(ListTile, 'English').last;
    await tester.tap(enItem);
    await tester.pumpAndSettle();

    expect(controller.currentLanguage.displayName, 'English');
  });
}
