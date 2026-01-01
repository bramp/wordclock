import 'package:wordclock/logic/time_to_words.dart';

class JapaneseTimeToWords implements TimeToWords {
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
  String _getNumber(int n) {
    if (n <= 10) return _digit(n);
    if (n < 20) return '十 ${_digit(n - 10)}'.trim();

    final tens = n ~/ 10;
    final ones = n % 10;
    return '${_digit(tens)} 十 ${_digit(ones)}'.trim();
  }

  String _digit(int n) => switch (n) {
    1 => '一',
    2 => '二',
    3 => '三',
    4 => '四',
    5 => '五',
    6 => '六',
    7 => '七',
    8 => '八',
    9 => '九',
    10 => '十',
    _ => '',
  };
}
