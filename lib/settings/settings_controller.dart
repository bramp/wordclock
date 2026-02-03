import 'dart:ui' show PlatformDispatcher;
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wordclock/model/adjustable_clock.dart';
import 'package:wordclock/generator/utils/word_clock_utils.dart';
import 'package:wordclock/services/analytics_service.dart';
import 'package:wordclock/settings/theme_settings.dart';
import 'package:wordclock/generator/backtracking/grid_builder.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/languages/all.dart';

enum ClockSpeed { normal, fast, hyper }

class SettingsController extends ChangeNotifier {
  static const String _kLanguageIdKey = 'preferred_language_id';

  static List<WordClockLanguage> get supportedLanguages =>
      WordClockLanguages.all;

  ThemeSettings _currentSettings = ThemeSettings.defaultTheme;

  // The active clock instance.
  // We use AdjustableClock which allows shifting time and changing speed.
  // By default, it aligns with system time.
  final AdjustableClock _clock = AdjustableClock();

  // Track state simply to report to UI (though clock handles logic)
  bool _isManualTime = false;

  // Dynamic Grid State
  int? _gridSeed; // null = use default static grid

  // Shared preferences instance
  SharedPreferences? _prefs;

  // The default language is English ('EN').
  // Note: supportedLanguages is sorted by ID, so we look it up.
  late WordClockLanguage _currentLanguage;
  late WordClockGrid _currentGrid;

  bool _highlightAll = false;
  Set<int>? _allActiveIndices;

  SettingsController() {
    // We initialize with a safe default.
    // Call loadSettings() to override this with persisted or detected language.
    _currentLanguage = WordClockLanguages.byId['EN']!;
    _regenerateGrid();
  }

  /// Initializes the controller by loading persisted settings.
  Future<void> loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    final String? savedLangId = _prefs?.getString(_kLanguageIdKey);

    if (savedLangId != null &&
        WordClockLanguages.byId.containsKey(savedLangId)) {
      _currentLanguage = WordClockLanguages.byId[savedLangId]!;
    } else {
      // No saved preference, try to match system locale.
      _currentLanguage = _detectBestLanguage();
    }
    _regenerateGrid();
    notifyListeners();
  }

  /// Parses a BCP47 language tag (e.g., 'en-US', 'zh-Hans-CN') into a Flutter Locale.
  Locale _parseLocale(String languageCode) {
    final parts = languageCode.split('-');
    if (parts.length == 1) {
      return Locale(parts[0]);
    }
    if (parts.length == 2) {
      // Could be language-country or language-script
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
    final userLocales = PlatformDispatcher.instance.locales;

    // Map supported languages to Flutter Locales for resolution
    final List<Locale> supportedLocales = [];
    final Map<Locale, WordClockLanguage> localeToLang = {};

    for (final lang in supportedLanguages) {
      if (lang.isAlternative) {
        continue;
      }

      final locale = _parseLocale(lang.languageCode);

      // Record the mapping. If multiple non-alternative languages share a
      // locale, we prioritize the one without a description.
      if (!localeToLang.containsKey(locale) ||
          (lang.description == null || lang.description!.isEmpty)) {
        localeToLang[locale] = lang;
        if (!supportedLocales.contains(locale)) {
          supportedLocales.add(locale);
        }
      }
    }

    // Use Flutter's built-in resolution algorithm
    final resolvedLocale = basicLocaleListResolution(
      userLocales,
      supportedLocales,
    );

    return localeToLang[resolvedLocale] ??
        WordClockLanguages.byId['EN'] ??
        supportedLanguages.first;
  }

  ThemeSettings get settings => _currentSettings;

  /// Returns the clock instance.
  Clock get clock => _clock;

  ClockSpeed get clockSpeed => _clockSpeed;
  ClockSpeed _clockSpeed = ClockSpeed.normal;

  bool get isManualTime => _isManualTime;

  int? get gridSeed => _gridSeed;
  WordClockLanguage get currentLanguage => _currentLanguage;
  WordClockGrid get currentGrid => _currentGrid;
  bool get highlightAll => _highlightAll;

  Set<int> get allActiveIndices {
    _allActiveIndices ??= _calculateAllActiveIndices();
    return _allActiveIndices!;
  }

  void updateTheme(ThemeSettings newSettings) {
    // Preserve the user's plasma preference when switching themes
    _currentSettings = newSettings.copyWith(
      backgroundType: _currentSettings.backgroundType,
    );
    notifyListeners();
  }

  void setBackgroundType(BackgroundType type) {
    if (_currentSettings.backgroundType == type) return;
    _currentSettings = _currentSettings.copyWith(backgroundType: type);

    // Track background type change in analytics
    AnalyticsService.logThemeChange(
      settingName: 'background_type',
      value: type.toString(),
    );

    notifyListeners();
  }

  void setLanguage(WordClockLanguage language) {
    if (_currentLanguage == language) return;
    _currentLanguage = language;
    _allActiveIndices = null;
    _regenerateGrid();

    // Persist the selection
    _prefs?.setString(_kLanguageIdKey, language.id);

    // Track language change in analytics
    AnalyticsService.logLanguageChange(language.id);

    notifyListeners();
  }

  void setGridSeed(int? seed) {
    if (_gridSeed == seed) return;
    _gridSeed = seed;
    _allActiveIndices = null;
    _regenerateGrid();
    notifyListeners();
  }

  void _regenerateGrid() {
    final defGridRef = _currentLanguage.defaultGridRef;
    if (_gridSeed == null && defGridRef != null) {
      _currentGrid = defGridRef;
    } else {
      final builder = BacktrackingGridBuilder(
        width: 11,
        height: 10,
        language: _currentLanguage,
        seed: _gridSeed ?? 0,
      );
      final result = builder.build();
      _currentGrid = WordClockGrid(
        grid: result.grid,
        timeToWords: defGridRef!.timeToWords,
      );
    }
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

  Set<int> _calculateAllActiveIndices() {
    final Set<int> all = {};
    WordClockUtils.forEachTime(_currentLanguage, (_, phrase) {
      final units = _currentLanguage.tokenize(phrase);
      all.addAll(_currentGrid.grid.getIndices(units));
    });
    return all;
  }
}
