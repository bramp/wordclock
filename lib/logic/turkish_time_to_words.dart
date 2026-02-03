import 'package:wordclock/logic/time_to_words.dart';

class ReferenceTurkishTimeToWords implements TimeToWords {
  const ReferenceTurkishTimeToWords();
  @override
  String convert(DateTime time) {
    int m = time.minute;
    int h = time.hour;

    // Round down to nearest 5 minutes
    m = m - (m % 5);

    // 1. Conditionals (Absolute overrides in Scriptable engine)
    // Note: Conditionals skip the Intro ("SAAT") prefix.
    // Scriptable engine uses raw h (0-23) for conditional lookup.
    String? conditional = switch (m) {
      0 || 30 => switch (h % 12) {
        0 => m == 0 ? 'ON İKİ' : 'ON İKİ BUÇUK', // 0:00 / 0:30 midnight / noon
        1 => m == 0 ? 'BİR' : 'BİR BUÇUK', // 1:00 / 1:30
        2 => m == 0 ? 'İKİ' : 'İKİ BUÇUK', // 2:00 / 2:30
        3 => m == 0 ? 'ÜÇ' : 'ÜÇ BUÇUK', // 3:00 / 3:30 (Wait, check exact form)
        4 => m == 0 ? 'DÖRT' : 'DÖRT BUÇUK', // 4:00 / 4:30
        5 => m == 0 ? 'BEŞ' : 'BEŞ BUÇUK', // 5:00 / 5:30
        6 => m == 0 ? 'ALTI' : 'ALTI BUÇUK', // 6:00 / 6:30
        7 => m == 0 ? 'YEDİ' : 'YEDİ BUÇUK', // 7:00 / 7:30
        8 => m == 0 ? 'SEKIZ' : 'SEKIZ BUÇUK', // 8:00 / 8:30
        9 => m == 0 ? 'DOKUZ' : 'DOKUZ BUÇUK', // 9:00 / 9:30
        10 => m == 0 ? 'ON' : 'ON BUÇUK', // 10:00 / 10:30
        11 => m == 0 ? 'ON BİR' : 'ON BİR BUÇUK', // 11:00 / 11:30
        _ => null,
      },
      _ => null,
    };
    if (conditional != null) return 'SAAT $conditional';

    // 2. Normal logic (Intro + Delta + Exact)
    // hourDisplayLimit: 65
    if (m >= 65) {
      h++;
    }

    final displayHour = h % 12;

    String words = 'SAAT'; // Hour (Intro)

    // 5. Delta (Matches 'd' in scriptable data)
    String delta = switch (m) {
      5 => 'BEŞ GEÇİYOR', // Five passing
      10 => 'ON GEÇİYOR', // Ten passing
      15 => 'ÇEYREK GEÇİYOR', // Quarter passing
      20 => 'YİRMİ GEÇİYOR', // Twenty passing
      25 => 'YİRMİ BEŞ GEÇİYOR', // Twenty-five passing
      30 => 'BUÇUK', // Half past
      35 => 'OTUZ BEŞ GEÇİYOR', // Thirty-five passing
      40 => 'KIRK GEÇİYOR', // Forty passing
      45 => 'KIRK BEŞ GEÇİYOR', // Forty-five passing
      50 => 'ELLİ GEÇİYOR', // Fifty passing
      55 => 'ELLİ BEŞ GEÇİYOR', // Fifty-five passing
      _ => '',
    };
    // 6. Exact hour (Matches 'e' in scriptable data and includes suffix 'd')
    String exact = switch (displayHour) {
      0 => 'ON İKİYİ', // 12 (suffixed)
      1 => 'BİRİ', // 1 (suffixed)
      2 => 'İKİYİ', // 2 (suffixed)
      3 => 'ÜÇÜ', // 3 (suffixed)
      4 => 'DÖRDÜ', // 4 (suffixed)
      5 => 'BEŞİ', // 5 (suffixed)
      6 => 'ALTIYI', // 6 (suffixed)
      7 => 'YEDİYİ', // 7 (suffixed)
      8 => 'SEKIZİ', // 8 (suffixed)
      9 => 'DOKUZU', // 9 (suffixed)
      10 => 'ONU', // 10 (suffixed)
      11 => 'ON BİRİ', // 11 (suffixed)
      _ => '',
    };

    // Append Exact then Delta
    words += " $exact";
    if (delta.isNotEmpty) words += " $delta";

    return words.replaceAll('  ', ' ').trim();
  }
}

/// Implements the Turkish time-to-words logic with improvements over the reference implementation.
///
/// Differences from [ReferenceTurkishTimeToWords]:
/// 1. **Formal Grammar**: Uses the accusative case for hour words in "geçiyor" (past) phrases
///    (e.g., "SAAT BİRİ BEŞ GEÇİYOR"), similar to the reference but consistent with formal usage.
///    This provides more visual variety on the grid compared to the colloquial nominative form.
/// 2. **Spelling Validations**: Corrects the spelling of "SEKİZ" (was "SEKIZ" in reference) and
///    ensures "ELLİ" uses the dotted 'İ'. Also ensures "SEKİZİ" and "DÖRDÜ" are spelled correctly
///    in their accusative forms.
class TurkishTimeToWords implements TimeToWords {
  const TurkishTimeToWords();
  @override
  String convert(DateTime time) {
    int m = time.minute;
    int h = time.hour;

    // Round down to nearest 5 minutes
    m = m - (m % 5);

    final displayHour = h % 12;

    // Nominative forms for exact hours and half hours
    String hourNominative = switch (displayHour) {
      0 => 'ON İKİ',
      1 => 'BİR',
      2 => 'İKİ',
      3 => 'ÜÇ',
      4 => 'DÖRT',
      5 => 'BEŞ',
      6 => 'ALTI',
      7 => 'YEDİ',
      8 => 'SEKİZ', // Fixed spelling (was SEKIZ)
      9 => 'DOKUZ',
      10 => 'ON',
      11 => 'ON BİR',
      _ => '',
    };

    if (m == 0) {
      return 'SAAT $hourNominative';
    }

    if (m == 30) {
      return 'SAAT $hourNominative BUÇUK';
    }

    // Accusative forms for "passing" (geçiyor) phrases
    // These must define the object of the verb "geçiyor" (passing [the hour])
    String hourAccusative = switch (displayHour) {
      0 => 'ON İKİYİ',
      1 => 'BİRİ',
      2 => 'İKİYİ',
      3 => 'ÜÇÜ',
      4 => 'DÖRDÜ', // T softens to D
      5 => 'BEŞİ',
      6 => 'ALTIYI',
      7 => 'YEDİYİ',
      8 => 'SEKİZİ', // Fixed spelling (dotted İ)
      9 => 'DOKUZU',
      10 => 'ONU',
      11 => 'ON BİRİ',
      _ => '',
    };

    // Minutes > 0 and != 30
    String minuteWord = switch (m) {
      5 => 'BEŞ',
      10 => 'ON',
      15 => 'ÇEYREK',
      20 => 'YİRMİ',
      25 => 'YİRMİ BEŞ',
      35 => 'OTUZ BEŞ',
      40 => 'KIRK',
      45 => 'KIRK BEŞ',
      50 => 'ELLİ', // Ensure dotted İ
      55 => 'ELLİ BEŞ',
      _ => '',
    };

    // Formal: SAAT + HOUR(Accusative) + MINUTE + GEÇİYOR
    return 'SAAT $hourAccusative $minuteWord GEÇİYOR';
  }
}
