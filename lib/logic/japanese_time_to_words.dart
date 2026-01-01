import 'package:wordclock/logic/time_to_words.dart';

class JapaneseTimeToWords implements TimeToWords {
  @override
  String get paddingChars => '東西南北春夏秋冬日月火水木金土山川海空星花鳥風月上下左右中心光闇世界';

  @override
  String convert(DateTime time) {
    int minute = time.minute;
    int hour = time.hour;

    // Normalize hour (0-23 -> 1-12)
    int displayHour = hour % 12;
    if (displayHour == 0) displayHour = 12;

    List<String> parts = [];

    // AM/PM
    // In Japanese, periods are often placed before the time.
    // "Gozen" (午前) = AM (Before noon)
    // "Gogo" (午後) = PM (After noon)
    if (hour < 12) {
      parts.add('午前');
    } else {
      parts.add('午後');
    }

    // Hour
    // Format: [Number] [Ji] (時 = Hour/Time)
    parts.addAll(_getNumber(displayHour));
    parts.add('時');

    // Minute
    // Format: [Number] [Fun] (分 = Minute)
    if (minute == 0) {
      // Exact hour, no minute part
    } else {
      if (minute == 30) {
        // "Han" (半) means "Half" (e.g., Half past)
        parts.add('半');
      } else {
        parts.addAll(_getNumber(minute));
        parts.add('分');
      }
    }

    return parts.join(' ');
  }

  /// Converts a number to its Japanese Kanji representation.
  /// Handles numbers up to 59 (sufficient for minutes).
  List<String> _getNumber(int n) {
    if (n <= 10) {
      return [_digit(n)];
    } else if (n < 20) {
      // 11-19: Ju (10) + digit
      // e.g. 11 = 十 (10) + 一 (1) = Ju-Ichi
      return ['十', _digit(n - 10)];
    } else {
      // 20+: digit + Ju (10) + [digit]
      // e.g. 21 = 二 (2) + 十 (10) + 一 (1) = Ni-Ju-Ichi
      int tens = n ~/ 10;
      int ones = n % 10;
      List<String> result = [_digit(tens), '十'];
      if (ones > 0) {
        result.add(_digit(ones));
      }
      return result;
    }
  }

  /// Returns the Kanji for a single digit (0-10).
  String _digit(int n) {
    switch (n) {
      case 1:
        return '一'; // Ichi
      case 2:
        return '二'; // Ni
      case 3:
        return '三'; // San
      case 4:
        return '四'; // Yon / Shi
      case 5:
        return '五'; // Go
      case 6:
        return '六'; // Roku
      case 7:
        return '七'; // Nana / Shichi
      case 8:
        return '八'; // Hachi
      case 9:
        return '九'; // Kyu / Ku
      case 10:
        return '十'; // Ju
      default:
        return '';
    }
  }
}
