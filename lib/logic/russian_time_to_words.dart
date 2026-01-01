import 'package:wordclock/logic/time_to_words.dart';

class RussianTimeToWords implements TimeToWords {
  static const hours = [
    'ДВЕНАДЦАТЬ', // Twelve
    'ОДИН', // One
    'ДВА', // Two
    'ТРИ', // Three
    'ЧЕТЫРЕ', // Four
    'ПЯТЬ', // Five
    'ШЕСТЬ', // Six
    'СЕМЬ', // Seven
    'ВОСЕМЬ', // Eight
    'ДЕВЯТЬ', // Nine
    'ДЕСЯТЬ', // Ten
    'ОДИННАДЦАТЬ', // Eleven
  ];

  static const minutes = {
    5: 'ПЯТЬ МИНУТ', // Five minutes
    10: 'ДЕСЯТЬ МИНУТ', // Ten minutes
    15: 'ПЯТНАДЦАТЬ МИНУТ', // Fifteen minutes
    20: 'ДВАДЦАТЬ МИНУТ', // Twenty minutes
    25: 'ДВАДЦАТЬ ПЯТЬ МИНУТ', // Twenty-five minutes
    30: 'ТРИДЦАТЬ МИНУТ', // Thirty minutes
    35: 'ТРИДЦАТЬ ПЯТЬ МИНУТ', // Thirty-five minutes
    40: 'СОРОК МИНУТ', // Forty minutes
    45: 'СОРОК ПЯТЬ МИНУТ', // Forty-five minutes
    50: 'ПЯТЬДЕСЯТ МИНУТ', // Fifty minutes
    55: 'ПЯТЬДЕСЯТ ПЯТЬ МИНУТ', // Fifty-five minutes
  };

  @override
  String convert(DateTime time) {
    int h = time.hour;
    int m = (time.minute ~/ 5) * 5; // Round down to nearest 5

    int displayHour = h % 12;

    String hLabel(int hr) {
      if (hr == 1) return 'ЧАС'; // Hour
      if (hr == 2 || hr == 3 || hr == 4) {
        return '${hours[hr]} ЧАСА'; // Hour (genitive singular)
      }
      return '${hours[hr]} ЧАСОВ'; // Hours (genitive plural)
    }

    return switch (m) {
      0 => 'СЕЙЧАС ${hLabel(displayHour)}', // NOW X o'clock
      30 => '${hLabel(displayHour)} ПОЛОВИНА', // Half
      _ => '${hLabel(displayHour)} ${minutes[m]}',
    };
  }
}
