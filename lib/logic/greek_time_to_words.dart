import 'package:wordclock/logic/time_to_words.dart';

class GreekTimeToWords implements TimeToWords {
  @override
  String convert(DateTime time) {
    int m = time.minute;
    int h = time.hour;
    m = m - (m % 5);

    if (m >= 35) h++;

    final displayHour = h % 12;

    // Intro: 'H ΩPA EINAI' (Latin H, P, A, E, I, N)
    String words = 'H ΩPA EINAI';

    // Exact Hour
    words +=
        " ${switch (displayHour) {
          0 => 'ΔΩΔEKA',
          1 => 'MIA',
          2 => 'ΔYO',
          3 => 'TPEIΣ',
          4 => 'TEΣΣEPIΣ',
          5 => 'ΠENTE',
          6 => 'EΞI',
          7 => 'EΦTA',
          8 => 'OΧTΩ',
          9 => 'ENNIA',
          10 => 'ΔEKA',
          11 => 'ENTEKA',
          _ => '',
        }}";

    // Delta
    words += switch (m) {
      0 => '',
      5 => ' KAI ΠENTE',
      10 => ' KAI ΔEKA',
      15 => ' KAI TETAPTO',
      20 => ' KAI EIKOΣI',
      25 => ' KAI EIKOΣI ΠENTE',
      30 => ' KAI MIΣH',
      35 => ' ΠAPA EIKOΣI ΠENTE',
      40 => ' ΠAPA EIKOΣI',
      45 => ' ΠAPA TETAPTO',
      50 => ' ΠAPA ΔEKA',
      55 => ' ΠAPA ΠENTE',
      _ => '',
    };

    return words.replaceAll('  ', ' ').trim();
  }
}
