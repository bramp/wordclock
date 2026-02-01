import 'package:wordclock/logic/time_to_words.dart';

class NativeSpanishTimeToWords implements TimeToWords {
  const NativeSpanishTimeToWords();
  static const hours = [
    'DOCE', // Twelve
    'UNA', // One
    'DOS', // Two
    'TRES', // Three
    'CUATRO', // Four
    'CINCO', // Five
    'SEIS', // Six
    'SIETE', // Seven
    'OCHO', // Eight
    'NUEVE', // Nine
    'DIEZ', // Ten
    'ONCE', // Eleven
  ];

  static const minutes = {
    5: 'CINCO', // Five
    10: 'DIEZ', // Ten
    15: 'CUARTO', // Quarter
    20: 'VEINTE', // Twenty
    25: 'VEINTICINCO', // Twenty-five
    30: 'MEDIA', // Half
  };

  @override
  String convert(DateTime time) {
    int h = time.hour;
    int m = (time.minute ~/ 5) * 5; // Round down to nearest 5

    int displayHour = h % 12;
    int nextHour = (displayHour + 1) % 12;

    return switch (m) {
      0 when h == 12 => 'ES MEDIODÍA', // It is noon
      0 when h == 0 => 'ES MEDIANOCHE', // It is midnight
      0 =>
        '${displayHour == 1 ? 'ES LA' : 'SON LAS'} ${hours[displayHour]}', // It is X o'clock
      <= 30 =>
        '${displayHour == 1 ? 'ES LA' : 'SON LAS'} ${hours[displayHour]} Y ${minutes[m]}', // X and Y minutes
      _ =>
        '${nextHour == 1 ? 'ES LA' : 'SON LAS'} ${hours[nextHour]} MENOS ${minutes[60 - m]}', // Y minus X minutes
    };
  }
}

class ReferenceSpanishTimeToWords implements TimeToWords {
  const ReferenceSpanishTimeToWords();
  @override
  String convert(DateTime time) {
    int m = time.minute;
    int h = time.hour;

    // Round down to nearest 5 minutes
    m = m - (m % 5);

    // 1. Conditionals (None for ES)

    // 2. Hour display limit (35 minutes)
    if (m >= 35) {
      h++;
    }

    final displayHour = h % 12;

    String words = '';

    // 5. Delta
    // 6. Exact hour
    String exact = switch (displayHour) {
      0 => 'SON LAS DOCE', // They are the twelve
      1 => 'ES LA UNA', // It is the one
      2 => 'SON LAS DOS', // They are the two
      3 => 'SON LAS TRES', // They are the three
      4 => 'SON LAS CUATRO', // They are the four
      5 => 'SON LAS CINCO', // They are the five
      6 => 'SON LAS SEIS', // They are the six
      7 => 'SON LAS SIETE', // They are the seven
      8 => 'SON LAS OCHO', // They are the eight
      9 => 'SON LAS NUEVE', // They are the nine
      10 => 'SON LAS DIEZ', // They are the ten
      11 => 'SON LAS ONCE', // They are the eleven
      _ => '',
    };

    // 5. Delta
    String delta = switch (m) {
      5 => 'Y CINCO', // And five
      10 => 'Y DIEZ', // And ten
      15 => 'Y CUARTO', // And quarter
      20 => 'Y VEINTE', // And twenty
      25 => 'Y VEINTICINCO', // And twenty-five
      30 => 'Y MEDIA', // And half
      35 => 'MENOS VEINTICINCO', // Minus twenty-five
      40 => 'MENOS VEINTE', // Minus twenty
      45 => 'MENOS CUARTO', // Minus quarter
      50 => 'MENOS DIEZ', // Minus ten
      55 => 'MENOS CINCO', // Minus five
      _ => '',
    };

    // Order: Exact + Delta
    // e.g. SON LAS DOCE + Y CINCO
    words += " $exact";
    if (delta.isNotEmpty) words += " $delta";

    return words.replaceAll('  ', ' ').trim();
  }
}

/// Spanish implementation. Matches [ReferenceSpanishTimeToWords] as no changes were requested by the expert.
class SpanishTimeToWords extends ReferenceSpanishTimeToWords {
  const SpanishTimeToWords();
}
