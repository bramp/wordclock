import 'package:wordclock/logic/time_to_words.dart';

/// Base implementation for English language variants (EN, E2).
///
/// This class consolidates the logic for converting time to English words,
/// supporting various configurations for dialect differences (e.g., "A QUARTER",
/// typographic apostrophes, spacing in "TWENTY FIVE").
abstract class _BaseEnglishTimeToWords implements TimeToWords {
  /// whether to use "TWENTY FIVE" (true) or "TWENTYFIVE" (false).
  final bool useSpaceInTwentyFive;

  /// Whether to use the typographic apostrophe (’) or standard (').
  final bool useTypographicApostrophe;

  /// Whether to include "A" before "QUARTER" (e.g., "A QUARTER PAST").
  final bool useAQuarter;

  const _BaseEnglishTimeToWords({
    this.useSpaceInTwentyFive = true,
    this.useTypographicApostrophe = false,
    this.useAQuarter = false,
  });

  String get intro => 'IT IS';
  int get hourDisplayLimit => 35;

  String get oClock => useTypographicApostrophe ? "O’CLOCK" : "O'CLOCK";
  String get quarter => useAQuarter ? "A QUARTER" : "QUARTER";
  String get twentyFive => useSpaceInTwentyFive ? "TWENTY FIVE" : "TWENTYFIVE";

  // Returns the hour name (0=TWELVE)
  String getHour(int hour) => switch (hour) {
    0 => 'TWELVE',
    1 => 'ONE',
    2 => 'TWO',
    3 => 'THREE',
    4 => 'FOUR',
    5 => 'FIVE',
    6 => 'SIX',
    7 => 'SEVEN',
    8 => 'EIGHT',
    9 => 'NINE',
    10 => 'TEN',
    11 => 'ELEVEN',
    _ => '',
  };

  String getDelta(int minute) => switch (minute) {
    0 => " $oClock",
    5 => " FIVE PAST",
    10 => " TEN PAST",
    15 => " $quarter PAST",
    20 => " TWENTY PAST",
    25 => " $twentyFive PAST",
    30 => " HALF PAST",
    35 => " $twentyFive TO",
    40 => " TWENTY TO",
    45 => " $quarter TO",
    50 => " TEN TO",
    55 => " FIVE TO",
    _ => "",
  };

  @override
  String convert(DateTime time) {
    int m = time.minute;
    int h = time.hour;

    // Round down to nearest 5 minutes
    m = m - (m % 5);

    // Rollover hour
    if (m >= hourDisplayLimit) {
      h++;
    }

    final displayHour = h % 12;
    final exact = getHour(displayHour);
    final delta = getDelta(m);

    String words = intro;
    if (m == 0) {
      // 0 minutes: Exact + Delta (e.g., TWELVE O'CLOCK)
      words += ' $exact$delta';
    } else {
      // Others: Delta + Exact (e.g., TEN PAST TWELVE)
      words += '$delta $exact';
    }

    return words.replaceAll('  ', ' ').trim();
  }
}

/// Standard English (EN) Reference implementation.
class ReferenceEnglishTimeToWords extends _BaseEnglishTimeToWords {
  const ReferenceEnglishTimeToWords({super.useSpaceInTwentyFive = false})
    : super(useTypographicApostrophe: false, useAQuarter: false);
}

/// English Alternative (E2) Reference implementation.
/// Historically used "A QUARTER" and standard apostrophes.
class ReferenceEnglishAlternativeTimeToWords extends _BaseEnglishTimeToWords {
  const ReferenceEnglishAlternativeTimeToWords({
    super.useSpaceInTwentyFive = true,
  }) : super(useTypographicApostrophe: false, useAQuarter: true);
}

/// Modern English implementation.
/// - Consistently uses a space in "TWENTY FIVE".
/// - Uses typographic apostrophe for "O’CLOCK".
class EnglishTimeToWords extends _BaseEnglishTimeToWords {
  const EnglishTimeToWords()
    : super(
        useSpaceInTwentyFive: true,
        useTypographicApostrophe: true,
        useAQuarter: false,
      );
}

/// Modern English Alternative implementation.
/// - Removes the optional "A" from "A QUARTER" for compactness (making it effectively same as EnglishTimeToWords).
/// - Consistently uses a space in "TWENTY FIVE".
/// - Uses typographic apostrophe for "O’CLOCK".
class EnglishAlternativeTimeToWords extends _BaseEnglishTimeToWords {
  const EnglishAlternativeTimeToWords()
    : super(
        useSpaceInTwentyFive: true,
        useTypographicApostrophe: true,
        // Recommendation: Drop the redundant "A" from "A QUARTER" for compactness.
        useAQuarter: false,
      );
}
