import 'package:wordclock/logic/time_to_words.dart';

/// Black Speech (Mordor) time telling.
///
/// Uses constructed "Neo-Black Speech" vocabulary.
///
/// Hours 1-12:
/// 1: ASH, 2: DUB, 3: GAKH, 4: ZAG, 5: KRA, 6: RAUK,
/// 7: UDU, 8: SKAI, 9: KRITH, 10: TOR, 11: USH, 12: GOTH.
///
/// Minutes: 0-59 (5 min increments).
class BlackSpeechTimeToWords extends TimeToWords {
  @override
  String convert(DateTime time) {
    int hour = time.hour;
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;

    final minute = time.minute;

    final hourWord = _getHour(hour);
    final minuteWord = minute == 0 ? '' : _getMinute(minute);

    final buffer = StringBuffer();
    // "GON" ~ Time/Hour
    buffer.write('$hourWord GON');

    if (minuteWord.isNotEmpty) {
      buffer.write(' $minuteWord');
    }

    return buffer.toString();
  }

  String _getHour(int n) {
    switch (n) {
      case 1:
        return 'ASH';
      case 2:
        return 'DUB';
      case 3:
        return 'GAKH';
      case 4:
        return 'ZAG';
      case 5:
        return 'KRA';
      case 6:
        return 'RAUK';
      case 7:
        return 'UDU';
      case 8:
        return 'SKAI';
      case 9:
        return 'KRITH';
      case 10:
        return 'TOR';
      case 11:
        return 'USH';
      case 12:
        return 'GOTH';
      default:
        return '';
    }
  }

  String _getMinute(int n) {
    // 0-4 -> handled by minute == 0 check externally? No, minute != 0.
    if (n < 5) {
      return 'KRA'; // >0, <5. Typically word clock shows '5' for 1-4 mins past.
    }
    if (n < 10) return 'KRA'; // [5, 10) -> 5
    if (n < 15) return 'TOR'; // [10, 15) -> 10
    if (n < 20) return 'TOR KRA'; // [15, 20) -> 15
    if (n < 25) return 'DUB TOR'; // [20, 25) -> 20
    if (n < 30) return 'DUB TOR KRA'; // [25, 30) -> 25
    if (n < 35) return 'GAKH TOR'; // [30, 35) -> 30
    if (n < 40) return 'GAKH TOR KRA'; // [35, 40) -> 35
    if (n < 45) return 'ZAG TOR'; // [40, 45) -> 40
    if (n < 50) return 'ZAG TOR KRA'; // [45, 50) -> 45
    if (n < 55) return 'KRA TOR'; // [50, 55) -> 50
    return 'KRA TOR KRA'; // [55, 60) -> 55
  }
}
