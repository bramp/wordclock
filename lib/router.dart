import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wordclock/settings/settings_controller.dart';
import 'package:wordclock/ui/clock_face.dart';
import 'package:wordclock/services/analytics_service.dart';
import 'package:wordclock/ui/components/consent_banner.dart';
import 'package:wordclock/languages/all.dart';

GoRouter createRouter(SettingsController settingsController) {
  return GoRouter(
    initialLocation: '/',
    observers: [
      if (AnalyticsService.observer != null) AnalyticsService.observer!,
    ],
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return Stack(
            children: [
              child,
              // Display consent banner at the bottom of the screen
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ConsentBanner(controller: settingsController),
              ),
            ],
          );
        },
        routes: [
          GoRoute(
            path: '/',
            redirect: (context, state) {
              // Redirect root to current language
              return '/${settingsController.gridLanguage.languageCode}';
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
                return '/${settingsController.gridLanguage.languageCode}';
              }

              // Synchronization: URL -> State
              if (settingsController.gridLanguage != targetLang) {
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
