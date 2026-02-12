import 'package:wordclock/logic/time_to_words.dart';

/// Base implementation for Turkish language.
abstract class _BaseTurkishTimeToWords implements TimeToWords {
  final String eight;
  final String eightSuffixed;

  const _BaseTurkishTimeToWords({
    required this.eight,
    required this.eightSuffixed,
  });

  String getHour(int hour, bool accusative) => switch (hour % 12) {
    0 => accusative ? 'ON İKİYİ' : 'ON İKİ',
    1 => accusative ? 'BİRİ' : 'BİR',
    2 => accusative ? 'İKİYİ' : 'İKİ',
    3 => accusative ? 'ÜÇÜ' : 'ÜÇ',
    4 => accusative ? 'DÖRDÜ' : 'DÖRT',
    5 => accusative ? 'BEŞİ' : 'BEŞ',
    6 => accusative ? 'ALTIYI' : 'ALTI',
    7 => accusative ? 'YEDİYİ' : 'YEDİ',
    8 => accusative ? eightSuffixed : eight,
    9 => accusative ? 'DOKUZU' : 'DOKUZ',
    10 => accusative ? 'ONU' : 'ON',
    11 => accusative ? 'ON BİRİ' : 'ON BİR',
    _ => '',
  };

  String getDelta(int minute) => switch (minute) {
    5 => 'BEŞ',
    10 => 'ON',
    15 => 'ÇEYREK',
    20 => 'YİRMİ',
    25 => 'YİRMİ BEŞ',
    35 => 'OTUZ BEŞ',
    40 => 'KIRK',
    45 => 'KIRK BEŞ',
    50 => 'ELLİ',
    55 => 'ELLİ BEŞ',
    _ => '',
  };

  @override
  String convert(DateTime time) {
    int m = time.minute;
    int h = time.hour;

    // Round down to nearest 5 minutes
    m = m - (m % 5);

    final displayHour = h % 12;

    if (m == 0) {
      return 'SAAT ${getHour(displayHour, false)}';
    }

    if (m == 30) {
      return 'SAAT ${getHour(displayHour, false)} BUÇUK';
    }

    final exact = getHour(displayHour, true);
    final delta = getDelta(m);

    return 'SAAT $exact $delta GEÇİYOR'.replaceAll('  ', ' ').trim();
  }
}

/// Turkish (TR) Reference implementation.
/// Contains legacy spelling (SEKIZ).
class ReferenceTurkishTimeToWords extends _BaseTurkishTimeToWords {
  const ReferenceTurkishTimeToWords()
    : super(eight: 'SEKIZ', eightSuffixed: 'SEKIZİ');
}

/// Turkish implementation.
/// Fixes spelling and uses formal grammar.
class TurkishTimeToWords extends _BaseTurkishTimeToWords {
  const TurkishTimeToWords() : super(eight: 'SEKİZ', eightSuffixed: 'SEKİZİ');
}
