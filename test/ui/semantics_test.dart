import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wordclock/settings/settings_controller.dart';
import 'package:wordclock/ui/clock_face.dart';
import 'package:wordclock/ui/settings/components/section_header.dart';
import 'package:wordclock/ui/settings/components/language_selector.dart';
import 'package:wordclock/ui/settings/components/theme_chip.dart';
import 'package:wordclock/ui/settings/components/speed_chip.dart';

void main() {
  group('Semantics Verification', () {
    testWidgets('ClockFace provides accessibility label and hint', (
      WidgetTester tester,
    ) async {
      final handle = tester.ensureSemantics();
      SharedPreferences.setMockInitialValues({});
      final controller = SettingsController();
      await controller.loadSettings();

      await tester.pumpWidget(
        MaterialApp(home: ClockFace(settingsController: controller)),
      );
      await tester.pump();

      // We use a RegExp to be slightly more robust to minor punctuation changes,
      // but the core "Current time in words" must be present.
      expect(
        find.bySemanticsLabel(RegExp(r'Current time in words: .*')),
        findsOneWidget,
      );

      // Verify hint specifically
      expect(
        find.byElementPredicate(
          (e) =>
              e.widget is Semantics &&
              (e.widget as Semantics).properties.hint ==
                  'Long press to copy time to clipboard',
        ),
        findsOneWidget,
      );

      handle.dispose();
    });

    testWidgets('SectionHeader is correctly marked as a semantic header', (
      WidgetTester tester,
    ) async {
      final handle = tester.ensureSemantics();
      const title = 'DISPLAY SETTINGS';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SectionHeader(title: title)),
        ),
      );

      // Verify it's a header
      expect(
        find.byElementPredicate(
          (e) =>
              e.widget is Semantics &&
              (e.widget as Semantics).properties.header == true,
        ),
        findsOneWidget,
      );

      handle.dispose();
    });

    testWidgets('LanguageSelector has correct button semantics', (
      WidgetTester tester,
    ) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageSelector<String>(
              currentSelection: 'English',
              availableOptions: const ['English', 'French'],
              labelBuilder: (s) => s,
              onSelected: (_) {},
              semanticsLabelPrefix: 'Interface Language',
            ),
          ),
        ),
      );

      // Verify label, button trait, and hint
      final finder = find.byElementPredicate((e) {
        if (e.widget is! Semantics) return false;
        final s = e.widget as Semantics;
        return s.properties.label ==
                'Interface Language: Change English language' &&
            s.properties.button == true &&
            s.properties.hint == 'Opens a language selection menu';
      });

      expect(finder, findsOneWidget);

      handle.dispose();
    });

    testWidgets('ThemeChip and SpeedChip have functional semantic labels', (
      WidgetTester tester,
    ) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ThemeChip(
                  label: 'Warm',
                  colors: const [Colors.red, Colors.orange],
                  isSelected: true,
                  onTap: () {},
                ),
                SpeedChip(
                  label: 'Fast',
                  color: Colors.blue,
                  isSelected: false,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Verify ThemeChip
      expect(
        find.byElementPredicate((e) {
          if (e.widget is! Semantics) return false;
          final s = e.widget as Semantics;
          return s.properties.label == 'Select Warm theme' &&
              s.properties.selected == true &&
              s.properties.button == true;
        }),
        findsOneWidget,
      );

      // Verify SpeedChip
      expect(
        find.byElementPredicate((e) {
          if (e.widget is! Semantics) return false;
          final s = e.widget as Semantics;
          return s.properties.label == 'Set clock speed to Fast' &&
              s.properties.selected == false &&
              s.properties.button == true;
        }),
        findsOneWidget,
      );

      handle.dispose();
    });
  });
}
