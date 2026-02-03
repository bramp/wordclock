import 'package:wordclock/logic/time_to_words.dart';

/// Base implementation for Dutch language.
abstract class _BaseDutchTimeToWords implements TimeToWords {
  const _BaseDutchTimeToWords();

  String getHour(int hour) => switch (hour) {
    0 => 'TWAALF', // 12
    1 => 'ÉÉN', // 1
    2 => 'TWEE', // 2
    3 => 'DRIE', // 3
    4 => 'VIER', // 4
    5 => 'VIJF', // 5
    6 => 'ZES', // 6
    7 => 'ZEVEN', // 7
    8 => 'ACHT', // 8
    9 => 'NEGEN', // 9
    10 => 'TIEN', // 10
    11 => 'ELF', // 11
    _ => '',
  };

  String getDelta(int minute) => switch (minute) {
    0 => ' UUR', // O'clock
    5 => ' VIJF OVER', // Five past
    10 => ' TIEN OVER', // Ten past
    15 => ' KWART OVER', // Quarter past
    20 => ' TIEN VOOR HALF', // Ten before half
    25 => ' VIJF VOOR HALF', // Five before half
    30 => ' HALF', // Half (to)
    35 => ' VIJF OVER HALF', // Five past half
    40 => ' TIEN OVER HALF', // Ten past half
    45 => ' KWART VOOR', // Quarter before
    50 => ' TIEN VOOR', // Ten before
    55 => ' VIJF VOOR', // Five before
    _ => '',
  };

  @override
  String convert(DateTime time) {
    int m = time.minute;
    int h = time.hour;

    // Round down to nearest 5 minutes
    m = m - (m % 5);

    // Rollover hour if minutes >= 20
    if (m >= 20) {
      h++;
    }

    final displayHour = h % 12;

    final exact = getHour(displayHour);
    final delta = getDelta(m);

    String words = 'HET IS';
    if (m == 0) {
      // Intro -> Exact -> Delta (UUR)
      words += ' $exact$delta';
    } else {
      // Intro -> Delta -> Exact
      words += '$delta $exact';
    }

    return words.replaceAll('  ', ' ').trim();
  }
}

/// Standard Dutch (NL) Reference implementation.
class ReferenceDutchTimeToWords extends _BaseDutchTimeToWords {
  const ReferenceDutchTimeToWords();
}

/// Dutch implementation.
/// Matches [ReferenceDutchTimeToWords].
class DutchTimeToWords extends ReferenceDutchTimeToWords {
  const DutchTimeToWords();
}
