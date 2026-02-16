import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wordclock/settings/settings_controller.dart';
import 'package:wordclock/settings/theme_settings.dart';
import 'package:wordclock/ui/clock_face.dart';
import 'package:clock/clock.dart';
import 'test_utils.dart';

void main() {
  testWidgets('Golden Image Tests for all languages', (
    WidgetTester tester,
  ) async {
    // Load fonts before any tests
    await loadFonts();

    // Setup physical size for consistent goldens
    tester.view.physicalSize = const Size(800, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final fixedTime = DateTime(2024, 1, 1, 10, 10);

    // Use withClock for deterministic testing
    await withClock(Clock.fixed(fixedTime), () async {
      SharedPreferences.setMockInitialValues({});
      final settingsController = SettingsController();
      await settingsController.loadSettings();

      // Override settings for golden tests
      settingsController.updateTheme(ThemeSettings.goldenTheme);
      settingsController.setManualTime(fixedTime);

      final representativeIds = {
        'EN', // Latin
        'DE', // Latin + Umlauts
        'GR', // Greek
        'TR', // Turkish
        'CZ', // Central European
        'TA', // Tamil
        'CS', // Chinese Simplified
        'CT', // Chinese Traditional
        'JP', // Japanese
        'KP', // Klingon pIqaD
        'QY', // Quenya
        'SI', // Sindarin
      };

      final languages = SettingsController.supportedLanguages
          .where((l) => representativeIds.contains(l.id))
          .toList();

      for (final lang in languages) {
        settingsController.setLanguage(lang);

        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Theme(
              data: ThemeData.dark(),
              child: Scaffold(
                body: ClockFace(
                  settingsController: settingsController,
                  animationDuration: Duration.zero,
                ),
              ),
            ),
          ),
        );

        // Wait for rendering to settle
        await tester.pump();

        // Verification
        await expectLater(
          find.byType(ClockFace),
          matchesGoldenFile('goldens/languages/${lang.id}.png'),
        );
      }
    });
  });
}
