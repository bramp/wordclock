import 'package:wordclock/logic/time_to_words.dart';

/// Base implementation for Spanish language.
abstract class _BaseSpanishTimeToWords implements TimeToWords {
  const _BaseSpanishTimeToWords();

  String getHour(int hour) => switch (hour) {
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

  String getDelta(int minute) => switch (minute) {
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

  @override
  String convert(DateTime time) {
    int m = time.minute;
    int h = time.hour;

    // Round down to nearest 5 minutes
    m = m - (m % 5);

    // Rollover hour if minutes >= 35 (past half hour)
    if (m >= 35) {
      h++;
    }

    final displayHour = h % 12;

    final exact = getHour(displayHour);
    final delta = getDelta(m);

    String words = exact;
    if (delta.isNotEmpty) {
      words += ' $delta';
    }

    return words.replaceAll('  ', ' ').trim();
  }
}

/// Standard Spanish (ES) Reference implementation.
class ReferenceSpanishTimeToWords extends _BaseSpanishTimeToWords {
  const ReferenceSpanishTimeToWords();
}

/// Spanish implementation.
/// Matches [ReferenceSpanishTimeToWords] as no changes were requested by the expert.
class SpanishTimeToWords extends ReferenceSpanishTimeToWords {
  const SpanishTimeToWords();
}
