import 'package:wordclock/logic/time_to_words.dart';

class NativeFrenchTimeToWords implements TimeToWords {
  static const hoursList = [
    'MINUIT', // Midnight
    'UNE', // One
    'DEUX', // Two
    'TROIS', // Three
    'QUATRE', // Four
    'CINQ', // Five
    'SIX', // Six
    'SEPT', // Seven
    'HUIT', // Eight
    'NEUF', // Nine
    'DIX', // Ten
    'ONZE', // Eleven
    'MIDI', // Noon
  ];

  static const minutes = {
    5: 'CINQ', // Five
    10: 'DIX', // Ten
    20: 'VINGT', // Twenty
    25: 'VINGT-CINQ', // Twenty-five
  };

  @override
  String convert(DateTime time) {
    int h = time.hour;
    int m = (time.minute ~/ 5) * 5; // Round down to nearest 5

    int displayHour = h % 12;
    if (h == 12) displayHour = 12; // MIDI
    if (h == 0) displayHour = 0; // MINUIT

    int nextHour = (h + 1) % 24;
    int nextDisplayHour = nextHour % 12;
    if (nextHour == 12) nextDisplayHour = 12;
    if (nextHour == 0) nextDisplayHour = 0;

    String hLabel(int hr) {
      if (hr == 0) return 'MINUIT';
      if (hr == 12) return 'MIDI';
      return '${hoursList[hr]} HEURE${hr > 1 ? 'S' : ''}'; // HEURE(S) = hour(s)
    }

    return switch (m) {
      0 => 'IL EST ${hLabel(displayHour)}', // It is X o'clock
      15 => 'IL EST ${hLabel(displayHour)} ET QUART', // And quarter
      30 =>
        'IL EST ${hLabel(displayHour)} ET ${displayHour == 0 || displayHour == 12 ? 'DEMI' : 'DEMIE'}', // And half (masculine for noon/midnight, feminine for hours)
      45 =>
        'IL EST ${hLabel(nextDisplayHour)} MOINS LE QUART', // Minus the quarter
      < 30 => 'IL EST ${hLabel(displayHour)} ${minutes[m]}', // X minutes past Y
      _ =>
        'IL EST ${hLabel(nextDisplayHour)} MOINS ${minutes[60 - m]}', // Y minus X minutes
    };
  }
}

class FrenchTimeToWords implements TimeToWords {
  @override
  String convert(DateTime time) {
    int m = time.minute;
    int h = time.hour;

    // Round down to nearest 5 minutes
    m = m - (m % 5);

    // 1. Conditionals (Midi/Minuit half-hours)
    String? conditional = switch (m) {
      30 => switch (h % 24) {
        0 => 'IL EST MINUIT ET DEMI',
        12 => 'IL EST MIDI ET DEMI',
        _ => null,
      },
      _ => null,
    };
    if (conditional != null) return conditional;

    // 2. Hour display limit (35 minutes)
    if (m >= 35) {
      h++;
    }

    final displayHour = h % 12;

    // 5. Delta
    String delta = switch (m) {
      0 => "", // Empty for 0
      5 => ' CINQ', // Five
      10 => ' DIX', // Ten
      15 => ' ET QUART', // And quarter
      20 => ' VINGT', // Twenty
      25 => ' VINGT-CINQ', // Twenty-five
      30 =>
        ' ET DEMI', // And half. (Using DEMI generic, logic below might need fixing about gender)
      35 => ' MOINS VINGT-CINQ', // Minus twenty-five
      40 => ' MOINS VINGT', // Minus twenty
      45 => ' MOINS LE QUART', // Minus the quarter
      50 => ' MOINS DIX', // Minus ten
      55 => ' MOINS CINQ', // Minus five
      _ => '',
    };

    // Note: Original code handled 'ET DEMI' vs 'ET DEMIE' in m=30 switch.
    // But here we need to be careful. Generic 'ET DEMI' in switch above is placeholders?
    // The previous switch had 'IL EST ET DEMIE' which was weird.
    // Let's refine the Delta switch to just be the suffix words.

    if (m == 30) {
      // Logic for DEMI/DEMIE
      // Midi/Minuit -> DEMI (masculine). Others -> DEMIE (feminine "heure").

      // Actually check h%24 directly for Midi/Minuit
      if (h % 24 == 0 || h % 24 == 12) {
        delta = ' ET DEMI';
      } else {
        delta = ' ET DEMIE';
      }
    }

    // 6. Exact hour
    String hExact = switch (h % 24) {
      0 => 'MINUIT', // Midnight
      12 => 'MIDI', // Noon
      _ => switch (displayHour) {
        1 => 'UNE HEURE', // One hour
        2 => 'DEUX HEURES', // Two hours
        3 => 'TROIS HEURES', // Three hours
        4 => 'QUATRE HEURES', // Four hours
        5 => 'CINQ HEURES', // Five hours
        6 => 'SIX HEURES', // Six hours
        7 => 'SEPT HEURES', // Seven hours
        8 => 'HUIT HEURES', // Eight hours
        9 => 'NEUF HEURES', // Nine hours
        10 => 'DIX HEURES', // Ten hours
        11 => 'ONZE HEURES', // Eleven hours
        _ => '',
      },
    };

    // Construct: IL EST [EXACT] [DELTA]
    // Construct: IL EST [EXACT] [DELTA]
    String words = 'IL EST $hExact$delta';

    return words.replaceAll('  ', ' ').trim();
  }
}
