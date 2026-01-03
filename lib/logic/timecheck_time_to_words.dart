import 'package:wordclock/logic/time_to_words.dart';

/// Represents a single word or phrase segment with its position on the grid.
class TimeCheckWord {
  final String text;
  final int row;
  final int col;

  /// The number of grid cells this word occupies.
  /// Used for determining adjacency/overlap logic accurately, as one cell may contain multiple letters.
  final int span;

  const TimeCheckWord({
    required this.text,
    required this.row,
    required this.col,
    required this.span,
  });

  factory TimeCheckWord.fromJson(Map<String, dynamic> json) {
    return TimeCheckWord(
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

/// Holds the raw grid and rules for a language from the TimeCheck dataset.
class TimeCheckLanguageData {
  final String grid;
  final int width;
  final int hourDisplayLimit;
  final List<TimeCheckWord> intro;
  final Map<int, List<TimeCheckWord>> exact;
  final Map<int, List<TimeCheckWord>> delta;
  final Map<int, Map<int, List<TimeCheckWord>>> conditional;
  final List<TimeCheckWord> padding;

  TimeCheckLanguageData({
    required this.grid,
    required this.width,
    required this.hourDisplayLimit,
    required this.intro,
    required this.exact,
    required this.delta,
    required this.conditional,
    required this.padding,
  });

  factory TimeCheckLanguageData.fromJson(Map<String, dynamic> json) {
    List<TimeCheckWord> parseList(dynamic list) {
      if (list == null) return [];
      return (list as List).map((x) => TimeCheckWord.fromJson(x)).toList();
    }

    Map<int, List<TimeCheckWord>> parseMap(Map<String, dynamic>? map) {
      if (map == null) return {};
      return map.map(
        (key, value) => MapEntry(int.parse(key), parseList(value)),
      );
    }

    Map<int, Map<int, List<TimeCheckWord>>> parseConditional(
      Map<String, dynamic>? map,
    ) {
      if (map == null) return {};
      return map.map(
        (key, value) =>
            MapEntry(int.parse(key), parseMap(value as Map<String, dynamic>)),
      );
    }

    final grid = json['grid'] as String;
    final width = json['width'] as int;
    final hourDisplayLimit = json['hourDisplayLimit'] as int;
    final intro = parseList(json['intro']);
    final exact = parseMap(json['exact'] as Map<String, dynamic>?);
    final delta = parseMap(json['delta'] as Map<String, dynamic>?);
    final conditional = parseConditional(
      json['conditional'] as Map<String, dynamic>?,
    );
    final padding = parseList(json['padding']);

    return TimeCheckLanguageData(
      grid: grid,
      width: width,
      hourDisplayLimit: hourDisplayLimit,
      intro: intro,
      exact: exact,
      delta: delta,
      conditional: conditional,
      padding: padding,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> serializeMap(Map<int, List<TimeCheckWord>> map) {
      return map.map((key, value) => MapEntry(key.toString(), value));
    }

    Map<String, dynamic> serializeConditional(
      Map<int, Map<int, List<TimeCheckWord>>> map,
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
      'padding': padding,
    };
  }
}

/// Implements TimeToWords from the TimeCheck dataset.
class TimeCheckTimeToWords implements TimeToWords {
  final TimeCheckLanguageData data;
  TimeCheckTimeToWords(this.data);

  @override
  String convert(DateTime time) {
    int minute = time.minute;
    int hour = time.hour;

    // Round down to nearest 5 minutes
    minute = minute - (minute % 5);

    List<TimeCheckWord> activeWords = [];

    // 1. Always add Intro words
    activeWords.addAll(data.intro);

    // 2. Check for conditional overrides
    if (data.conditional.containsKey(hour) &&
        data.conditional[hour]!.containsKey(minute)) {
      activeWords.addAll(data.conditional[hour]![minute]!);
    } else if (data.conditional.containsKey(hour % 12) &&
        data.conditional[hour % 12]!.containsKey(minute)) {
      activeWords.addAll(data.conditional[hour % 12]![minute]!);
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
    final uniqueWordsMap = <String, TimeCheckWord>{};
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
    final mergedWords = <TimeCheckWord>[];
    if (sortedWords.isNotEmpty) {
      TimeCheckWord current = sortedWords.first;
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

          current = TimeCheckWord(
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
