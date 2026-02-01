import 'package:wordclock/logic/time_to_words.dart';

/// Base implementation for German language variants.
/// Handles common logic for rounding, hour rollover, and sentence structure.
abstract class _BaseGermanTimeToWords implements TimeToWords {
  const _BaseGermanTimeToWords();

  String get intro;
  int get hourDisplayLimit;
  bool get usesEinUhrLogic;

  // Returns the hour name for 0..11 (0=Twelve/Zwölf)
  String getHour(int hour);

  // Returns the delta phrase for minutes 0, 5..55
  String getDelta(int minute);

  @override
  String convert(DateTime time) {
    int m = time.minute;
    int h = time.hour;

    // Round down to the nearest 5 minutes
    m = m - (m % 5);

    // Apply special "Ein Uhr" logic for 1:00 / 13:00
    if (usesEinUhrLogic && m == 0 && (h % 12 == 1)) {
      return '$intro EIN UHR';
    }

    // Rollover hour if minutes exceed limit (e.g., 25, 20, 15)
    if (m >= hourDisplayLimit) {
      h++;
    }

    final displayHour = h % 12;
    final exact = getHour(displayHour);
    final delta = getDelta(m);

    String words = intro;
    if (m == 0) {
      // 0 minutes: Exact + Delta (often ' UHR' or empty)
      words += ' $exact$delta';
    } else {
      // Others: Delta + Exact
      // Delta usually includes spacing (e.g., " FÜNF NACH")
      words += '$delta $exact';
    }

    return words.replaceAll('  ', ' ').trim();
  }
}

/// Original algorithmic implementation for German.
/// Calculates phrases dynamically (e.g., "5 before half") rather than using fixed lookups.
/// Corresponds to 'NativeGermanTimeToWords'.
class NativeGermanTimeToWords implements TimeToWords {
  const NativeGermanTimeToWords();

  static const _hours = [
    'ZWÖLF',
    'EINS',
    'ZWEI',
    'DREI',
    'VIER',
    'FÜNF',
    'SECHS',
    'SIEBEN',
    'ACHT',
    'NEUN',
    'ZEHN',
    'ELF',
  ];

  static const _minutes = {
    5: 'FÜNF',
    10: 'ZEHN',
    15: 'VIERTEL',
    20: 'ZWANZIG',
    25: 'FÜNF',
  };

  @override
  String convert(DateTime time) {
    int h = time.hour;
    int m = (time.minute ~/ 5) * 5; // Round down to nearest 5

    int displayHour = h % 12;
    int nextHour = (displayHour + 1) % 12;

    // "Ein Uhr" instead of "Eins Uhr" for 1:00
    final hStr = (displayHour == 1 && m == 0) ? 'EIN' : _hours[displayHour];
    final nextHStr = _hours[nextHour];

    return switch (m) {
      0 => 'ES IST $hStr UHR',
      15 => 'ES IST VIERTEL NACH $hStr',
      30 => 'ES IST HALB $nextHStr',
      45 => 'ES IST VIERTEL VOR $nextHStr',
      < 20 => 'ES IST ${activeMinute(m)} NACH $hStr', // X after Y
      < 30 =>
        'ES IST ${activeMinute(30 - m)} VOR HALB $nextHStr', // X before half Y
      < 40 =>
        'ES IST ${activeMinute(m - 30)} NACH HALB $nextHStr', // X after half Y
      _ => 'ES IST ${activeMinute(60 - m)} VOR $nextHStr', // X before Y
    };
  }

  String activeMinute(int m) => _minutes[m]!;
}

/// Standard German (DE) implementation (Qlocktwo Logic).
class ReferenceGermanTimeToWords extends _BaseGermanTimeToWords {
  const ReferenceGermanTimeToWords();

  @override
  String get intro => 'ES IST';

  @override
  int get hourDisplayLimit => 25;

  @override
  bool get usesEinUhrLogic => true;

  @override
  String getHour(int hour) => switch (hour) {
    0 => 'ZWÖLF',
    1 => 'EINS',
    2 => 'ZWEI',
    3 => 'DREI',
    4 => 'VIER',
    5 => 'FÜNF',
    6 => 'SECHS',
    7 => 'SIEBEN',
    8 => 'ACHT',
    9 => 'NEUN',
    10 => 'ZEHN',
    11 => 'ELF',
    _ => '',
  };

