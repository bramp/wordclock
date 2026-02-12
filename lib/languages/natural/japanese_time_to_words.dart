import 'package:wordclock/logic/time_to_words.dart';

/// Base implementation for Japanese language.
abstract class _BaseJapaneseTimeToWords implements TimeToWords {
  final bool isReference;

  const _BaseJapaneseTimeToWords({required this.isReference});

  String getHour(int hour, bool isMidnight) {
    final h12 = hour % 12;
    if (h12 == 0 && isMidnight && !isReference) return '零時';
    return switch (h12) {
      0 => '十二時',
      1 => '一時',
      2 => '二時',
      3 => '三時',
      4 => '四時',
      5 => '五時',
      6 => '六時',
      7 => '七時',
      8 => '八時',
      9 => '九時',
      10 => '十時',
      11 => '十一時',
      _ => '',
    };
  }

  String getDelta(int minute) => switch (minute) {
    0 => 'です',
    5 => '五分 です',
    10 => '十分 です',
    15 => '十五分 です',
    20 => '二十分 です',
    25 => '二十五分 です',
    30 => '半 です',
    35 => 'まで あと 二十五分 です',
    40 => 'まで あと 二十分 です',
    45 => 'まで あと 十五分 です',
    50 => 'まで あと 十分 です',
    55 => 'まで あと 五分 です',
    _ => '',
  };

  @override
  String convert(DateTime time) {
    int m = time.minute;
    int h = time.hour;

    // Round down to nearest 5 minutes
    m = m - (m % 5);

    // Reference has special case for 30
    if (isReference && m == 30) {
      final hStr = getHour(h, false); // Reference doesn't use Reiji
      return '現在の時刻は $hStr半 です';
    }

    // hourDisplayLimit: 35
    if (m >= 35) {
      h++;
    }

    final hStr = getHour(h, h % 24 == 0);
    final delta = getDelta(m);

    if (m >= 35) {
      String words = isReference ? '現在の時刻は ' : '';
      return '$words$hStr $delta'.trim().replaceAll('  ', ' ');
    }

    String intro = isReference ? '現在の時刻は' : 'ただいま';
    return '$intro $hStr $delta'.trim().replaceAll('  ', ' ');
  }
}

/// Japanese (JP) Reference implementation.
class ReferenceJapaneseTimeToWords extends _BaseJapaneseTimeToWords {
  const ReferenceJapaneseTimeToWords() : super(isReference: true);
}

/// Japanese implementation.
/// Uses a more natural intro and handles "Reiji" (midnight).
class JapaneseTimeToWords extends _BaseJapaneseTimeToWords {
  const JapaneseTimeToWords() : super(isReference: false);
}
