import 'package:wordclock/logic/time_to_words.dart';

/// Base implementation for Romanian language.
abstract class _BaseRomanianTimeToWords implements TimeToWords {
  final bool splitTwelve;
  final bool useJumatate;

  const _BaseRomanianTimeToWords({
    required this.splitTwelve,
    required this.useJumatate,
  });

  String getHour(int hour) => switch (hour % 12) {
    0 => splitTwelve ? 'DOUĂ SPRE ZECE' : 'DOUĂSPREZECE',
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
  };

  String getDelta(int minute) => switch (minute) {
    0 => '',
    5 => ' ŞI CINCI',
    10 => ' ŞI ZECE',
    15 => ' ŞI UN SFERT',
    20 => ' ŞI DOUĂZECI',
    25 => ' ŞI DOUĂZECI ŞI CINCI',
    30 => useJumatate ? ' ŞI JUMĂTATE' : ' ŞI TREIZECI',
    35 => ' ŞI TREIZECI ŞI CINCI',
    40 => ' FĂRĂ DOUĂZECI',
    45 => ' FĂRĂ UN SFERT',
    50 => ' FĂRĂ ZECE',
    55 => ' FĂRĂ CINCI',
    _ => '',
  };

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
    final exact = getHour(displayHour);
    final delta = getDelta(m);

    return 'ESTE ORA $exact$delta'.replaceAll('  ', ' ').trim();
  }
}

/// Romanian (RO) Reference implementation.
class ReferenceRomanianTimeToWords extends _BaseRomanianTimeToWords {
  const ReferenceRomanianTimeToWords()
    : super(splitTwelve: true, useJumatate: false);
}

/// Romanian implementation.
/// Fixes the split word for 12 and uses "JUMĂTATE" for 30 minutes.
class RomanianTimeToWords extends _BaseRomanianTimeToWords {
  const RomanianTimeToWords() : super(splitTwelve: false, useJumatate: true);
}
