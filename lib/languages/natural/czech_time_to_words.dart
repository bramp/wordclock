import 'package:wordclock/logic/time_to_words.dart';

/// Base implementation for Czech language.
abstract class _BaseCzechTimeToWords implements TimeToWords {
  final bool useJsou;
  final String fiveMinutePhrase;

  const _BaseCzechTimeToWords({
    required this.useJsou,
    required this.fiveMinutePhrase,
  });

  String getHour(int hour) => switch (hour % 12) {
    0 => 'DVANÁCT',
    1 => 'JEDNA',
    2 => 'DVĚ',
    3 => 'TŘI',
    4 => 'ČTYŘI',
    5 => 'PĚT',
    6 => 'ŠEST',
    7 => 'SEDM',
    8 => 'OSM',
    9 => 'DEVĚT',
    10 => 'DESET',
    11 => 'JEDENÁCT',
    _ => '',
  };

  String getIntro(int hour) {
    if (!useJsou) return 'JE';
    return switch (hour % 12) {
      2 || 3 || 4 => 'JSOU',
      _ => 'JE',
    };
  }

  String getDelta(int minute) => switch (minute) {
    0 => '',
    5 => fiveMinutePhrase,
    10 => 'DESET',
    15 => 'PATNÁCT',
    20 => 'DVACET',
    25 => 'DVACET PĚT',
    30 => 'TŘICET',
    35 => 'TŘICET PĚT',
    40 => 'ČTYŘICET',
    45 => 'ČTYŘICET PĚT',
    50 => 'PADESÁT',
    55 => 'PADESÁT PĚT',
    _ => '',
  };

  @override
  String convert(DateTime time) {
    int m = (time.minute ~/ 5) * 5;
    int h = time.hour;

    final intro = getIntro(h);
    final exact = getHour(h);
    final delta = getDelta(m);

    return '$intro $exact $delta'.replaceAll('  ', ' ').trim();
  }
}

/// Czech (CZ) Reference implementation.
class ReferenceCzechTimeToWords extends _BaseCzechTimeToWords {
  const ReferenceCzechTimeToWords()
    : super(useJsou: true, fiveMinutePhrase: 'NULA PĚT');
}

/// Czech implementation.
class CzechTimeToWords extends _BaseCzechTimeToWords {
  const CzechTimeToWords() : super(useJsou: false, fiveMinutePhrase: 'PĚT');
}