  @override
  String getDelta(int minute) => switch (minute) {
    0 => ' UHR',
    5 => ' FÜNF NACH',
    10 => ' ZEHN NACH',
    15 => ' VIERTEL NACH',
    20 => ' ZWANZIG NACH',
    25 => ' FÜNF VOR HALB',
    30 => ' HALB',
    35 => ' FÜNF NACH HALB',
    40 => ' ZWANZIG VOR',
    45 => ' VIERTEL VOR',
    50 => ' ZEHN VOR',
    55 => ' FÜNF VOR',
    _ => '',
  };
}

/// Standard German (DE) implementation that differs from [ReferenceGermanTimeToWords] by:
/// - Omiting "UHR" for whole hours.
/// - Using "EINS" instead of "EIN UHR" for 1 o'clock.
class GermanTimeToWords extends ReferenceGermanTimeToWords {
  const GermanTimeToWords();

  @override
  bool get usesEinUhrLogic => false; // Use "EINS" instead of "EIN UHR"

  @override
  String getDelta(int minute) {
    if (minute == 0) return ''; // Omit "UHR"
    return super.getDelta(minute);
  }
}

/// Original Reference Bernese German (CH) implementation (TimeClock).
/// Should not be modified. Matches the reference implementation.
class ReferenceBerneseGermanTimeToWords extends _BaseGermanTimeToWords {
  const ReferenceBerneseGermanTimeToWords();

  @override
  String get intro => 'ES ISCH'; // It is

  @override
  int get hourDisplayLimit => 25;

  @override
  bool get usesEinUhrLogic => false;

  @override
  String getHour(int hour) => switch (hour) {
    0 => 'ZWÖUFI', // Twelve
    1 => 'EIS', // One
    2 => 'ZWÖI', // Two
    3 => 'DRÜ', // Three
    4 => 'VIERI', // Four
    5 => 'FÜFI', // Five
    6 => 'SÄCHSI', // Six
    7 => 'SIBNI', // Seven
    8 => 'ACHTI', // Eight
    9 => 'NÜNI', // Nine
    10 => 'ZÄNI', // Ten
    11 => 'EUFI', // Eleven
    _ => '',
  };

  @override
  String getDelta(int minute) => switch (minute) {
    0 => '',
    5 => ' FÜF AB', // Five after
    10 => ' ZÄÄ AB', // Ten after
    15 => ' VIERTU AB', // Quarter after
    20 => ' ZWÄNZG AB', // Twenty after
    25 => ' FÜF VOR HAUBI', // Five before half
    30 => ' HAUBI', // Half
    35 => ' FÜF AB HAUBI', // Five after half
    40 => ' ZWÄNZG VOR', // Twenty before
    45 => ' VIERTU VOR', // Quarter before
    50 => ' ZÄÄ VOR', // Ten before
    55 => ' FÜF VOR', // Five before
    _ => '',
  };
}

/// Bernese German (CH) implementation that differs from [ReferenceBerneseGermanTimeToWords] by:
/// - Using "VIERI" instead of "VIER" for 4 o'clock.
/// - Using "ZÄNI" instead of "ZÄÄ" for 10 o'clock.
class BerneseGermanTimeToWords extends ReferenceBerneseGermanTimeToWords {
  const BerneseGermanTimeToWords();

  @override
  String getHour(int hour) => switch (hour) {
    4 => 'VIERI', // Expert suggested VIERI over VIER
    10 => 'ZÄNI', // Expert suggested ZÄNI over ZÄÄ for the hour
    _ => super.getHour(hour),
  };
}

/// Alternative German (D2) implementation.
class ReferenceGermanAlternativeTimeToWords extends ReferenceGermanTimeToWords {
  const ReferenceGermanAlternativeTimeToWords();

  @override
  int get hourDisplayLimit => 20;

  @override
  String getDelta(int minute) {
    if (minute == 20) return ' ZEHN VOR HALB'; // Ten before half
    if (minute == 40) return ' ZEHN NACH HALB'; // Ten after half
    if (minute == 45) return ' DREIVIERTEL'; // Three-quarters
    return super.getDelta(minute);
  }
}

