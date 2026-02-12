import 'package:flutter/material.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/languages/all.dart';

/// Helper utilities for handling [Locale] and [WordClockLanguage] mapping.
class LocaleHelper {
  /// Parses a BCP47 language tag (e.g., 'en', 'en-US', 'zh-Hans-CN') into a [Locale].
  static Locale parseLocale(String languageCode) {
    final parts = languageCode.split('-');
    if (parts.length == 1) {
      return Locale(parts[0]);
    }
    if (parts.length == 2) {
      // Check if the second part is a 4-character script code (e.g., 'Hans', 'Hant')
      if (parts[1].length == 4) {
        return Locale.fromSubtags(languageCode: parts[0], scriptCode: parts[1]);
      }
      return Locale(parts[0], parts[1]);
    }
    if (parts.length == 3) {
      return Locale.fromSubtags(
        languageCode: parts[0],
        scriptCode: parts[1],
        countryCode: parts[2],
      );
    }
    return Locale(parts[0]);
  }

  /// Resolves the best matching [WordClockLanguage] from a list of user preferred [locales].
  static WordClockLanguage detectBestLanguage(Iterable<Locale> userLocales) {
    final List<Locale> supportedLocales = [];
    final Map<Locale, WordClockLanguage> localeToLang = {};

    // Ensure English is added first to be the default fallback.
    final enLang = WordClockLanguages.byId['EN'];
    if (enLang != null) {
      final enLocale = parseLocale(enLang.languageCode);
      supportedLocales.add(enLocale);
      localeToLang[enLocale] = enLang;
    }

    for (final lang in WordClockLanguages.all) {
      if (lang.isHidden) continue;
      if (lang.isAlternative) continue;
      if (lang.id == 'EN') continue;

      final locale = parseLocale(lang.languageCode);
      // Only keep the first encounter for a locale, or one that has a description
      if (!localeToLang.containsKey(locale)) {
        localeToLang[locale] = lang;
        if (!supportedLocales.contains(locale)) {
          supportedLocales.add(locale);
        }
      }
    }

    final resolvedLocale = basicLocaleListResolution(
      userLocales.toList(),
      supportedLocales,
    );

    return localeToLang[resolvedLocale] ??
        WordClockLanguages.byId['EN'] ??
        WordClockLanguages.all.first;
  }
}
