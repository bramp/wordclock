import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Abstraction over platform-specific and static APIs to facilitate testing.
class PlatformService {
  const PlatformService();

  /// Returns true if the application is running on the web.
  bool get isWeb => kIsWeb;

  /// Returns the base URI of the application (relevant for web).
  Uri get baseUri => Uri.base;

  /// Returns the list of locales favored by the user.
  List<Locale> get systemLocales => PlatformDispatcher.instance.locales;

  /// Returns the instance of SharedPreferences.
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();
}
