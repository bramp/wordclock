import 'package:wordclock/logic/time_to_words.dart';

/// Base implementation for Polish language.
abstract class _BasePolishTimeToWords implements TimeToWords {
  final bool isReference;

  const _BasePolishTimeToWords({required this.isReference});

  String getHour(int hour) {
    if (isReference) {
      final stem = switch (hour % 12) {
        0 => 'DWUN AST',
        1 => 'PIERWSZ',
        2 => 'DRUG',
        3 => 'TRZEC I',
        4 => 'CZWART',
        5 => 'PI ĄT',
        6 => 'SZÓST',
        7 => 'SIÓDM',
        8 => 'ÓSM',
        9 => 'DZIEWI ĄT',
        10 => 'DZIESI ĄT',
        11 => 'JEDEN AST',
        _ => '',
      };
      return '$stem A';
    }
    return switch (hour % 12) {
      0 => 'DWUNASTA',
      1 => 'PIERWSZA',
      2 => 'DRUGA',
      3 => 'TRZECIA',
      4 => 'CZWARTA',
      5 => 'PIĄTA',
      6 => 'SZÓSTA',
      7 => 'SIÓDMA',
      8 => 'ÓSMA',
      9 => 'DZIEWIĄTA',
      10 => 'DZIESIĄTA',
      11 => 'JEDENASTA',
      _ => '',
    };
  }

  String getDelta(int minute) {
    if (isReference) {
      return switch (minute) {
        0 => '',
        5 => 'PIĘĆ',
        10 => 'DZIESI ĘĆ',
        15 => 'PIĘT NAŚ CI E',
        20 => 'DWADZIEŚCI A',
        25 => 'DWADZIEŚCI A PIĘĆ',
        30 => 'TRZY DZIEŚCI',
        35 => 'TRZY DZIEŚCI PIĘĆ',
        40 => 'CZTER DZIEŚCI',
        45 => 'CZTER DZIEŚCI PIĘĆ',
        50 => 'PIĘĆ DZIESI ĄT',
        55 => 'PIĘĆ DZIESI ĄT PIĘĆ',
        _ => '',
      };
    }
    return switch (minute) {
      0 => '',
      5 => 'PIĘĆ',
      10 => 'DZIESIĘĆ',
      15 => 'PIĘTNAŚCIE', // Fixed Cyrillic T
      20 => 'DWADZIEŚCIA',
      25 => 'DWADZIEŚCIA PIĘĆ',
      30 => 'TRZYDZIEŚCIE',
      35 => 'TRZYDZIEŚCIE PIĘĆ',
      40 => 'CZTERDZIEŚCIE',
      45 => 'CZTERDZIEŚCIE PIĘĆ',
      50 => 'PIĘĆDZIESIĄT',
      55 => 'PIĘĆDZIESIĄT PIĘĆ',
      _ => '',
    };
  }

  @override
  String convert(DateTime time) {
    int h = time.hour;
    int m = (time.minute ~/ 5) * 5;

    final hourPhrase = getHour(h);
    final deltaPhrase = getDelta(m);

    return '$hourPhrase $deltaPhrase'.trim().replaceAll('  ', ' ');
  }
}

/// Polish (PL) Reference implementation.
/// Contains split numerals (e.g. "DZIESI ĄT").
class ReferencePolishTimeToWords extends _BasePolishTimeToWords {
  const ReferencePolishTimeToWords() : super(isReference: true);
}

/// Polish implementation.
/// Fixes split numerals.
class PolishTimeToWords extends _BasePolishTimeToWords {
  const PolishTimeToWords() : super(isReference: false);
}
