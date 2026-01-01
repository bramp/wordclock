import 'package:wordclock/logic/time_to_words.dart';

class ItalianTimeToWords implements TimeToWords {
  static const hours = [
    'DODICI', // Twelve
    'L\'UNA', // One
    'DUE', // Two
    'TRE', // Three
    'QUATTRO', // Four
    'CINQUE', // Five
    'SEI', // Six
    'SETTE', // Seven
    'OTTO', // Eight
    'NOVE', // Nine
    'DIECI', // Ten
    'UNDICI', // Eleven
  ];

  static const minutes = {
    5: 'CINQUE', // Five
    10: 'DIECI', // Ten
    20: 'VENTI', // Twenty
    25: 'VENTICINQUE', // Twenty-five
  };

  @override
  String convert(DateTime time) {
    int h = time.hour;
    int m = (time.minute ~/ 5) * 5; // Round down to nearest 5

    int displayHour = h % 12;
    int nextHour = (displayHour + 1) % 12;

    // "È" = singular, "SONO LE" = plural
    String hPrefix(int hr) =>
        hr == 1 ? 'È' : 'SONO LE'; // "It is" / "They are the"
    String hName(int hr) => hours[hr];

    return switch (m) {
      0 when h == 12 => 'È MEZZOGIORNO', // It is noon
      0 when h == 0 => 'È MEZZANOTTE', // It is midnight
      0 => '${hPrefix(displayHour)} ${hName(displayHour)}',
      15 =>
        '${hPrefix(displayHour)} ${hName(displayHour)} E UN QUARTO', // And a quarter
      30 => '${hPrefix(displayHour)} ${hName(displayHour)} E MEZZA', // And half
      45 =>
        '${hPrefix(nextHour)} ${hName(nextHour)} MENO UN QUARTO', // Minus a quarter
      < 30 =>
        '${hPrefix(displayHour)} ${hName(displayHour)} E ${minutes[m]}', // "E" = and
      _ =>
        '${hPrefix(nextHour)} ${hName(nextHour)} MENO ${minutes[60 - m]}', // "MENO" = minus
    };
  }
}
