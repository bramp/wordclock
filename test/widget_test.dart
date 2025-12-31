import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/main.dart';
import 'package:wordclock/settings/settings_controller.dart';
import 'package:wordclock/ui/clock_face.dart';

void main() {
  testWidgets('WordClock app smoke test', (WidgetTester tester) async {
    final settingsController = SettingsController();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(settingsController: settingsController));

    // Verify that the ClockFace is present
    expect(find.byType(ClockFace), findsOneWidget);
  });
}
