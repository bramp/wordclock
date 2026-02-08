// Void
import 'dart:convert';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wordclock/model/adjustable_clock.dart';
import 'package:wordclock/generator/utils/word_clock_utils.dart';
import 'package:wordclock/services/analytics_service.dart';
import 'package:wordclock/settings/theme_settings.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/languages/all.dart';
import 'package:wordclock/services/platform_service.dart';

enum ClockSpeed { normal, fast, hyper }

class SettingsController extends ChangeNotifier {
  static const String _kLanguageIdKey = 'preferred_language_id';
  static const String _kUiLocaleKey = 'ui_locale';
  static const String _kThemeKey = 'theme_settings';
  static const String _kAnalyticsConsentKey = 'analytics_consent';

  static List<WordClockLanguage> get supportedLanguages =>
      WordClockLanguages.all;

  // TODO Update this based on what is actually supported.
  static const List<Locale> supportedUiLocales = [
    Locale('en'),
    //Locale('fr'),
    //Locale('es'),
  ];

  ThemeSettings _currentSettings = ThemeSettings.defaultTheme;

  // The active clock instance.
  final AdjustableClock _clock = AdjustableClock();

  bool _isManualTime = false;

  // Shared preferences instance
  SharedPreferences? _prefs;

  final PlatformService _platform;

  // The default language is English ('EN').
  // The default language is English ('EN').
  late WordClockLanguage _gridLanguage;
  late WordClockGrid _grid;

  // UI Locale support
  Locale? _uiLocale;

  // Analytics consent
  bool? _analyticsConsent;

  bool _highlightAll = false;
  Set<int>? _allActiveIndices;

  SettingsController({PlatformService? platformService})
    : _platform = platformService ?? const PlatformService() {
    _gridLanguage = WordClockLanguages.byId['EN']!;
    _updateGrid();
  }

  /// Initializes the controller by loading persisted settings.
  Future<void> loadSettings() async {
    _prefs = await _platform.sharedPreferences;

    _resolveLanguage();
    _resolveUiLocale();
    _loadTheme();
    _resolveAnalyticsConsent();

    notifyListeners();
  }

