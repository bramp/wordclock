import 'package:wordclock/logic/time_to_words.dart';

/// Holds the raw grid and rules for a language from the Scriptable dataset.
class ScriptableLanguageData {
  final String grid;
  final int width;
  final int hourDisplayLimit;
  final List<String> intro;
  final Map<int, List<String>> exact;
  final Map<int, List<String>> delta;
  final Map<int, Map<int, List<String>>> conditional;

  ScriptableLanguageData({
    required this.grid,
    required this.width,
    required this.hourDisplayLimit,
    required this.intro,
    required this.exact,
    required this.delta,
    required this.conditional,
  });

  factory ScriptableLanguageData.fromJson(Map<String, dynamic> json) {
    Map<int, List<String>> parseMap(Map<String, dynamic>? map) {
      if (map == null) return {};
      return map.map(
        (key, value) => MapEntry(int.parse(key), List<String>.from(value)),
      );
    }

    Map<int, Map<int, List<String>>> parseConditional(
      Map<String, dynamic>? map,
    ) {
      if (map == null) return {};
      return map.map(
        (key, value) =>
            MapEntry(int.parse(key), parseMap(value as Map<String, dynamic>)),
      );
    }

    return ScriptableLanguageData(
      grid: json['grid'] as String,
      width: json['width'] as int,
      hourDisplayLimit: json['hourDisplayLimit'] as int,
      intro: List<String>.from(json['intro'] ?? []),
      exact: parseMap(json['exact'] as Map<String, dynamic>?),
      delta: parseMap(json['delta'] as Map<String, dynamic>?),
      conditional: parseConditional(
        json['conditional'] as Map<String, dynamic>?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> serializeMap(Map<int, List<String>> map) {
      return map.map((key, value) => MapEntry(key.toString(), value));
    }

    Map<String, dynamic> serializeConditional(
      Map<int, Map<int, List<String>>> map,
    ) {
      return map.map(
        (key, value) => MapEntry(key.toString(), serializeMap(value)),
      );
    }

    return {
      'grid': grid,
      'width': width,
      'hourDisplayLimit': hourDisplayLimit,
      'intro': intro,
      'exact': serializeMap(exact),
      'delta': serializeMap(delta),
      'conditional': serializeConditional(conditional),
    };
  }
}

/// Implements TimeToWords from the ScriptableWordClockWidget dataset.
class ScriptableTimeToWords implements TimeToWords {
  final ScriptableLanguageData data;
  ScriptableTimeToWords(this.data);

  @override
  String convert(DateTime time) {
    int minute = time.minute;
    int hour = time.hour;

    // Round down to nearest 5 minutes
    minute = minute - (minute % 5);

    // 1. Check for conditional overrides (e.g. Noon/Midnight)
    if (data.conditional.containsKey(hour) &&
        data.conditional[hour]!.containsKey(minute)) {
      return data.conditional[hour]![minute]!.join(' ');
    }

    // 2. Determine if we should display the next hour (e.g. 'Ten to FIVE')
    if (minute >= data.hourDisplayLimit) {
      hour++;
    }

    // 3. Normalize hour for lookup
    int displayHour = hour;
    if (!data.exact.containsKey(displayHour)) {
      displayHour = hour % 12;
    }

    List<String> words = [];

    // 4. Add Intro words (e.g. 'IT IS')
    words.addAll(data.intro);

    // 5. Add Delta words (e.g. 'TEN PAST')
    if (data.delta.containsKey(minute)) {
      words.addAll(data.delta[minute]!);
    }

    // 6. Add Exact hour words (e.g. 'FIVE')
    if (data.exact.containsKey(displayHour)) {
      words.addAll(data.exact[displayHour]!);
    }

    return words.join(' ');
  }
}