/// German Alternative (D2) implementation that differs from [ReferenceGermanAlternativeTimeToWords] by:
/// - Using "VIERTEL VOR" instead of "DREIVIERTEL" for 45 minutes.
class GermanAlternativeTimeToWords
    extends ReferenceGermanAlternativeTimeToWords {
  const GermanAlternativeTimeToWords();

  @override
  String getDelta(int minute) {
    if (minute == 45) {
      return ' VIERTEL VOR'; // Use VIERTEL VOR instead of DREIVIERTEL
    }
    return super.getDelta(minute);
  }
}

/// Swabian/Bavarian (D3) implementation.
class ReferenceSwabianGermanTimeToWords extends _BaseGermanTimeToWords {
  const ReferenceSwabianGermanTimeToWords();

  @override
  String get intro => 'ES ISCH'; // It is

  @override
  int get hourDisplayLimit => 15;

  @override
  bool get usesEinUhrLogic => false;

  @override
  String getHour(int hour) => switch (hour) {
    0 => 'ZWÖLFE', // Twelve
    1 => 'OISE', // One
    2 => 'ZWOIE', // Two
    3 => 'DREIE', // Three
    4 => 'VIERE', // Four
    5 => 'FÜNFE', // Five
    6 => 'SECHSE', // Six
    7 => 'SIEBNE', // Seven
    8 => 'ACHTE', // Eight
    9 => 'NEUNE', // Nine
    10 => 'ZEHNE', // Ten
    11 => 'ELFE', // Eleven
    _ => '',
  };

  @override
  String getDelta(int minute) => switch (minute) {
    0 => '',
    5 => ' FÜNF NACH', // Five after
    10 => ' ZEHN NACH', // Ten after
    15 => ' VIERTL', // Quarter
    20 => ' ZEHN VOR HALB', // Ten before half
    25 => ' FÜNF VOR HALB', // Five before half
    30 => ' HALB', // Half
    35 => ' FÜNF NACH HALB', // Five after half
    40 => ' ZEHN NACH HALB', // Ten after half
    45 => ' DREIVIERTL', // Three-quarters
    50 => ' ZEHN VOR', // Ten before
    55 => ' FÜNF VOR', // Five before
    _ => '',
  };
}

/// Swabian/Bavarian (D3) implementation that differs from [ReferenceSwabianGermanTimeToWords] by:
/// - Standardizing hour names by removing trailing "-E". This increases consistency and grid optimization (e.g., "ZWÖLF" instead of "ZWÖLFE").
class SwabianGermanTimeToWords extends ReferenceSwabianGermanTimeToWords {
  const SwabianGermanTimeToWords();

  @override
  String getHour(int hour) => switch (hour) {
    0 => 'ZWÖLF', // Twelve
    1 => 'OIS', // One
    2 => 'ZWOI', // Two
    3 => 'DREI', // Three
    4 => 'VIER', // Four
    5 => 'FÜNF', // Five
    6 => 'SECHS', // Six
    7 => 'SIBE', // Seven
    8 => 'ACHT', // Eight
    9 => 'NEUN', // Nine
    10 => 'ZEHN', // Ten
    11 => 'ELF', // Eleven
    _ => '',
  };
}

/// East German (D4) implementation.
class ReferenceEastGermanTimeToWords extends ReferenceGermanTimeToWords {
  const ReferenceEastGermanTimeToWords();

  @override
  int get hourDisplayLimit => 15;

  @override
  String getDelta(int minute) => switch (minute) {
    0 => ' UHR',
    5 => ' FÜNF NACH',
    10 => ' ZEHN NACH',
    15 => ' VIERTEL', // Quarter (No 'after')
    20 => ' ZEHN VOR HALB', // Ten before half
    25 => ' FÜNF VOR HALB', // Five before half
    30 => ' HALB', // Half
    35 => ' FÜNF NACH HALB', // Five after half
    40 => ' ZEHN NACH HALB', // Ten after half
    45 => ' DREIVIERTEL', // Three-quarters
    50 => ' ZEHN VOR', // Ten before
    55 => ' FÜNF VOR', // Five before
    _ => '',
  };
}
