import 'package:wordclock/logic/time_to_words.dart';

class RussianTimeToWords implements TimeToWords {
  static const hours = [
    'ДВЕНАДЦАТЬ', // Twelve
    'ЧАС', // One (lit: "Hour")
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

  // Genitive case for hours (used in "X of the Y-th hour")
  static const hoursGenitive = [
    'ДВЕНАДЦАТОГО', // Twelfth
    'ПЕРВОГО', // First
    'ВТОРОГО', // Second
    'ТРЕТЬЕГО', // Third
    'ЧЕТВЕРТОГО', // Fourth
    'ПЯТОГО', // Fifth
    'ШЕСТОГО', // Sixth
    'СЕДЬМОГО', // Seventh
    'ВОСЬМОГО', // Eighth
    'ДЕВЯТОГО', // Ninth
    'ДЕСЯТОГО', // Tenth
    'ОДИННАДЦАТОГО', // Eleventh
  ];

  static const minutes = {
    5: 'ПЯТЬ', // Five
    10: 'ДЕСЯТЬ', // Ten
    15: 'ЧЕТВЕРТЬ', // Quarter
    20: 'ДВАДЦАТЬ', // Twenty
    25: 'ДВАДЦАТЬ ПЯТЬ', // Twenty-five
  };

  // Genitive case for minutes (used in "Without X minutes")
  static const minutesGenitive = {
    5: 'ПЯТИ', // Five
    10: 'ДЕСЯТИ', // Ten
    15: 'ЧЕТВЕРТИ', // Quarter
    20: 'ДВАДЦАТИ', // Twenty
    25: 'ДВАДЦАТИ ПЯТИ', // Twenty-five
  };

  @override
  String convert(DateTime time) {
    int h = time.hour;
    int m = (time.minute ~/ 5) * 5;

    int displayHour = h % 12;
    int nextHour = (displayHour + 1) % 12;

    return switch (m) {
      0 => hours[displayHour], // Exact hour
      30 => 'ПОЛ ${hoursGenitive[nextHour]}', // Half of the next hour
      < 30 =>
        '${minutes[m]} ${hoursGenitive[nextHour]}', // X minutes of the next hour
      _ =>
        'БЕЗ ${minutesGenitive[60 - m]} ${hours[nextHour]}', // Without X minutes to the next hour
    };
  }
}
