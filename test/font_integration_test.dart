import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wordclock/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wordclock/settings/settings_controller.dart';
import 'package:wordclock/router.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/ui/settings/components/language_selector.dart';
import 'package:wordclock/ui/settings/settings_panel.dart';
import 'package:wordclock/settings/theme_settings.dart';

void main() {
  // Allow fetching of fonts, and we expect these tests
  // to succeed because the assets are present.
  GoogleFonts.config.allowRuntimeFetching = true;

  testWidgets('All supported languages load bundled fonts programmatically', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(() async {
      SharedPreferences.setMockInitialValues({});
      final settingsController = SettingsController();
      await settingsController.loadSettings();

      final router = createRouter(settingsController);

      await tester.pumpWidget(
        app.WordClockApp(
          settingsController: settingsController,
          router: router,
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      // Only test active languages to avoid issues with hidden/wip ones
      final activeLanguages = SettingsController.supportedLanguages.where(
        (l) => !l.isHidden && !l.isAlternative && l.id != 'KP',
      );
      for (final language in activeLanguages) {
        settingsController.setLanguage(language);
        // Wait for the UI to request the font
        await tester.pump(const Duration(milliseconds: 100));

        try {
          // This should throw if a network request was triggered
          await GoogleFonts.pendingFonts();
        } catch (e) {
          fail('Font loading failed for language ${language.id}: $e');
        }

        final exception = tester.takeException();
        if (exception != null) {
          fail('Caught exception for language ${language.id}: $exception');
        }
      }
    });
  });

  testWidgets('Language picker UI triggers font loading correctly for Tamil', (
    WidgetTester tester,
  ) async {
    // Set a consistent surface size
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.runAsync(() async {
      SharedPreferences.setMockInitialValues({
        'analytics_consent': true,
        'theme_settings': jsonEncode(
          ThemeSettings.defaultTheme
              .copyWith(backgroundType: BackgroundType.solid)
              .toJson(),
        ),
      });
      final settingsController = SettingsController();
      await settingsController.loadSettings();

      final router = createRouter(settingsController);

      await tester.pumpWidget(
        app.WordClockApp(
          settingsController: settingsController,
          router: router,
        ),
      );
      // Wait for routing
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      // Ensure settings button is hit-testable
      final settingsButton = find.byTooltip('Settings');
      expect(settingsButton, findsOneWidget);
      final buttonCenter = tester.getCenter(settingsButton);
      if (buttonCenter.dx >= 1024 || buttonCenter.dy >= 768) {
        fail('Settings button is offscreen at $buttonCenter');
      }

      await tester.tap(settingsButton);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1)); // Replaced pumpAndSettle

      // Verify drawer is open
      final panelFinder = find.byType(SettingsPanel);
      expect(panelFinder, findsOneWidget);
      final panelCenter = tester.getCenter(panelFinder);
      if (panelCenter.dx >= 1024) {
        fail(
          'Settings panel is offscreen at $panelCenter after tapping button',
        );
      }

      // Find 'Clock Language' selector
      final selectors = find.descendant(
        of: panelFinder,
        matching: find.byType(LanguageSelector<WordClockLanguage>),
      );
      if (selectors.evaluate().isEmpty) {
        fail('Language selectors not found in settings panel');
      }

      await tester.tap(selectors.last);
      await tester.pump(const Duration(seconds: 1)); // Replaced pumpAndSettle

      // Use search to find 'Tamil' quickly and reliably
      await tester.enterText(find.byType(TextField), 'Tamil');
      await tester.pump(const Duration(milliseconds: 500));

      // Find 'Tamil' - it should be the only one or at least visible
      final tamilItem = find.textContaining('Tamil').last;
      await tester.tap(tamilItem);
      await tester.pump(const Duration(seconds: 1));

      // Verify fonts
      try {
        await GoogleFonts.pendingFonts();
      } catch (e) {
        fail('Font loading failed for Tamil via UI: $e');
      }

      final exception = tester.takeException();
      if (exception != null) {
        fail('Caught exception for Tamil via UI: $exception');
      }
    });
  });
}
