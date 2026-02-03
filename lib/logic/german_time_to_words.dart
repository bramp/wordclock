import 'package:wordclock/logic/time_to_words.dart';

/// Base implementation for German language variants.
/// Handles common logic for rounding, hour rollover, and sentence structure.
abstract class _BaseGermanTimeToWords implements TimeToWords {
  final String intro;
  final int hourDisplayLimit;
  final bool usesEinUhrLogic;
  final bool omitUhr;

  const _BaseGermanTimeToWords({
    required this.intro,
    required this.hourDisplayLimit,
    this.usesEinUhrLogic = true,
    this.omitUhr = false,
  });

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

    // Apply special "Ein Uhr" logic for 1:00 (if enabled)
    // "EIN UHR" vs "EINS" (or other variants)
    // Logic: If usesEinUhrLogic is true, 1:00 is "EIN UHR".
    // If false, it uses getHour(1) which should return "EINS" (or dialect variant).
    if (m == 0 && (h % 12 == 1)) {
      if (usesEinUhrLogic) {
        return '$intro EIN${omitUhr ? '' : ' UHR'}';
      }
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
      // 0 minutes: Exact + Delta (typically ' UHR' unless omitted)
      // If delta is empty (some variants), words is just intro + exact.
      if (delta.isNotEmpty) {
        words += ' $exact$delta';
      } else {
        words += ' $exact';
      }
    } else {
      // Others: Delta + Exact
      // Delta usually includes spacing (e.g., " FÜNF NACH")
      words += '$delta $exact';
    }

    return words.replaceAll('  ', ' ').trim();
  }
}

// --- Standard German (DE) ---

/// Standard German (DE) implementation.
class ReferenceGermanTimeToWords extends _BaseGermanTimeToWords {
  const ReferenceGermanTimeToWords({
    super.intro = 'ES IST',
    super.hourDisplayLimit = 25,
    super.usesEinUhrLogic = true,
    super.omitUhr = false,
  });

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
    0 => omitUhr ? '' : ' UHR',
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

/// Optimized Standard German (DE).
/// - Omiting "UHR".
/// - Using "EINS" instead of "EIN UHR" (via usesEinUhrLogic = false).
class GermanTimeToWords extends ReferenceGermanTimeToWords {
  const GermanTimeToWords() : super(omitUhr: true, usesEinUhrLogic: false);
}

// --- Bernese German (CH) ---

class ReferenceBerneseGermanTimeToWords extends _BaseGermanTimeToWords {
  const ReferenceBerneseGermanTimeToWords()
    : super(intro: 'ES ISCH', hourDisplayLimit: 25, usesEinUhrLogic: false);

  @override
  String getHour(int hour) => switch (hour) {
    0 => 'ZWÖUFI',
    1 => 'EIS',
    2 => 'ZWÖI',
    3 => 'DRÜ',
    4 => 'VIERI',
    5 => 'FÜFI',
    6 => 'SÄCHSI',
    7 => 'SIBNI',
    8 => 'ACHTI',
    9 => 'NÜNI',
    10 => 'ZÄNI',
    11 => 'EUFI',
    _ => '',
  };

  @override
  String getDelta(int minute) => switch (minute) {
    0 => '',
    5 => ' FÜF AB',
    10 => ' ZÄÄ AB',
    15 => ' VIERTU AB',
    20 => ' ZWÄNZG AB',
    25 => ' FÜF VOR HAUBI',
    30 => ' HAUBI',
    35 => ' FÜF AB HAUBI',
    40 => ' ZWÄNZG VOR',
    45 => ' VIERTU VOR',
    50 => ' ZÄÄ VOR',
    55 => ' FÜF VOR',
    _ => '',
  };
}

class BerneseGermanTimeToWords extends ReferenceBerneseGermanTimeToWords {
  const BerneseGermanTimeToWords();

