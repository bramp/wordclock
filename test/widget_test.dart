import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wordclock/main.dart';
import 'package:wordclock/settings/settings_controller.dart';
import 'package:wordclock/ui/clock_face.dart';

import 'package:wordclock/router.dart';

void main() {
  testWidgets('WordClock app smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final settingsController = SettingsController();
    await settingsController.loadSettings();

    final router = createRouter(settingsController);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      WordClockApp(settingsController: settingsController, router: router),
    );

    // Verify that the ClockFace is present
    expect(find.byType(ClockFace), findsOneWidget);
  });
}
