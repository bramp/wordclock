import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:wordclock/model/adjustable_clock.dart';
import 'package:wordclock/generator/utils/word_clock_utils.dart';
import 'package:wordclock/settings/theme_settings.dart';
import 'package:wordclock/generator/grid_generator.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/languages/all.dart';

enum ClockSpeed { normal, fast, hyper }

class SettingsController extends ChangeNotifier {
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

  // The default language is English ('en').
  // Note: supportedLanguages is sorted by ID, so we look it up.
  WordClockLanguage _currentLanguage = WordClockLanguages.byId['EN']!;
  late WordGrid _currentGrid;

  bool _highlightAll = false;
  Set<int>? _allActiveIndices;

  SettingsController() {
    _regenerateGrid();
  }

  ThemeSettings get settings => _currentSettings;

  /// Returns the clock instance.
  Clock get clock => _clock;

  ClockSpeed get clockSpeed => _clockSpeed;
  ClockSpeed _clockSpeed = ClockSpeed.normal;

  bool get isManualTime => _isManualTime;

  int? get gridSeed => _gridSeed;
  WordClockLanguage get currentLanguage => _currentLanguage;
  WordGrid get currentGrid => _currentGrid;
  bool get highlightAll => _highlightAll;

  Set<int> get allActiveIndices {
    _allActiveIndices ??= _calculateAllActiveIndices();
    return _allActiveIndices!;
  }

  void updateTheme(ThemeSettings newSettings) {
    _currentSettings = newSettings;
    notifyListeners();
  }

  void setLanguage(WordClockLanguage language) {
    if (_currentLanguage == language) return;
    _currentLanguage = language;
    _allActiveIndices = null;
    _regenerateGrid();
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
    final defGrid = _currentLanguage.defaultGrid;
    if (_gridSeed == null && defGrid != null) {
      _currentGrid = defGrid;
    } else {
      final cells = GridGenerator.generate(
        width: 11,
        seed: _gridSeed,
        language: _currentLanguage,
      );
      _currentGrid = WordGrid(width: 11, cells: cells);
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
      all.addAll(_currentGrid.getIndices(units));
    });
    return all;
  }
}
