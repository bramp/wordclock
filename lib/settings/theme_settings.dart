import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum BackgroundType { solid, plasma }

class ThemeSettings {
  final List<Color> activeGradientColors;
  final Color inactiveColor;
  final Color backgroundColor;
  final bool showMinuteDots;
  final BackgroundType backgroundType;

  const ThemeSettings({
    required this.activeGradientColors,
    required this.inactiveColor,
    required this.backgroundColor,
    this.showMinuteDots = true,
    this.backgroundType = BackgroundType.plasma,
  });

  static const defaultTheme = ThemeSettings(
    activeGradientColors: [
      Color(0xFFFF00CC), // Purple
      Color(0xFF333399), // Dark Blue
      Color(0xFF00CCFF), // Light Blue
    ],
    inactiveColor: Color.fromRGBO(255, 255, 255, 0.15),
    backgroundColor: Colors.black,
    backgroundType: BackgroundType.plasma,
  );

  static const warmTheme = ThemeSettings(
    activeGradientColors: [
      Color(0xFFFF512F), // Orange
      Color(0xFFDD2476), // Pink/Red
    ],
    inactiveColor: Color.fromRGBO(255, 200, 200, 0.15),
    backgroundColor: Color(0xFF1A0505),
    backgroundType: BackgroundType.plasma,
  );

  static const matrixTheme = ThemeSettings(
    activeGradientColors: [
      Color(0xFF00FF00), // Bright Green
      Color(0xFF004400), // Dark Green
    ],
    inactiveColor: Color.fromRGBO(0, 255, 0, 0.15),
    backgroundColor: Colors.black,
    backgroundType: BackgroundType.plasma,
  );

  static const whiteTheme = ThemeSettings(
    activeGradientColors: [Colors.white, Colors.white],
    inactiveColor: Color.fromRGBO(255, 255, 255, 0.1),
    backgroundColor: Colors.black,
    backgroundType: BackgroundType.plasma,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ThemeSettings) return false;
    return listEquals(activeGradientColors, other.activeGradientColors) &&
        inactiveColor == other.inactiveColor &&
        backgroundColor == other.backgroundColor &&
        showMinuteDots == other.showMinuteDots &&
        backgroundType == other.backgroundType;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(activeGradientColors),
    inactiveColor,
    backgroundColor,
    showMinuteDots,
    backgroundType,
  );

  ThemeSettings copyWith({
    List<Color>? activeGradientColors,
    Color? inactiveColor,
    Color? backgroundColor,
    bool? showMinuteDots,
    BackgroundType? backgroundType,
  }) {
    return ThemeSettings(
      activeGradientColors: activeGradientColors ?? this.activeGradientColors,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      showMinuteDots: showMinuteDots ?? this.showMinuteDots,
      backgroundType: backgroundType ?? this.backgroundType,
    );
  }
}
