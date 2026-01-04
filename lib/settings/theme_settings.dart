import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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

  static const whiteTheme = ThemeSettings(
    activeGradientColors: [Colors.white, Colors.white],
    inactiveColor: Color.fromRGBO(255, 255, 255, 0.1),
    backgroundColor: Colors.black,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ThemeSettings) return false;
    return listEquals(activeGradientColors, other.activeGradientColors) &&
        inactiveColor == other.inactiveColor &&
        backgroundColor == other.backgroundColor &&
        showMinuteDots == other.showMinuteDots;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(activeGradientColors),
    inactiveColor,
    backgroundColor,
    showMinuteDots,
  );
}
