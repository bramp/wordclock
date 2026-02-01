import 'package:wordclock/logic/time_to_words.dart';

class NativeJapaneseTimeToWords implements TimeToWords {
  const NativeJapaneseTimeToWords();
  @override
  String convert(DateTime time) {
    int m = time.minute;
    int h = time.hour;

    // Normalize hour (0-23 -> 1-12)
    int displayHour = h % 12;
    if (displayHour == 0) displayHour = 12;

    // AM/PM: "Gozen" (午前) / "Gogo" (午後)
    final period = h < 12 ? '午前' : '午後';
    final hStr = _getNumber(displayHour);

    return switch (m) {
      0 => '$period $hStr 時', // 時 = Ji = Hour
      30 => '$period $hStr 時 半', // 半 = Han = Half
      _ => '$period $hStr 時 ${_getNumber(m)} 分', // 分 = Fun = Minute
    };
  }

  /// Converts a number to its Japanese Kanji representation (up to 59).
  /// e.g., 45 -> 四十五 (Four-Ten-Five)
  String _getNumber(int n) {
    if (n <= 10) return _digit(n);
    if (n < 20) return '十${_digit(n - 10)}';

    final tens = n ~/ 10;
    final ones = n % 10;
    return '${_digit(tens)}十${_digit(ones)}';
  }

  String _digit(int n) => switch (n) {
    1 => '一', // One
    2 => '二', // Two
    3 => '三', // Three
    4 => '四', // Four
    5 => '五', // Five
    6 => '六', // Six
    7 => '七', // Seven
    8 => '八', // Eight
    9 => '九', // Nine
    10 => '十', // Ten
    _ => '',
  };
}

class ReferenceJapaneseTimeToWords implements TimeToWords {
  const ReferenceJapaneseTimeToWords();
  @override
  String convert(DateTime time) {
    int m = time.minute;
    int h = time.hour;

    // Round down to nearest 5 minutes
    m = m - (m % 5);

    // 1. Conditionals (Half-hours)
    // Note: Half-hour in scriptable data is a full override that doesn't use the segments.
    // We use h (0-23) here to match the scriptable engine's conditional lookup.
    // In JP's data, only hours 0..11 are defined in conditional.
    String? conditional = switch (m) {
      30 => switch (h % 12) {
        0 => '十二時半 です', // 0:30 midnight
        1 => '一時半 です', // 1:30
        2 => '二時半 です', // 2:30
        3 => '三時半 です', // 3:30
        4 => '四時半 です', // 4:30
        5 => '五時半 です', // 5:30
        6 => '六時半 です', // 6:30
        7 => '七時半 です', // 7:30
        8 => '八時半 です', // 8:30
        9 => '九時半 です', // 9:30
        10 => '十時半 です', // 10:30
        11 => '十一時半 です', // 11:30
        _ => null,
      },
      _ => null,
    };
    if (conditional != null) return '現在の時刻は $conditional';

    // 2. Normal logic (Intro + Delta + Exact)
    // hourDisplayLimit: 35
    if (m >= 35) {
      h++;
    }

    final displayHour = h % 12;

    String words = '現在の時刻は'; // The current time is (Intro)

    // 6. Exact hour (Matches 'e' in the data)
    String exact = switch (displayHour) {
      0 => '十二時', // 12 o'clock
      1 => '一時', // 1 o'clock
      2 => '二時', // 2 o'clock
      3 => '三時', // 3 o'clock
      4 => '四時', // 4 o'clock
      5 => '五時', // 5 o'clock
      6 => '六時', // 6 o'clock
      7 => '七時', // 7 o'clock
      8 => '八時', // 8 o'clock
      9 => '九時', // 9 o'clock
      10 => '十時', // 10 o'clock
      11 => '十一時', // 11 o'clock
      _ => '',
    };

    // 5. Delta (Matches 'd' in the data)
    String delta = switch (m) {
      0 => 'です', // is
      5 => '五分 です', // five minutes is
      10 => '十分 です', // ten minutes is
      15 => '十五分 です', // fifteen minutes is
      20 => '二十分 です', // twenty minutes is
      25 => '二十五分 です', // twenty-five minutes is
      30 => '半 です',
      35 => 'まで あと 二十五分 です', // until [next hour] remaining 25 minutes is
      40 => 'まで あと 二十分 です', // until [next hour] remaining 20 minutes is
      45 => 'まで あと 十五分 です', // until [next hour] remaining 15 minutes is
      50 => 'まで あと 十分 です', // until [next hour] remaining 10 minutes is
      55 => 'まで あと 五分 です', // until [next hour] remaining 5 minutes is
      _ => '',
    };

    words += " $exact";
    if (delta.isNotEmpty) words += " $delta";

    return words.replaceAll('  ', ' ').trim();
  }
}
