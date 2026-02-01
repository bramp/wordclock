import 'package:wordclock/logic/time_to_words.dart';

class ReferencePolishTimeToWords implements TimeToWords {
  const ReferencePolishTimeToWords();

  @override
  String convert(DateTime time) {
    int h = time.hour;
    int m = (time.minute ~/ 5) * 5;
    int displayHour = h % 12;

    /// Stems for ordinal hour names (e.g., "First", "Second").
    /// These are the feminine forms as Polish hours are feminine (godzina).
    String stem(int hour) {
      return switch (hour % 12) {
        0 => 'DWUN AST', // Twelfth
        1 => 'PIERWSZ', // First
        2 => 'DRUG', // Second
        3 => 'TRZEC I', // Third
        4 => 'CZWART', // Fourth
        5 => 'PI ĄT', // Fifth
        6 => 'SZÓST', // Sixth
        7 => 'SIÓDM', // Seventh
        8 => 'ÓSM', // Eighth
        9 => 'DZIEWI ĄT', // Ninth
        10 => 'DZIESI ĄT', // Tenth
        11 => 'JEDEN AST', // Eleventh
        _ => '',
      };
    }

    /// Suffix "A" makes the hour ordinal (e.g., PIERWSZ + A = PIERWSZA).
    String hStr = '${stem(displayHour)} A';

    if (m == 0) return hStr;

    /// Minute names using cardinal or ordinal forms depending on common usage/reuse.
    /// Tokens are split to maximize sharing of common blocks like "DZIEŚCI" or "A".
    String mStr = switch (m) {
      5 => 'PIĘĆ', // Five
      10 => 'DZIESI ĘĆ', // Ten
      15 => 'PIĘT NAŚ CI E', // Fifteen
      20 => 'DWADZIEŚCI A', // Twenty
      25 => 'DWADZIEŚCI A PIĘĆ', // Twenty-five
      30 => 'TRZY DZIEŚCI', // Thirty
      35 => 'TRZY DZIEŚCI PIĘĆ', // Thirty-five
      40 => 'CZTER DZIEŚCI', // Forty
      45 => 'CZTER DZIEŚCI PIĘĆ', // Forty-five
      50 => 'PIĘĆ DZIESI ĄT', // Fifty
      55 => 'PIĘĆ DZIESI ĄT PIĘĆ', // Fifty-five
      _ => '',
    };

    return '$hStr $mStr';
  }
}

/// Polish implementation that differs from [ReferencePolishTimeToWords] by:
/// - Fixing orthography (removing internal spaces and correcting diacritics).
/// - Using the "terse" format (HOUR + MINUTE) with grammatically correct Polish words.
class PolishTimeToWords extends ReferencePolishTimeToWords {
  const PolishTimeToWords();

  @override
  String convert(DateTime time) {
    int h = time.hour;
    int m = (time.minute ~/ 5) * 5;
    int displayHour = h % 12;

    String hStr = switch (displayHour) {
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

    if (m == 0) return hStr;

    String mStr = switch (m) {
      5 => 'PIĘĆ',
      10 => 'DZIESIĘĆ',
      15 => 'PIĘTNAŚCIE',
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

    return '$hStr $mStr';
  }
}
