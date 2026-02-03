import 'package:wordclock/logic/time_to_words.dart';

/// Base implementation for Russian language.
abstract class _BaseRussianTimeToWords implements TimeToWords {
  final bool isReference;

  const _BaseRussianTimeToWords({required this.isReference});

  String getHour(int h) {
    if (isReference) {
      return switch (h % 12) {
        0 => 'ДВЕ НАДЦАТЬ ЧАСОВ',
        1 => 'ОДИН ЧАС',
        2 => 'ДВА ЧАСА',
        3 => 'ТРИ ЧАСА',
        4 => 'ЧЕ ТЫ РЕ ЧАСА',
        5 => 'ПЯТЬ ЧАСОВ',
        6 => 'ШЕСТЬ ЧАСОВ',
        7 => 'СЕМЬ ЧАСОВ',
        8 => 'ВО СЕМЬ ЧАСОВ',
        9 => 'ДЕ ВЯТЬ ЧАСОВ',
        10 => 'ДЕ СЯТЬ ЧАСОВ',
        11 => 'ОДИН НАДЦАТЬ ЧАСОВ',
        _ => '',
      };
    }
    return switch (h % 12) {
      0 => 'ДВЕНАДЦАТЬ ЧАСОВ',
      1 => 'ОДИН ЧАС',
      2 => 'ДВА ЧАСА',
      3 => 'ТРИ ЧАСА',
      4 => 'ЧЕТЫРЕ ЧАСА',
      5 => 'ПЯТЬ ЧАСОВ',
      6 => 'ШЕСТЬ ЧАСОВ',
      7 => 'СЕМЬ ЧАСОВ',
      8 => 'ВОСЕМЬ ЧАСОВ',
      9 => 'ДЕВЯТЬ ЧАСОВ',
      10 => 'ДЕСЯТЬ ЧАСОВ',
      11 => 'ОДИННАДЦАТЬ ЧАСОВ',
      _ => '',
    };
  }

  String getDelta(int m) {
    if (isReference) {
      return switch (m) {
        0 => '',
        5 => 'ПЯТЬ МИНУТ',
        10 => 'ДЕ СЯТЬ МИНУТ',
        15 => 'ПЯТНАД ЦАТЬ МИНУТ',
        20 => 'ДВАД ЦАТЬ МИНУТ',
        25 => 'ДВАД ЦАТЬ ПЯТЬ МИНУТ',
        30 => 'ТРИД ЦАТЬ МИНУТ',
        35 => 'ТРИД ЦАТЬ ПЯТЬ МИНУТ',
        40 => 'СОРОК МИНУТ',
        45 => 'СОРОК ПЯТЬ МИНУТ',
        50 => 'ПЯТЬ ДЕСЯТ МИНУТ',
        55 => 'ПЯТЬ ДЕСЯТ ПЯТЬ МИНУТ',
        _ => '',
      };
    }
    return switch (m) {
      0 => '',
      5 => 'ПЯТЬ МИНУТ',
      10 => 'ДЕСЯТЬ МИНУТ',
      15 => 'ПЯТНАДЦАТЬ МИНУТ',
      20 => 'ДВАДЦАТЬ МИНУТ',
      25 => 'ДВАДЦАТЬ ПЯТЬ МИНУТ',
      30 => 'ТРИДЦАТЬ МИНУТ',
      35 => 'ТРИДЦАТЬ ПЯТЬ МИНУТ',
      40 => 'СОРОК МИНУТ',
      45 => 'СОРОК ПЯТЬ МИНУТ',
      50 => 'ПЯТЬДЕСЯТ МИНУТ',
      55 => 'ПЯТЬДЕСЯТ ПЯТЬ МИНУТ',
      _ => '',
    };
  }

  @override
  String convert(DateTime time) {
    int m = (time.minute ~/ 5) * 5;
    int h = time.hour;

    final hourPhrase = getHour(h);
    final deltaPhrase = getDelta(m);

    return '$hourPhrase $deltaPhrase'.trim().replaceAll('  ', ' ');
  }
}

/// Russian (RU) Reference implementation.
/// Contains split numerals (e.g. "ДЕ СЯТЬ").
class ReferenceRussianTimeToWords extends _BaseRussianTimeToWords {
  const ReferenceRussianTimeToWords() : super(isReference: true);
}

/// Russian implementation.
/// Fixes split numerals.
class RussianTimeToWords extends _BaseRussianTimeToWords {
  const RussianTimeToWords() : super(isReference: false);
}
