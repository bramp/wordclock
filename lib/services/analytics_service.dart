import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:wordclock/firebase_options.dart';

/// Service for handling Google Analytics events
class AnalyticsService {
  static FirebaseAnalytics? _analytics;
  static FirebaseAnalyticsObserver? _observer;

  /// Initialize Firebase and Analytics
  static Future<void> initialize() async {
    try {
      // Initialize Firebase on all platforms
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics!);
    } catch (e) {
      // Firebase initialization might fail if not configured for all platforms
      // This is expected for platforms without Firebase configuration
      if (kDebugMode) {
        print('Firebase Analytics initialization skipped: $e');
      }
    }
  }

  /// Get the analytics observer for navigation tracking
  static FirebaseAnalyticsObserver? get observer => _observer;

  /// Log a custom event
  static Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (_analytics != null) {
      await _analytics!.logEvent(name: name, parameters: parameters);
    }
  }

  /// Log when user changes language
  static Future<void> logLanguageChange(String languageCode) async {
    await logEvent(
      name: 'language_change',
      parameters: {'language': languageCode},
    );
  }

  /// Log when user changes theme settings
  static Future<void> logThemeChange({
    required String settingName,
    required String value,
  }) async {
    await logEvent(
      name: 'theme_change',
      parameters: {'setting_name': settingName, 'value': value},
    );
  }

  /// Log when user opens settings panel
  static Future<void> logSettingsOpened() async {
    await logEvent(name: 'settings_opened');
  }

  /// Log when user closes settings panel
  static Future<void> logSettingsClosed() async {
    await logEvent(name: 'settings_closed');
  }

  /// Log screen view
  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (_analytics != null) {
      await _analytics!.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    }
  }
}
