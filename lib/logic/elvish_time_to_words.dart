import 'package:wordclock/logic/time_to_words.dart';

/// Sindarin Elvish time telling.
///
/// Uses "Hour Minute" format.
/// Hours: 1-12 (Min, Tad, Neled, Canad, Leben, Eneg, Odo, Toloth, Neder, Pae, Minib, Imp)
/// Minutes: 0-55 (5 minute steps).
///
/// Vocabulary based on Neo-Sindarin reconstructions.
/// Reference: https://www.elfdict.com/
class ElvishTimeToWords extends TimeToWords {
  @override
  String convert(DateTime time) {
    int hour = time.hour;
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;

    final minute = time.minute;

    final hourWord = _getNumber(hour);

    final buffer = StringBuffer();
    // "LÛ" = Time/Hour (Contextual).
    // Using "OR" (Day) or "DÛ" (Night) could be cool but complex.
    // Let's stick to "LÛ" as a generic marker if minute is 0, or just the number.
    // To fill the grid, let's add "LÛ" (Time).
    buffer.write('$hourWord LÛ');

    if (minute != 0) {
      final minuteWord = _getMinuteNumber(minute);
      buffer.write(' $minuteWord');
    }

    return buffer.toString();
  }

  String _getNumber(int n) {
    // 1-12
    switch (n) {
      case 1:
        return 'MIN';
      case 2:
        return 'TAD';
      case 3:
        return 'NELED';
      case 4:
        return 'CANAD';
      case 5:
        return 'LEBEN';
      case 6:
        return 'ENEG';
      case 7:
        return 'ODO';
      case 8:
        return 'TOLOTH';
      case 9:
        return 'NEDER';
      case 10:
        return 'PAE';
      case 11:
        return 'MINIB';
      case 12:
        return 'IMP';
      default:
        return '';
    }
  }

  String _getMinuteNumber(int n) {
    // 5-55
    if (n < 10) return _getNumber(n); // 5
    if (n == 10) return 'PAE';
    if (n == 15) return 'PAELEBEN'; // 15
    if (n == 20) return 'TAPHAE';
    if (n == 25) return 'TAPHAE LEBEN';
    if (n == 30) return 'NELPHAE';
    if (n == 35) return 'NELPHAE LEBEN';
    if (n == 40) return 'CANAPHAE';
    if (n == 45) return 'CANAPHAE LEBEN';
    if (n == 50) return 'LEPHAE';
    if (n == 55) return 'LEPHAE LEBEN';
    return '';
  }
}