  @override
  String getHour(int hour) => switch (hour) {
    // Expert suggested VIERI over VIER, ZÄNI over ZÄÄ
    // (Note: Base class already uses VIERI and ZÄNI, so this override might be redundant
    // unless the reference implementation used VIER/ZÄÄ previously?
    // Checking previous code: Reference used VIERI and ZÄNI.
    // Wait, original file said:
    // Reference: 4=>VIERI, 10=>ZÄNI
    // Bernese override: 4=>VIERI, 10=>ZÄNI.
    // It seems identical. I will keep it clean here.)
    4 => 'VIERI',
    10 => 'ZÄNI',
    _ => super.getHour(hour),
  };
}

// --- German Alternative (D2) ---

class ReferenceGermanAlternativeTimeToWords extends ReferenceGermanTimeToWords {
  const ReferenceGermanAlternativeTimeToWords() : super(hourDisplayLimit: 20);

  @override
  String getDelta(int minute) {
    // Distinctive D2 logic
    if (minute == 20) return ' ZEHN VOR HALB';
    if (minute == 40) return ' ZEHN NACH HALB';
    if (minute == 45) return ' DREIVIERTEL';
    return super.getDelta(minute);
  }
}

class GermanAlternativeTimeToWords
    extends ReferenceGermanAlternativeTimeToWords {
  const GermanAlternativeTimeToWords();

  @override
  String getDelta(int minute) {
    // Optimization: VIERTEL VOR instead of DREIVIERTEL
    if (minute == 45) return ' VIERTEL VOR';
    return super.getDelta(minute);
  }
}

// --- East German (D4) ---

class ReferenceEastGermanTimeToWords extends ReferenceGermanTimeToWords {
  const ReferenceEastGermanTimeToWords() : super(hourDisplayLimit: 15);

  @override
  String getDelta(int minute) => switch (minute) {
    15 => ' VIERTEL', // Distinctive: No 'NACH'
    20 => ' ZEHN VOR HALB',
    40 => ' ZEHN NACH HALB',
    45 => ' DREIVIERTEL',
    _ => super.getDelta(minute),
  };
}

// --- Swabian/Bavarian (D3) ---

class ReferenceSwabianGermanTimeToWords extends _BaseGermanTimeToWords {
  const ReferenceSwabianGermanTimeToWords()
    : super(intro: 'ES ISCH', hourDisplayLimit: 15, usesEinUhrLogic: false);

  @override
  String getHour(int hour) => switch (hour) {
    0 => 'ZWÖLFE',
    1 => 'OISE',
    2 => 'ZWOIE',
    3 => 'DREIE',
    4 => 'VIERE',
    5 => 'FÜNFE',
    6 => 'SECHSE',
    7 => 'SIEBNE',
    8 => 'ACHTE',
    9 => 'NEUNE',
    10 => 'ZEHNE',
    11 => 'ELFE',
    _ => '',
  };

  @override
  String getDelta(int minute) => switch (minute) {
    0 => '',
    5 => ' FÜNF NACH',
    10 => ' ZEHN NACH',
    15 => ' VIERTL',
    20 => ' ZEHN VOR HALB',
    25 => ' FÜNF VOR HALB',
    30 => ' HALB',
    35 => ' FÜNF NACH HALB',
    40 => ' ZEHN NACH HALB',
    45 => ' DREIVIERTL',
    50 => ' ZEHN VOR',
    55 => ' FÜNF VOR',
    _ => '',
  };
}

/// Swabian/Bavarian (D3) Optimized.
class SwabianGermanTimeToWords extends ReferenceSwabianGermanTimeToWords {
  const SwabianGermanTimeToWords();

  @override
  String getHour(int hour) => switch (hour) {
    // Standardizing hour names by removing trailing "-E".
    0 => 'ZWÖLF',
    1 => 'OIS',
    2 => 'ZWOI',
    3 => 'DREI',
    4 => 'VIER',
    5 => 'FÜNF',
    6 => 'SECHS',
    7 => 'SIBE',
    8 => 'ACHT',
    9 => 'NEUN',
    10 => 'ZEHN',
    11 => 'ELF',
    _ => '',
  };
}
