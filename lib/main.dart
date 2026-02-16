import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wordclock/services/analytics_service.dart';
import 'package:wordclock/settings/settings_controller.dart';
import 'package:wordclock/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register font licenses
  LicenseRegistry.addLicense(() async* {
    final notoLicense = await rootBundle.loadString(
      'assets/fonts/OFL_Noto.txt',
    );
    yield LicenseEntryWithLineBreaks([
      'google_fonts',
      'Noto Sans',
    ], notoLicense);

    final alcarinLicense = await rootBundle.loadString(
      'assets/fonts/OFL_AlcarinTengwar.txt',
    );
    yield LicenseEntryWithLineBreaks(['AlcarinTengwar'], alcarinLicense);

    final hastaLicense = await rootBundle.loadString(
      'assets/fonts/OFL_HaSta.txt',
    );
    yield LicenseEntryWithLineBreaks(['KlingonHaSta'], hastaLicense);
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
            final textTheme = baseTheme.textTheme.apply(
              fontFamily: 'Noto Sans',
            );
            return baseTheme.copyWith(
              textTheme: textTheme.copyWith(
                // Secondary text (subtitles, counts)
                bodySmall: textTheme.bodySmall?.copyWith(
                  color: Colors.white60,
                  fontSize: 12,
                ),
                // Section headers
                labelSmall: textTheme.labelSmall?.copyWith(
                  color: baseTheme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              listTileTheme: ListTileThemeData(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                visualDensity: VisualDensity.compact,
                subtitleTextStyle: textTheme.bodySmall?.copyWith(
                  color: Colors.white60,
                ),
              ),
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
