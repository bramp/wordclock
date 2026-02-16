import 'package:flutter/material.dart';

import 'package:wordclock/utils/font_helper.dart';

class FontStyles {
  /// Returns a TextStyle initialized with the correct Google Font for the given locale.
  ///
  /// This centralizes the font selection logic to ensure consistency across the app
  /// (Settings Panel, Letter Grid, etc.).
  static TextStyle getStyleForLocale(
    Locale locale, {
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? uiLocale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final languageCode = locale.languageCode;
    final scriptCode = locale.scriptCode;
    final countryCode = locale.countryCode;

    final fontFamily = FontHelper.getFontFamily(
      languageCode: languageCode,
      scriptCode: scriptCode,
      countryCode: countryCode,
    );

    TextStyle style = TextStyle(fontFamily: fontFamily);

    if (fontFamily == 'AlcarinTengwar') {
      // Boost the weight for Elvish as the font is naturally thin.
      // We shift the requested weight up by 200 (e.g. 400->600, 700->900).
      final baseWeight = fontWeight ?? FontWeight.w400;
      // Clamp to max 900
      final boostedValue = (baseWeight.value + 200).clamp(100, 900);
      final boostedWeight = FontWeight.values.firstWhere(
        (w) => w.value == boostedValue,
        orElse: () => FontWeight.w900,
      );

      // Also boost font size by 20% for better legibility
      final effectiveSize = (fontSize ?? 14.0) * 1.2;

      style = TextStyle(
        fontFamily: 'AlcarinTengwar',
        fontWeight: boostedWeight,
        fontSize: effectiveSize,
      );
      // We consumed fontWeight and fontSize, so don't apply them again
      fontWeight = null;
      fontSize = null;
    }

    // Apply the overrides
    return style
        .copyWith(
          color: color,
          backgroundColor: backgroundColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          wordSpacing: wordSpacing,
          textBaseline: textBaseline,
          height: height,
          locale:
              uiLocale, // Note: this is the TextStyle locale, not the font selection locale
          foreground: foreground,
          background: background,
          shadows: shadows,
          fontFeatures: fontFeatures,
          decoration: decoration,
          decorationColor: decorationColor,
          decorationStyle: decorationStyle,
          decorationThickness: decorationThickness,
        )
        .merge(textStyle); // Merge with base textStyle if provided
  }

  /// Convenience method to get a style for a language code directly
  static TextStyle getStyleForLanguage(
    String languageCode, {
    String? scriptCode,
    String? countryCode,
    TextStyle? textStyle,
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return getStyleForLocale(
      Locale.fromSubtags(
        languageCode: languageCode,
        scriptCode: scriptCode,
        countryCode: countryCode,
      ),
      textStyle: textStyle,
      color: color,
      fontWeight: fontWeight,
      fontSize: fontSize,
    );
  }
}
