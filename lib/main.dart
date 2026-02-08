import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wordclock/services/analytics_service.dart';
import 'package:wordclock/settings/settings_controller.dart';
import 'package:wordclock/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow fonts to be downloaded at runtime.
  // We try and package all fonts with the app, and we have
  // test/font_integration_test.dart to try and ensure this. But as a fallback
  // we allow runtime fetching.
  GoogleFonts.config.allowRuntimeFetching = true;

  // Register font license
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts', 'Noto Sans'], license);
  });

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
          theme: () {
            final baseTheme = ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor:
                    settingsController.settings.activeGradientColors.first,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              scaffoldBackgroundColor:
                  settingsController.settings.backgroundColor,
            );
            return baseTheme.copyWith(
              textTheme: GoogleFonts.notoSansTextTheme(baseTheme.textTheme),
            );
          }(),
          // Localization
          locale: settingsController.uiLocale,
          supportedLocales: SettingsController.supportedUiLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }
}
