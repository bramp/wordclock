import 'package:wordclock/logic/time_to_words.dart';

class NorwegianTimeToWords implements TimeToWords {
  @override
  String convert(DateTime time) {
    int m = time.minute;
    int h = time.hour;

    // Round down to nearest 5 minutes
    m = m - (m % 5);

    // hourDisplayLimit: 20
    if (m >= 20) {
      h++;
    }

    final displayHour = h % 12;

    String words = 'KLOKKEN ER'; // The clock is

    // 5. Delta (Intro + Delta + Exact)
    words += switch (m) {
      0 => '',
      5 => ' FEM OVER', // Five over
      10 => ' Tl OVER', // Ten over (Scriptable data uses lowercase L)
      15 => ' KVART OVER', // Quarter over
      20 => ' Tl PÅ HALV', // Ten before half
      25 => ' FEM PÅ HALV', // Five before half
      30 => ' HALV', // Half (to)
      35 => ' FEM OVER HALV', // Five after half
      40 => ' Tl OVER HALV', // Ten after half
      45 => ' KVART PÅ', // Quarter to
      50 => ' Tl PÅ', // Ten to
      55 => ' FEM PÅ', // Five to
      _ => '',
    };

    // 6. Exact hour
    words +=
        " ${switch (displayHour) {
          0 => 'TOLV', // 12
          1 => 'ETT', // 1
          2 => 'TO', // 2
          3 => 'TRE', // 3
          4 => 'FlRE', // 4 (Wait, is it FlRE?)
          5 => 'FEM', // 5
          6 => 'SEKS', // 6
          7 => 'SYV', // 7
          8 => 'ÅTTE', // 8
          9 => 'NI', // 9
          10 => 'Tl', // 10 (lowercase L)
          11 => 'ELLEVE', // 11
          _ => '',
        }}";

    return words.replaceAll('  ', ' ').trim();
  }
}
