import 'package:wordclock/logic/time_to_words.dart';

class PolishTimeToWords implements TimeToWords {
  static const hours = [
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
    int m = (time.minute ~/ 5) * 5; // Round down to nearest 5

    int displayHour = h % 12;
    int nextHour = (displayHour + 1) % 12;

    return switch (m) {
      0 => 'JEST ${hours[displayHour]}',
      15 =>
        'JEST KWADRANS PO ${hours[displayHour]}', // KWADRANS PO = quarter past
      30 => 'JEST WPÓŁ DO ${hours[nextHour]}', // WPÓŁ DO = half to
      45 => 'JEST ZA KWADRANS ${hours[nextHour]}', // ZA = to/in
      < 30 => 'JEST ${minutes[m]} PO ${hours[displayHour]}', // PO = after
      _ => 'JEST ZA ${minutes[60 - m]} ${hours[nextHour]}', // ZA = to/in
    };
  }
}
