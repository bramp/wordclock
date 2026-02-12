import 'package:wordclock/logic/time_to_words.dart';

/// Base implementation for Swedish language.
abstract class _BaseSwedishTimeToWords implements TimeToWords {
  final String eight;

  const _BaseSwedishTimeToWords({required this.eight});

  String getHour(int hour) => switch (hour) {
    0 => 'TOLV',
    1 => 'ETT',
    2 => 'TVÅ',
    3 => 'TRE',
    4 => 'FYRA',
    5 => 'FEM',
    6 => 'SEX',
    7 => 'SJU',
    8 => eight,
    9 => 'NIO',
    10 => 'TIO',
    11 => 'ELVA',
    _ => '',
  };

  String getDelta(int minute) => switch (minute) {
    0 => '',
    5 => ' FEM ÖVER',
    10 => ' TIO ÖVER',
    15 => ' KVART ÖVER',
    20 => ' TJUGO ÖVER',
    25 => ' FEM I HALV',
    30 => ' HALV',
    35 => ' FEM ÖVER HALV',
    40 => ' TJUGO I',
    45 => ' KVART I',
    50 => ' TIO I',
    55 => ' FEM I',
    _ => '',
  };

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

    return 'KLOCKAN ÄR$delta $exact'.replaceAll('  ', ' ').trim();
  }
}

/// Swedish (SE) Reference implementation.
class ReferenceSwedishTimeToWords extends _BaseSwedishTimeToWords {
  const ReferenceSwedishTimeToWords() : super(eight: 'ÄTTA');
}

/// Swedish implementation.
/// Fixes the spelling of 8 (ÅTTA).
class SwedishTimeToWords extends _BaseSwedishTimeToWords {
  const SwedishTimeToWords() : super(eight: 'ÅTTA');
}
