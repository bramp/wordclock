import 'package:wordclock/logic/time_to_words.dart';

/// Base implementation for Danish language.
abstract class _BaseDanishTimeToWords implements TimeToWords {
  final bool includeMinutter;

  const _BaseDanishTimeToWords({required this.includeMinutter});

  String getHour(int hour) => switch (hour) {
    0 => 'TOLV',
    1 => 'ET',
    2 => 'TO',
    3 => 'TRE',
    4 => 'FIRE',
    5 => 'FEM',
    6 => 'SEKS',
    7 => 'SYV',
    8 => 'OTTE',
    9 => 'NI',
    10 => 'TI',
    11 => 'ELLEVE',
    _ => '',
  };

  String getDelta(int minute) {
    final m = includeMinutter ? ' MINUTTER' : '';
    return switch (minute) {
      0 => '',
      5 => ' FEM$m OVER',
      10 => ' TI$m OVER',
      15 => ' KVART OVER',
      20 => ' TYVE$m OVER',
      25 => ' FEM$m I HALV',
      30 => ' HALV',
      35 => ' FEM$m OVER HALV',
      40 => ' TYVE$m I',
      45 => ' KVART I',
      50 => ' TI$m I',
      55 => ' FEM$m I',
      _ => '',
    };
  }

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
    final exact = getHour(displayHour);
    final delta = getDelta(m);

    return 'KLOKKEN ER$delta $exact'.replaceAll('  ', ' ').trim();
  }
}

/// Danish (DK) Reference implementation.
class ReferenceDanishTimeToWords extends _BaseDanishTimeToWords {
  const ReferenceDanishTimeToWords() : super(includeMinutter: true);
}

/// Danish implementation.
/// Removes the redundant word "MINUTTER".
class DanishTimeToWords extends _BaseDanishTimeToWords {
  const DanishTimeToWords() : super(includeMinutter: false);
}
