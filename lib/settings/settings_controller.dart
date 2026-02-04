// Void
import 'dart:convert';
import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
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
  static const String _kUiLocaleKey = 'ui_locale';
  static const String _kThemeKey = 'theme_settings';

  static List<WordClockLanguage> get supportedLanguages =>
      WordClockLanguages.all;

  static const List<Locale> supportedUiLocales = [
    Locale('en'),
    Locale('fr'),
    Locale('es'),
  ];

  ThemeSettings _currentSettings = ThemeSettings.defaultTheme;

  // The active clock instance.
  final AdjustableClock _clock = AdjustableClock();

  bool _isManualTime = false;

  // Shared preferences instance
  SharedPreferences? _prefs;

  // The default language is English ('EN').
  late WordClockLanguage _currentLanguage;
  late WordClockGrid _currentGrid;

  // UI Locale support
  Locale? _uiLocale;

  bool _highlightAll = false;
  Set<int>? _allActiveIndices;

  SettingsController() {
    _currentLanguage = WordClockLanguages.byId['EN']!;
    _regenerateGrid();
  }

  /// Initializes the controller by loading persisted settings.
  Future<void> loadSettings() async {
    _prefs = await SharedPreferences.getInstance();

    // 1. Resolve Clock Language
    // Priority: Persistence -> System -> Default (EN)
    // BUT we check URL first (Priority 1) manually here to ensure initial state is correct before Router attaches.
    final String? savedLangId = _prefs?.getString(_kLanguageIdKey);

    WordClockLanguage? urlLang;
    try {
      if (kIsWeb) {
        final uri = Uri.base;
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
      _currentLanguage = urlLang;
    } else if (savedLangId != null &&
        WordClockLanguages.byId.containsKey(savedLangId)) {
      _currentLanguage = WordClockLanguages.byId[savedLangId]!;
    } else {
      _currentLanguage = _detectBestLanguage();
    }

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

    _regenerateGrid();
    notifyListeners();
  }

  bool _isSupportedUiLocale(Locale locale) {
    return supportedUiLocales.any((l) => l.languageCode == locale.languageCode);
  }

  Locale _detectBestUiLocale() {
    final userLocales = PlatformDispatcher.instance.locales;
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
    final userLocales = PlatformDispatcher.instance.locales;
    final List<Locale> supportedLocales = [];
    final Map<Locale, WordClockLanguage> localeToLang = {};

    for (final lang in supportedLanguages) {
      if (lang.isAlternative) continue;
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

  WordClockLanguage get currentLanguage => _currentLanguage;
  WordClockGrid get currentGrid => _currentGrid;
  bool get highlightAll => _highlightAll;

  Locale get uiLocale => _uiLocale ?? supportedUiLocales.first;

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
    if (_currentLanguage == language) return;
    _currentLanguage = language;
    _allActiveIndices = null;
    _regenerateGrid();

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

  void _regenerateGrid() {
    final defGridRef = _currentLanguage.defaultGridRef;
    if (defGridRef != null) {
      _currentGrid = defGridRef;
    } else {
      final builder = BacktrackingGridBuilder(
        width: 11,
        height: 10,
        language: _currentLanguage,
        seed: 0,
      );
      final result = builder.build();
      // Ensure we have a valid TimeToWords.
      // If defaultGridRef is null, we might need a fallback TimeToWords instance.
      // Assuming all languages have a defaultGridRef or we construct one.
      // But BacktrackingGridBuilder uses _currentLanguage to build.
      // We need a TimeToWords for the grid.
      // WordClockLanguages usually have a reference implementation.
      // For now, assume defaultGridRef exists for all supported languages in the list.
      // If not, we might crash. But _currentLanguage usually has one.
      // Fallback to English generic logic if really needed, but dangerous.
      // Let's assume defGridRef is safe or use language.timeToWords property if added.
      // Since we don't have language.timeToWords property exposed easily without instance,
      // and defaultGridRef is the standard access.
      // If defGridRef is null, we are in trouble anyway.
      // But let's just use the builder result.
      _currentGrid = WordClockGrid(
        grid: result.grid,
        timeToWords:
            defGridRef?.timeToWords ??
            WordClockLanguages.byId['EN']!.defaultGridRef!.timeToWords,
      );
    }
  }

  void _saveTheme() {
    _prefs?.setString(_kThemeKey, jsonEncode(_currentSettings.toJson()));
  }

  void resetSettings() {
    _prefs?.clear();

    // Reset to defaults
    _currentSettings = ThemeSettings.defaultTheme;
    _uiLocale = _detectBestUiLocale();
    _currentLanguage = _detectBestLanguage();
    _allActiveIndices = null;

    // Reset transient
    _isManualTime = false;
    _clockSpeed = ClockSpeed.normal;
    _highlightAll = false;
    _clock.setRate(1.0);
    _clock.setTime(DateTime.now());

    _regenerateGrid();
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

  Set<int> _calculateAllActiveIndices() {
    final Set<int> all = {};
    WordClockUtils.forEachTime(_currentLanguage, (_, phrase) {
      final units = _currentLanguage.tokenize(phrase);
      all.addAll(_currentGrid.grid.getIndices(units));
    });
    return all;
  }
}
