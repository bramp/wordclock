import 'package:wordclock/logic/time_to_words.dart';

class PolishTimeToWords implements TimeToWords {
  const PolishTimeToWords();

  // Nominative case for hours (used for exact hours and "ZA" - before)
  static const hoursNominative = [
    'DWUNASTA', // Twelfth
    'PIERWSZA', // First
    'DRUGA', // Second
    'TRZECIA', // Third
    'CZWARTA', // Fourth
    'PIĄTA', // Fifth
    'SZÓSTA', // Sixth
    'SIÓDMA', // Seventh
    'ÓSMA', // Eighth
    'DZIEWIĄTA', // Ninth
    'DZIESIĄTA', // Tenth
    'JEDENASTA', // Eleventh
  ];

  // Genitive case for hours (used for "PO" - after and "WPÓŁ DO" - half to)
  static const hoursGenitive = [
    'DWUNASTEJ', // Twelfth
    'PIERWSZEJ', // First
    'DRUGIEJ', // Second
    'TRZECIEJ', // Third
    'CZWARTEJ', // Fourth
    'PIĄTEJ', // Fifth
    'SZÓSTEJ', // Sixth
    'SIÓDMEJ', // Seventh
    'ÓSMEJ', // Eighth
    'DZIEWIĄTEJ', // Ninth
    'DZIESIĄTEJ', // Tenth
    'JEDENASTEJ', // Eleventh
  ];

  static const minutes = {
    5: 'PIĘĆ', // Five
    10: 'DZIESIĘĆ', // Ten
    15: 'KWADRANS', // Quarter
    20: 'DWADZIEŚCIA', // Twenty
    25: 'DWADZIEŚCIA PIĘĆ', // Twenty-five
  };

  @override
  String convert(DateTime time) {
    int h = time.hour;
    int m = (time.minute ~/ 5) * 5;

    int displayHour = h % 12;
    int nextHour = (displayHour + 1) % 12;

    return switch (m) {
      0 => 'JEST ${hoursNominative[displayHour]}', // It is X
      15 => 'JEST KWADRANS PO ${hoursGenitive[displayHour]}', // Quarter after X
      30 => 'JEST WPÓŁ DO ${hoursGenitive[nextHour]}', // Half to X
      45 => 'JEST ZA KWADRANS ${hoursNominative[nextHour]}', // Quarter before X
      < 30 =>
        'JEST ${minutes[m]} PO ${hoursGenitive[displayHour]}', // X after Y
      _ =>
        'JEST ZA ${minutes[60 - m]} ${hoursNominative[nextHour]}', // X before Y
    };
  }
}
