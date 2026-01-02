import 'package:wordclock/logic/time_to_words.dart';

class NativeItalianTimeToWords implements TimeToWords {
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

class ItalianTimeToWords implements TimeToWords {
  @override
  String convert(DateTime time) {
    int m = time.minute;
    int h = time.hour;

    // Round down to nearest 5 minutes
    m = m - (m % 5);

    // 1. Conditionals (None for IT)

    // 2. Hour display limit (35 minutes)
    if (m >= 35) {
      h++;
    }

    final displayHour = h % 12;

    String words = '';

    // 5. Delta
    String delta = switch (m) {
      5 => 'E CINQUE', // And five
      10 => 'E DIECI', // And ten
      15 => 'E UN QUARTO', // And one quarter
      20 => 'E VENTI', // And twenty
      25 => 'E VENTICINQUE', // And twenty-five
      30 => 'E MEZZA', // And half
      35 => 'MENO VENTICINQUE', // Minus twenty-five
      40 => 'MENO VENTI', // Minus twenty
      45 => 'MENO UN QUARTO', // Minus one quarter
      50 => 'MENO DIECI', // Minus ten
      55 => 'MENO CINQUE', // Five before
      _ => '',
    };

    // 6. Exact hour
    String exact = switch (displayHour) {
      0 => 'SONO LE DODICI', // They are the twelve
      1 => 'È L’UNA', // It is the one
      2 => 'SONO LE DUE', // They are the two
      3 => 'SONO LE TRE', // They are the three
      4 => 'SONO LE QUATTRO', // They are the four
      5 => 'SONO LE CINQUE', // They are the five
      6 => 'SONO LE SEI', // They are the six
      7 => 'SONO LE SETTE', // They are the seven
      8 => 'SONO LE OTTO', // They are the eight
      9 => 'SONO LE NOVE', // They are the nine
      10 => 'SONO LE DIECI', // They are the ten
      11 => 'SONO LE UNDICI', // They are the eleven
      _ => '',
    };

    // Exact + Delta (e.g. SONO LE DUE E CINQUE)
    words = exact + (delta.isNotEmpty ? ' $delta' : '');

    return words.replaceAll('  ', ' ').trim();
  }
}
