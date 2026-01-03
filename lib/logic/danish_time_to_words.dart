import 'package:wordclock/logic/time_to_words.dart';

class DanishTimeToWords implements TimeToWords {
  const DanishTimeToWords();
  @override
  String convert(DateTime time) {
    int m = time.minute;
    int h = time.hour;

    // Round down to nearest 5 minutes
    m = m - (m % 5);

    // hourDisplayLimit: 25
    if (m >= 25) {
      h++;
    }

    final displayHour = h % 12;

    String words = 'KLOKKEN ER'; // The clock is

    // 5. Delta
    words += switch (m) {
      0 => '',
      5 => ' FEM MINUTTER OVER', // Five minutes over
      10 => ' TI MINUTTER OVER', // Ten minutes over
      15 => ' KVART OVER', // Quarter over
      20 => ' TYVE MINUTTER OVER', // Twenty minutes over
      25 => ' FEM MINUTTER I HALV', // Five minutes before half
      30 => ' HALV', // Half (to)
      35 => ' FEM MINUTTER OVER HALV', // Five minutes after half
      40 => ' TYVE MINUTTER I', // Twenty minutes before
      45 => ' KVART I', // Quarter before
      50 => ' TI MINUTTER I', // Ten minutes before
      55 => ' FEM MINUTTER I', // Five minutes before
      _ => '',
    };

    // 6. Exact hour
    words +=
        " ${switch (displayHour) {
          0 => 'TOLV', // 12
          1 => 'ET', // 1
          2 => 'TO', // 2
          3 => 'TRE', // 3
          4 => 'FIRE', // 4
          5 => 'FEM', // 5
          6 => 'SEKS', // 6
          7 => 'SYV', // 7
          8 => 'OTTE', // 8
          9 => 'NI', // 9
          10 => 'TI', // 10
          11 => 'ELLEVE', // 11
          _ => '',
        }}";

    return words.replaceAll('  ', ' ').trim();
  }
}
