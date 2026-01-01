import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:wordclock/model/adjustable_clock.dart';

class ThemeSettings {
  final List<Color> activeGradientColors;
  final Color inactiveColor;
  final Color backgroundColor;
  final bool showMinuteDots;

  const ThemeSettings({
    required this.activeGradientColors,
    required this.inactiveColor,
    required this.backgroundColor,
    this.showMinuteDots = true,
  });

  static const defaultTheme = ThemeSettings(
    activeGradientColors: [
      Color(0xFFFF00CC), // Purple
      Color(0xFF333399), // Dark Blue
      Color(0xFF00CCFF), // Light Blue
    ],
    inactiveColor: Color.fromRGBO(255, 255, 255, 0.15),
    backgroundColor: Colors.black,
  );

  static const warmTheme = ThemeSettings(
    activeGradientColors: [
      Color(0xFFFF512F), // Orange
      Color(0xFFDD2476), // Pink/Red
    ],
    inactiveColor: Color.fromRGBO(255, 200, 200, 0.15),
    backgroundColor: Color(0xFF1A0505),
  );

  static const matrixTheme = ThemeSettings(
    activeGradientColors: [
      Color(0xFF00FF00), // Bright Green
      Color(0xFF004400), // Dark Green
    ],
    inactiveColor: Color.fromRGBO(0, 255, 0, 0.15),
    backgroundColor: Colors.black,
  );
}

enum ClockSpeed { normal, fast, hyper }

class SettingsController extends ChangeNotifier {
  ThemeSettings _currentSettings = ThemeSettings.defaultTheme;

  // The active clock instance.
  // We use AdjustableClock which allows shifting time and changing speed.
  // By default, it aligns with system time.
  final AdjustableClock _clock = AdjustableClock();

  // Track state simply to report to UI (though clock handles logic)
  bool _isManualTime = false;

  SettingsController(); // Constructor doesn't need init logic anymore

  ThemeSettings get settings => _currentSettings;

  /// Returns the clock instance.
  Clock get clock => _clock;

  ClockSpeed get clockSpeed => _clockSpeed;
  ClockSpeed _clockSpeed = ClockSpeed.normal;

  bool get isManualTime => _isManualTime;

  void updateTheme(ThemeSettings newSettings) {
    _currentSettings = newSettings;
    notifyListeners();
  }

  void setClockSpeed(ClockSpeed speed) {
    if (_clockSpeed == speed) return;
    _clockSpeed = speed;
    switch (speed) {
      case ClockSpeed.normal:
        _clock.setRate(1.0);
        break;
      case ClockSpeed.fast:
        _clock.setRate(60.0);
        break;
      case ClockSpeed.hyper:
        _clock.setRate(300.0);
        break;
    }
    notifyListeners();
  }

  void setManualTime(DateTime? time) {
    if (time != null) {
      _isManualTime = true;
      _clock.setTime(time);
    } else {
      _isManualTime = false;
      setClockSpeed(ClockSpeed.normal);
      _clock.setTime(DateTime.now());
    }
    notifyListeners();
  }
}
