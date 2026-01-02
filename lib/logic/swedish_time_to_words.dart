import 'package:wordclock/logic/time_to_words.dart';

class SwedishTimeToWords implements TimeToWords {
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

    String words = 'KLOCKAN ÄR'; // The clock is

    // 5. Delta (Intro + Delta + Exact)
    words += switch (m) {
      0 => '',
      5 => ' FEM ÖVER', // Five after
      10 => ' TIO ÖVER', // Ten after
      15 => ' KVART ÖVER', // Quarter after
      20 => ' TJUGO ÖVER', // Twenty after
      25 => ' FEM I HALV', // Five before half
      30 => ' HALV', // Half (to)
      35 => ' FEM ÖVER HALV', // Five after half
      40 => ' TJUGO I', // Twenty before
      45 => ' KVART I', // Quarter before
      50 => ' TIO I', // Ten before
      55 => ' FEM I', // Five before
      _ => '',
    };

    // 6. Exact hour
    words +=
        " ${switch (displayHour) {
          0 => 'TOLV', // 12
          1 => 'ETT', // 1
          2 => 'TVÅ', // 2
          3 => 'TRE', // 3
          4 => 'FYRA', // 4
          5 => 'FEM', // 5
          6 => 'SEX', // 6
          7 => 'SJU', // 7
          8 => 'ÄTTA', // 8 (Scriptable data uses ÄTTA)
          9 => 'NIO', // 9
          10 => 'TIO', // 10
          11 => 'ELVA', // 11
          _ => '',
        }}";

    return words.replaceAll('  ', ' ').trim();
  }
}
