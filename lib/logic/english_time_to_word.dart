import 'package:wordclock/logic/time_to_words.dart';

/// Base implementation for English language variants (EN, E2).
abstract class _BaseEnglishTimeToWords implements TimeToWords {
  const _BaseEnglishTimeToWords();

  String get intro => 'IT IS';
  int get hourDisplayLimit;

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

  // Returns delta phrase (usually includes 'PAST' or 'TO')
  String getDelta(int minute);

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

/// Original algorithmic implementation for English.
/// Corresponds to 'NativeEnglishTimeToWords'.
class NativeEnglishTimeToWords implements TimeToWords {
  const NativeEnglishTimeToWords();

  static const _hours = [
    'TWELVE',
    'ONE',
    'TWO',
    'THREE',
    'FOUR',
    'FIVE',
    'SIX',
    'SEVEN',
    'EIGHT',
    'NINE',
    'TEN',
    'ELEVEN',
  ];

  static const _minutes = {
    5: "FIVE",
    10: "TEN",
    20: "TWENTY",
    25: "TWENTY FIVE",
  };

  @override
  String convert(DateTime time) {
    int m = (time.minute ~/ 5) * 5; // Round down to nearest 5
    int h = (m > 30) ? time.hour + 1 : time.hour;

    int displayHour = h % 12;

    final hStr = _hours[displayHour];

    return switch (m) {
      0 => "IT IS $hStr OCLOCK",
      15 => "IT IS QUARTER PAST $hStr",
      30 => "IT IS HALF PAST $hStr",
      45 => "IT IS QUARTER TO $hStr",
      < 30 => "IT IS ${_minutes[m]} PAST $hStr",
      _ => "IT IS ${_minutes[60 - m]} TO $hStr",
    };
  }
}

/// Standard English (EN).
class EnglishTimeToWords extends _BaseEnglishTimeToWords {
  const EnglishTimeToWords();

  @override
  int get hourDisplayLimit => 35;

  @override
  String getDelta(int minute) => switch (minute) {
    0 => " O'CLOCK",
    5 => " FIVE PAST",
    10 => " TEN PAST",
    15 => " QUARTER PAST",
    20 => " TWENTY PAST",
    25 => " TWENTYFIVE PAST",
    30 => " HALF PAST",
    35 => " TWENTYFIVE TO",
    40 => " TWENTY TO",
    45 => " QUARTER TO",
    50 => " TEN TO",
    55 => " FIVE TO",
    _ => "",
  };
}

/// English Alternative (E2).
/// Uses "A QUARTER" instead of "QUARTER".
class EnglishAlternativeTimeToWords extends _BaseEnglishTimeToWords {
  const EnglishAlternativeTimeToWords();

  @override
  int get hourDisplayLimit => 35;

  @override
  String getDelta(int minute) => switch (minute) {
    0 => " O'CLOCK",
    5 => " FIVE PAST",
    10 => " TEN PAST",
    15 => " A QUARTER PAST",
    20 => " TWENTY PAST",
    25 => " TWENTYFIVE PAST",
    30 => " HALF PAST",
    35 => " TWENTYFIVE TO",
    40 => " TWENTY TO",
    45 => " A QUARTER TO",
    50 => " TEN TO",
    55 => " FIVE TO",
    _ => "",
  };
}

/// English Digital (E3).
/// Uses "Exact Delta" order (e.g., TWELVE FIVE).
/// Note: Contains specific spellings like 'TWELFE' from original data.
class EnglishDigitalTimeToWords implements TimeToWords {
  const EnglishDigitalTimeToWords();

  @override
  String convert(DateTime time) {
    int m = (time.minute ~/ 5) * 5;
    int h = time.hour % 12;
    if (h == 0) h = 12;

    String words = 'IT IS';

    String exact = switch (h) {
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
      12 => 'TWELFE', // Legacy spelling from data source
      _ => '',
    };

    String delta = switch (m) {
      0 => '',
      5 => 'FIVE',
      10 => 'TEN',
      15 => 'FIFTEEN',
      20 => 'TWENTY',
      25 => 'TWENTY FIVE',
      30 => 'THIRTY',
      35 => 'THIRTY FIVE',
      40 => 'FORTY',
      45 => 'FORTY FIVE',
      50 => 'FIFTY',
      55 => 'FIFTY FIVE',
      _ => '',
    };

    // E3 Order: Intro Exact Delta
    words += " $exact";
    if (delta.isNotEmpty) words += " $delta";

    return words.replaceAll('  ', ' ').trim();
  }
}
