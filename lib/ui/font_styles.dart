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

    // Common arguments for GoogleFonts methods
    // We pass these down so GoogleFonts handles them properly
    // Note: not all args are supported by all GoogleFonts factories directly,
    // but most return a TextStyle that supports copyWith or are full TextStyles.
    // The GoogleFonts package methods typically accept most TextStyle properties.

    // Helper to call specific factory
    TextStyle style;
    switch (fontFamily) {
      case 'NotoSansTamil':
        style = const TextStyle(fontFamily: 'Noto Sans Tamil');
      case 'NotoSansJP':
        style = const TextStyle(fontFamily: 'Noto Sans JP');
      case 'NotoSansSC':
        style = const TextStyle(fontFamily: 'Noto Sans SC');
      case 'NotoSansTC':
        style = const TextStyle(fontFamily: 'Noto Sans TC');
      case 'KlingonPiqad':
        style = const TextStyle(fontFamily: 'KlingonPiqad');
      case 'NotoSans':
      default:
        style = const TextStyle(fontFamily: 'Noto Sans');
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
