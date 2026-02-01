import 'package:wordclock/logic/time_to_words.dart';

class ReferenceRomanianTimeToWords implements TimeToWords {
  const ReferenceRomanianTimeToWords();
  @override
  String convert(DateTime time) {
    int m = time.minute;
    int h = time.hour;

    // Round down to nearest 5 minutes
    m = m - (m % 5);

    // hourDisplayLimit: 40
    if (m >= 40) {
      h++;
    }

    final displayHour = h % 12;

    String words = 'ESTE ORA'; // It is the hour

    // 6. Exact hour
    words +=
        " ${switch (displayHour) {
          0 => 'DOUĂ SPRE ZECE', // 12
          1 => 'UNU', // 1
          2 => 'DOUĂ', // 2
          3 => 'TREI', // 3
          4 => 'PATRU', // 4
          5 => 'CINCI', // 5
          6 => 'ŞASE', // 6
          7 => 'ŞAPTE', // 7
          8 => 'OPT', // 8
          9 => 'NOUĂ', // 9
          10 => 'ZECE', // 10
          11 => 'UNSPREZECE', // 11
          _ => '',
        }}";

    // 5. Delta
    words += switch (m) {
      0 => '',
      5 => ' ŞI CINCI', // And five
      10 => ' ŞI ZECE', // And ten
      15 => ' ŞI UN SFERT', // And a quarter
      20 => ' ŞI DOUĂZECI', // And twenty
      25 => ' ŞI DOUĂZECI ŞI CINCI', // And twenty and five
      30 => ' ŞI TREIZECI', // And thirty
      35 => ' ŞI TREIZECI ŞI CINCI', // And thirty and five
      40 => ' FĂRĂ DOUĂZECI', // Without twenty
      45 => ' FĂRĂ UN SFERT', // Without a quarter
      50 => ' FĂRĂ ZECE', // Without ten
      55 => ' FĂRĂ CINCI', // Without five
      _ => '',
    };

    return words.replaceAll('  ', ' ').trim();
  }
}

/// Romanian implementation that differs from [ReferenceRomanianTimeToWords] by:
/// - Fixing the split word "DOUĂ SPRE ZECE" to "DOUĂSPREZECE" (12).
/// - Using "ŞI JUMĂTATE" instead of "ŞI TREIZECI" for naturalness.
class RomanianTimeToWords extends ReferenceRomanianTimeToWords {
  const RomanianTimeToWords();

  @override
  String convert(DateTime time) {
    int m = time.minute;
    int h = time.hour;
    m = m - (m % 5);

    if (m >= 40) h++;

    final displayHour = h % 12;

    String words = 'ESTE ORA';

    words +=
        " ${switch (displayHour) {
          0 => 'DOUĂSPREZECE',
          1 => 'UNU',
          2 => 'DOUĂ',
          3 => 'TREI',
          4 => 'PATRU',
          5 => 'CINCI',
          6 => 'ŞASE',
          7 => 'ŞAPTE',
          8 => 'OPT',
          9 => 'NOUĂ',
          10 => 'ZECE',
          11 => 'UNSPREZECE',
          _ => '',
        }}";

    words += switch (m) {
      0 => '',
      5 => ' ŞI CINCI',
      10 => ' ŞI ZECE',
      15 => ' ŞI UN SFERT',
      20 => ' ŞI DOUĂZECI',
      25 => ' ŞI DOUĂZECI ŞI CINCI',
      30 => ' ŞI JUMĂTATE',
      35 =>
        ' ŞI TREIZECI ŞI CINCI', // Expert didn't mention this, but I'll keep it consistent or use "FĂRĂ"? 35 is usually "şi treizeci şi cinci" or "fără douăzeci şi cinci"? Reference said "ŞI TREIZECI ŞI CINCI".
      40 => ' FĂRĂ DOUĂZECI',
      45 => ' FĂRĂ UN SFERT',
      50 => ' FĂRĂ ZECE',
      55 => ' FĂRĂ CINCI',
      _ => '',
    };

    return words.replaceAll('  ', ' ').trim();
  }
}