  /// Resolves the grid language to use based on the following priority:
  ///
  /// 1. URL Path/Fragment (if on Web): e.g. /en-US or #/es-ES (BCP 47 locales)
  /// 2. Persisted preference: The language ID previously saved by the user (e.g. 'EN', 'ES').
  /// 3. System Locale: The best match for the user's device locale.
  /// 4. Default: English ('EN').
  void _resolveLanguage() {
    // 1. Resolve Clock Language
    // Priority: Persistence -> System -> Default (EN)
    // BUT we check URL first (Priority 1) manually here to ensure initial state is correct before Router attaches.
    final String? savedLangId = _prefs?.getString(_kLanguageIdKey);

    WordClockLanguage? urlLang;
    try {
      if (_platform.isWeb) {
        final uri = _platform.baseUri;
        for (final segment in uri.pathSegments) {
          final lang = WordClockLanguages.findByCode(segment);
          if (lang != null) {
            urlLang = lang;
            break;
          }
        }
        if (urlLang == null && uri.hasFragment) {
          final parts = uri.fragment.split('/');
          for (final part in parts) {
            final lang = WordClockLanguages.findByCode(part);
            if (lang != null) {
              urlLang = lang;
              break;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error parsing URI: $e');
    }

    if (urlLang != null) {
      _gridLanguage = urlLang;
    } else if (savedLangId != null &&
        WordClockLanguages.byId.containsKey(savedLangId)) {
      _gridLanguage = WordClockLanguages.byId[savedLangId]!;
    } else {
      _gridLanguage = _detectBestLanguage();
    }
    _updateGrid();
  }

  void _resolveUiLocale() {
    // 2. Resolve UI Locale
    // Priority: Persistence -> System -> Default (first supported)
    final String? savedUiLocale = _prefs?.getString(_kUiLocaleKey);
    if (savedUiLocale != null) {
      final parts = savedUiLocale.split('_');
      final locale = parts.length > 1
          ? Locale(parts[0], parts[1])
          : Locale(parts[0]);

      if (_isSupportedUiLocale(locale)) {
        _uiLocale = locale;
      }
    }

    // If no persistence, try to match system
    _uiLocale ??= _detectBestUiLocale();
  }

  void _loadTheme() {
    // 3. Resolve Theme
    final String? savedThemeJson = _prefs?.getString(_kThemeKey);
    if (savedThemeJson != null) {
      try {
        _currentSettings = ThemeSettings.fromJson(
          jsonDecode(savedThemeJson) as Map<String, dynamic>,
        );
      } catch (e) {
        debugPrint('Error loading theme settings: $e');
      }
    }
  }

  void _resolveAnalyticsConsent() {
    // 4. Resolve Analytics Consent
    final bool? consented = _prefs?.getBool(_kAnalyticsConsentKey);
    _analyticsConsent = consented;

    // If explicit consent is stored, respect it.
    // Otherwise, default to disabled until user decides.
    AnalyticsService.setAnalyticsCollectionEnabled(consented ?? false);
  }

  bool _isSupportedUiLocale(Locale locale) {
    return supportedUiLocales.any((l) => l.languageCode == locale.languageCode);
  }

  Locale _detectBestUiLocale() {
    final userLocales = _platform.systemLocales;
    return basicLocaleListResolution(userLocales, supportedUiLocales);
  }

  // ... (Existing _parseLocale and _detectBestLanguage methods remain valid for Clock Language)
  Locale _parseLocale(String languageCode) {
    final parts = languageCode.split('-');
    if (parts.length == 1) {
      return Locale(parts[0]);
    }
    if (parts.length == 2) {
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

  WordClockLanguage _detectBestLanguage() {
    final userLocales = _platform.systemLocales;
    final List<Locale> supportedLocales = [];
    final Map<Locale, WordClockLanguage> localeToLang = {};

    // Ensure English is added first to be the default fallback if no other locale matches.
    if (WordClockLanguages.byId.containsKey('EN')) {
      final enLang = WordClockLanguages.byId['EN']!;
      final enLocale = _parseLocale(enLang.languageCode);
      supportedLocales.add(enLocale);
      localeToLang[enLocale] = enLang;
    }

    for (final lang in supportedLanguages) {
      if (lang.isAlternative) continue;
      // Skip if already added (English)
      if (lang.id == 'EN') continue;

      final locale = _parseLocale(lang.languageCode);
      if (!localeToLang.containsKey(locale) ||
          (lang.description == null || lang.description!.isEmpty)) {
        localeToLang[locale] = lang;
        if (!supportedLocales.contains(locale)) {
          supportedLocales.add(locale);
        }
      }
    }
    final resolvedLocale = basicLocaleListResolution(
      userLocales,
      supportedLocales,
    );
    return localeToLang[resolvedLocale] ??
        WordClockLanguages.byId['EN'] ??
        supportedLanguages.first;
  }

  ThemeSettings get settings => _currentSettings;

  Clock get clock => _clock;

  ClockSpeed get clockSpeed => _clockSpeed;
  ClockSpeed _clockSpeed = ClockSpeed.normal;

  bool get isManualTime => _isManualTime;

  WordClockLanguage get gridLanguage => _gridLanguage;
  WordClockGrid get grid => _grid;
  bool get highlightAll => _highlightAll;

  Locale get uiLocale => _uiLocale ?? supportedUiLocales.first;

  bool? get analyticsConsent => _analyticsConsent;

  Set<int> get allActiveIndices {
    _allActiveIndices ??= _calculateAllActiveIndices();
    return _allActiveIndices!;
  }

  void updateTheme(ThemeSettings newSettings) {
    _currentSettings = newSettings.copyWith(
      backgroundType: _currentSettings.backgroundType,
    );
    _saveTheme();
    notifyListeners();
  }

  void setBackgroundType(BackgroundType type) {
    if (_currentSettings.backgroundType == type) return;
    _currentSettings = _currentSettings.copyWith(backgroundType: type);
    AnalyticsService.logThemeChange(
      settingName: 'background_type',
      value: type.toString(),
    );
    _saveTheme();
    notifyListeners();
  }

  void setLanguage(WordClockLanguage language) {
    if (_gridLanguage == language) return;
    _gridLanguage = language;
    _allActiveIndices = null;
    _updateGrid();

    _prefs?.setString(_kLanguageIdKey, language.id);
    AnalyticsService.logLanguageChange(language.id);

    notifyListeners();
  }

  void setUiLocale(Locale locale) {
    if (_uiLocale == locale) return;

    // Ensure it's supported
    if (!_isSupportedUiLocale(locale)) return;

    _uiLocale = locale;
    _prefs?.setString(_kUiLocaleKey, locale.toString());

    notifyListeners();
  }

  void _updateGrid() {
    _grid =
        _gridLanguage.defaultGridRef ??
        WordClockLanguages.byId['EN']!.defaultGridRef!;
  }

  void _saveTheme() {
    _prefs?.setString(_kThemeKey, jsonEncode(_currentSettings.toJson()));
  }

  void resetSettings() {
    _prefs?.clear();

    // Reset to defaults
    _currentSettings = ThemeSettings.defaultTheme;
    _uiLocale = _detectBestUiLocale();
    _gridLanguage = _detectBestLanguage();
    _allActiveIndices = null;

    // Reset transient
    _isManualTime = false;
    _clockSpeed = ClockSpeed.normal;
    _highlightAll = false;
    _clock.setRate(1.0);
    _clock.setTime(DateTime.now());

    _updateGrid();
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

  void toggleHighlightAll() {
    _highlightAll = !_highlightAll;
    notifyListeners();
  }

  void setAnalyticsConsent(bool consented) {
    if (_analyticsConsent == consented) return;
    _analyticsConsent = consented;
    _prefs?.setBool(_kAnalyticsConsentKey, consented);
    AnalyticsService.setAnalyticsCollectionEnabled(consented);
    notifyListeners();
  }

  Set<int> _calculateAllActiveIndices() {
    final Set<int> all = {};
    WordClockUtils.forEachTime(_gridLanguage, (_, phrase) {
      final units = _gridLanguage.tokenize(phrase);
      all.addAll(_grid.grid.getIndices(units));
    });
    return all;
  }
}
