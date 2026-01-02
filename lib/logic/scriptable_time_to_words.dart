import 'package:wordclock/logic/time_to_words.dart';

/// Represents a single word or phrase segment with its position on the grid.
class ScriptableWord {
  final String text;
  final int row;
  final int col;

  /// The number of grid cells this word occupies.
  /// Used for determining adjacency/overlap logic accurately, as one cell may contain multiple letters.
  final int span;

  ScriptableWord({
    required this.text,
    required this.row,
    required this.col,
    required this.span,
  });

  factory ScriptableWord.fromJson(Map<String, dynamic> json) {
    return ScriptableWord(
      text: json['t'] as String,
      row: json['r'] as int,
      col: json['c'] as int,
      span: json['s'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {'t': text, 'r': row, 'c': col, 's': span};

  @override
  String toString() => text;
}

/// Holds the raw grid and rules for a language from the Scriptable dataset.
class ScriptableLanguageData {
  final String grid;
  final int width;
  final int hourDisplayLimit;
  final List<ScriptableWord> intro;
  final Map<int, List<ScriptableWord>> exact;
  final Map<int, List<ScriptableWord>> delta;
  final Map<int, Map<int, List<ScriptableWord>>> conditional;

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
    List<ScriptableWord> parseList(dynamic list) {
      if (list == null) return [];
      return (list as List).map((x) => ScriptableWord.fromJson(x)).toList();
    }

    Map<int, List<ScriptableWord>> parseMap(Map<String, dynamic>? map) {
      if (map == null) return {};
      return map.map(
        (key, value) => MapEntry(int.parse(key), parseList(value)),
      );
    }

    Map<int, Map<int, List<ScriptableWord>>> parseConditional(
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
      intro: parseList(json['intro']),
      exact: parseMap(json['exact'] as Map<String, dynamic>?),
      delta: parseMap(json['delta'] as Map<String, dynamic>?),
      conditional: parseConditional(
        json['conditional'] as Map<String, dynamic>?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> serializeMap(Map<int, List<ScriptableWord>> map) {
      return map.map((key, value) => MapEntry(key.toString(), value));
    }

    Map<String, dynamic> serializeConditional(
      Map<int, Map<int, List<ScriptableWord>>> map,
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

    List<ScriptableWord> activeWords = [];

    // 1. Always add Intro words
    activeWords.addAll(data.intro);

    // 2. Check for conditional overrides
    if (data.conditional.containsKey(hour) &&
        data.conditional[hour]!.containsKey(minute)) {
      activeWords.addAll(data.conditional[hour]![minute]!);
    } else {
      // 3. Normal Logic
      if (minute >= data.hourDisplayLimit) {
        hour++;
      }

      int displayHour = hour;
      if (!data.exact.containsKey(displayHour)) {
        displayHour = hour % 12;
      }

      if (data.delta.containsKey(minute)) {
        activeWords.addAll(data.delta[minute]!);
      }

      if (data.exact.containsKey(displayHour)) {
        activeWords.addAll(data.exact[displayHour]!);
      }
    }

    // 4. De-duplicate words sharing the same start position
    final uniqueWordsMap = <String, ScriptableWord>{};
    for (final word in activeWords) {
      final key = '${word.row}:${word.col}';
      // If we encounter a duplicate start position, we assume it's the same word
      // (or at least one of them overlaps perfectly at start).
      // We keep the LAST added one usually, but here order doesn't strictly matter if identical.
      // However if widths differ, it's ambiguous. We assume identical definitions.
      uniqueWordsMap[key] = word;
    }

    final sortedWords = uniqueWordsMap.values.toList();

    // 5. Sort words by position
    sortedWords.sort((a, b) {
      if (a.row != b.row) {
        return a.row.compareTo(b.row);
      }
      return a.col.compareTo(b.col);
    });

    // 6. Merge adjacent or overlapping words
    final mergedWords = <ScriptableWord>[];
    if (sortedWords.isNotEmpty) {
      ScriptableWord current = sortedWords.first;
      for (int i = 1; i < sortedWords.length; i++) {
        final next = sortedWords[i];

        // We only merge if they are on the same row AND (adjacent OR overlapping).
        // Use span (grid cells) to determine adjacency, not text length.
        final int currentEnd = current.col + current.span;

        if (current.row == next.row && next.col <= currentEnd) {
          // Merge detected
          String newText = current.text;
          final int overlap = currentEnd - next.col;

          if (overlap > 0) {
            // Overlapping: One or more characters of the next word are already covered by current.
            // We only append the non-overlapping suffix.
            final int nextLen = next.text.length;
            if (overlap < nextLen) {
              newText += next.text.substring(overlap);
            }
          } else {
            // Adjacent
            newText += next.text;
          }

          // New span is from current.col to max(currentEnd, nextEnd)
          final int nextEnd = next.col + next.span;
          final int newSpan = (nextEnd > currentEnd)
              ? (nextEnd - current.col)
              : current.span;

          current = ScriptableWord(
            text: newText,
            row: current.row,
            col: current.col,
            span: newSpan,
          );
        } else {
          mergedWords.add(current);
          current = next;
        }
      }
      mergedWords.add(current);
    }

    return mergedWords.map((w) => w.text).join(' ');
  }
}
