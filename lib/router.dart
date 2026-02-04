import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wordclock/settings/settings_controller.dart';
import 'package:wordclock/ui/clock_face.dart';
import 'package:wordclock/languages/all.dart';

GoRouter createRouter(SettingsController settingsController) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          // You could wrap with a persistent scaffold here if needed for UI shell
          return child;
        },
        routes: [
          GoRoute(
            path: '/',
            redirect: (context, state) {
              // Redirect root to current language
              return '/${settingsController.currentLanguage.languageCode}';
            },
          ),
          GoRoute(
            path: '/:lang',
            builder: (context, state) {
              return ClockFace(settingsController: settingsController);
            },
            redirect: (context, state) {
              final langParam = state.pathParameters['lang'];
              if (langParam == null) return null;

              final targetLang = WordClockLanguages.findByCode(langParam);

              // Validation: Is this a supported language URL path?
              if (targetLang == null) {
                // Invalid language, fallback to current controller language
                return '/${settingsController.currentLanguage.languageCode}';
              }

              // Synchronization: URL -> State
              if (settingsController.currentLanguage != targetLang) {
                settingsController.setLanguage(targetLang);
              }

              return null; // Stay on this route
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri.toString()}')),
    ),
  );
}
