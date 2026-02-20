import 'package:wordclock/logic/time_to_words.dart';

class EsperantoTimeToWords extends TimeToWords {
  @override
  String convert(DateTime time) {
    int hour = time.hour;
    int minute = time.minute;

    // Round down to the nearest 5 minute increment
    minute = minute - (minute % 5);

    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;

    // Based on Esperanto time telling conventions.
    // "estas la dua (horo)" - it is the second (hour)
    // "estas la dua kaj dek" - it is the second and ten

    final hourWord = _getHour(hour);

    // "estas la [hour]"
    final buffer = StringBuffer('ESTAS LA $hourWord');

    if (minute != 0) {
      // "kaj [minute]"
      buffer.write(' KAJ ${_getNumber(minute)}');
    }

    return buffer.toString();
  }

  String _getHour(int n) => switch (n) {
    1 => 'UNUA',
    2 => 'DUA',
    3 => 'TRIA',
    4 => 'KVARA',
    5 => 'KVINA',
    6 => 'SESA',
    7 => 'SEPA',
    8 => 'OKA',
    9 => 'NAŬA',
    10 => 'DEKA',
    11 => 'DEKUNUA',
    12 => 'DEKDUA',
    _ => '',
  };

  String _getNumber(int n) {
    if (n <= 12) {
      return switch (n) {
        1 => 'UNU',
        2 => 'DU',
        3 => 'TRI',
        4 => 'KVAR',
        5 => 'KVIN',
        6 => 'SES',
        7 => 'SEP',
        8 => 'OK',
        9 => 'NAŬ',
        10 => 'DEK',
        11 => 'DEK UNU',
        12 => 'DEK DU',
        _ => '',
      };
    }

    if (n < 20) return 'DEK ${_getNumber(n - 10)}';
    if (n == 20) return 'DUDEK';
    if (n < 30) return 'DUDEK ${_getNumber(n - 20)}';
    if (n == 30) return 'TRIDEK';
    if (n < 40) return 'TRIDEK ${_getNumber(n - 30)}';
    if (n == 40) return 'KVARDEK';
    if (n < 50) return 'KVARDEK ${_getNumber(n - 40)}';
    if (n == 50) return 'KVINDEK';
    if (n < 60) return 'KVINDEK ${_getNumber(n - 50)}';

    return '';
  }
}
