import 'package:wordclock/logic/time_to_words.dart';

class PolishTimeToWords implements TimeToWords {
  const PolishTimeToWords();

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
