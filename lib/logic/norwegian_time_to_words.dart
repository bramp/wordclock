import 'package:wordclock/logic/time_to_words.dart';

/// Base implementation for Norwegian language.
abstract class _BaseNorwegianTimeToWords implements TimeToWords {
  final String ten;
  final String four;

  const _BaseNorwegianTimeToWords({required this.ten, required this.four});

  String getHour(int hour) => switch (hour) {
    0 => 'TOLV',
    1 => 'ETT',
    2 => 'TO',
    3 => 'TRE',
    4 => four,
    5 => 'FEM',
    6 => 'SEKS',
    7 => 'SYV',
    8 => 'ÅTTE',
    9 => 'NI',
    10 => ten,
    11 => 'ELLEVE',
    _ => '',
  };

  String getDelta(int minute) => switch (minute) {
    0 => '',
    5 => ' FEM OVER',
    10 => ' $ten OVER',
    15 => ' KVART OVER',
    20 => ' $ten PÅ HALV',
    25 => ' FEM PÅ HALV',
    30 => ' HALV',
    35 => ' FEM OVER HALV',
    40 => ' $ten OVER HALV',
    45 => ' KVART PÅ',
    50 => ' $ten PÅ',
    55 => ' FEM PÅ',
    _ => '',
  };

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
    final exact = getHour(displayHour);
    final delta = getDelta(m);

    return 'KLOKKEN ER$delta $exact'.replaceAll('  ', ' ').trim();
  }
}

/// Norwegian (NO) Reference implementation.
class ReferenceNorwegianTimeToWords extends _BaseNorwegianTimeToWords {
  const ReferenceNorwegianTimeToWords()
    : super(
        ten: 'Tl', // Note: Scriptable data used lowercase L
        four: 'FlRE',
      );
}

/// Norwegian implementation.
/// Fixes typos in the reference data.
class NorwegianTimeToWords extends _BaseNorwegianTimeToWords {
  const NorwegianTimeToWords() : super(ten: 'TI', four: 'FIRE');
}
