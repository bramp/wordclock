import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:wordclock/services/analytics_service.dart';
import 'package:wordclock/settings/settings_controller.dart';
import 'package:wordclock/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase Analytics
  await AnalyticsService.initialize();

  final settingsController = SettingsController();
  await settingsController.loadSettings();

  // Create router instance
  final router = createRouter(settingsController);

  runApp(WordClockApp(settingsController: settingsController, router: router));
}

class WordClockApp extends StatelessWidget {
  final SettingsController settingsController;
  final GoRouter router;

  const WordClockApp({
    super.key,
    required this.settingsController,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'WordClock',
          routerConfig: router,
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
          // Localization
          locale: settingsController.uiLocale,
          supportedLocales: SettingsController.supportedUiLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // Navigator observers handled by GoRouter generally, but we can attach analytics if needed
          // via router listener or observer. AnalyticsService.observer is a NavigatorObserver.
          // GoRouter accepts observers.
        );
      },
    );
  }
}
