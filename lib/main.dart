import 'package:flutter/material.dart';
import 'package:wordclock/settings/settings_controller.dart';
import 'package:wordclock/ui/clock_face.dart';

void main() {
  final settingsController = SettingsController();
  runApp(WordClockApp(settingsController: settingsController));
}

class WordClockApp extends StatelessWidget {
  final SettingsController settingsController;

  const WordClockApp({super.key, required this.settingsController});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (context, child) {
        return MaterialApp(
          title: 'WordClock',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: settingsController.settings.activeGradientColors.first,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            fontFamily: 'Courier',
            scaffoldBackgroundColor:
                settingsController.settings.backgroundColor,
          ),
          home: ClockFace(settingsController: settingsController),
        );
      },
    );
  }
}
