import 'package:wordclock/logic/time_to_words.dart';

class NativeRussianTimeToWords implements TimeToWords {
  const NativeRussianTimeToWords();
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

class ReferenceRussianTimeToWords implements TimeToWords {
  const ReferenceRussianTimeToWords();
  @override
  String convert(DateTime time) {
    int m = time.minute;
    int h = time.hour;

    // Round down to nearest 5 minutes
    m = m - (m % 5);

    // 1. Conditionals (None for RU)

    // 2. Hour display limit (80 minutes - effectively never)
    if (m >= 80) {
      h++;
    }

    final displayHour = h % 12;

    String words = '';

    // 5. Delta
    String delta = switch (m) {
      5 => 'ПЯТЬ МИНУТ', // Five minutes
      10 => 'ДЕ СЯТЬ МИНУТ', // Ten minutes (split)
      15 => 'ПЯТНАД ЦАТЬ МИНУТ', // Fifteen minutes (split)
      20 => 'ДВАД ЦАТЬ МИНУТ', // Twenty minutes (split)
      25 => 'ДВАД ЦАТЬ ПЯТЬ МИНУТ', // Twenty-five minutes (split)
      30 => 'ТРИД ЦАТЬ МИНУТ', // Thirty minutes (split)
      35 => 'ТРИД ЦАТЬ ПЯТЬ МИНУТ', // Thirty-five minutes (split)
      40 => 'СОРОК МИНУТ', // Forty minutes
      45 => 'СОРОК ПЯТЬ МИНУТ', // Forty-five minutes
      50 => 'ПЯТЬ ДЕСЯТ МИНУТ', // Fifty minutes (split)
      55 => 'ПЯТЬ ДЕСЯТ ПЯТЬ МИНУТ', // Fifty-five minutes (split)
      _ => '',
    };

    // 6. Exact hour
    String exact = switch (displayHour) {
      0 => 'ДВЕ НАДЦАТЬ ЧАСОВ', // 12 o'clock (split)
      1 => 'ОДИН ЧАС', // 1 o'clock
      2 => 'ДВА ЧАСА', // 2 o'clock
      3 => 'ТРИ ЧАСА', // 3 o'clock
      4 => 'ЧЕ ТЫ РЕ ЧАСА', // 4 o'clock (split)
      5 => 'ПЯТЬ ЧАСОВ', // 5 o'clock
      6 => 'ШЕСТЬ ЧАСОВ', // 6 o'clock
      7 => 'СЕМЬ ЧАСОВ', // 7 o'clock
      8 => 'ВО СЕМЬ ЧАСОВ', // 8 o'clock (split)
      9 => 'ДЕ ВЯТЬ ЧАСОВ', // 9 o'clock (split)
      10 => 'ДЕ СЯТЬ ЧАСОВ', // 10 o'clock (split)
      11 => 'ОДИН НАДЦАТЬ ЧАСОВ', // 11 o'clock (split)
      _ => '',
    };

    words += " $exact $delta";

    return words.replaceAll('  ', ' ').trim();
  }
}
