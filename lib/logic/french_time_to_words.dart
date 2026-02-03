import 'package:wordclock/logic/time_to_words.dart';

/// Base implementation for French language.
abstract class _BaseFrenchTimeToWords implements TimeToWords {
  const _BaseFrenchTimeToWords();

  String getHour(int hour) => switch (hour) {
    0 => 'MINUIT', // Midnight
    12 => 'MIDI', // Noon
    _ => switch (hour > 12 ? hour - 12 : hour) {
      1 => 'UNE HEURE',
      2 => 'DEUX HEURES',
      3 => 'TROIS HEURES',
      4 => 'QUATRE HEURES',
      5 => 'CINQ HEURES',
      6 => 'SIX HEURES',
      7 => 'SEPT HEURES',
      8 => 'HUIT HEURES',
      9 => 'NEUF HEURES',
      10 => 'DIX HEURES',
      11 => 'ONZE HEURES',
      _ => '',
    },
  };

  String getDelta(int minute) => switch (minute) {
    5 => ' CINQ',
    10 => ' DIX',
    15 => ' ET QUART',
    20 => ' VINGT',
    25 => ' VINGT-CINQ',
    35 => ' MOINS VINGT-CINQ',
    40 => ' MOINS VINGT',
    45 => ' MOINS LE QUART',
    50 => ' MOINS DIX',
    55 => ' MOINS CINQ',
    _ => '',
  };

  @override
  String convert(DateTime time) {
    int m = time.minute;
    int h = time.hour;

    // Round down to nearest 5 minutes
    m = m - (m % 5);

    // Rollover hour if minutes >= 35
    if (m >= 35) {
      h++;
    }

    // Handle 0 and 12/24 special cases for Hours
    final h24 = h % 24;

    // Determine the hour phrase
    final exact = getHour(h24);

    // Determine the delta phrase
    String delta = getDelta(m);

    // Special logic for 30 (Half past)
    if (m == 30) {
      if (h24 == 0 || h24 == 12) {
        delta = ' ET DEMI'; // Masculine for Midi/Minuit
      } else {
        delta = ' ET DEMIE'; // Feminine for Heures
      }
    }

    String words = 'IL EST $exact$delta';

    return words.replaceAll('  ', ' ').trim();
  }
}

/// Standard French (FR) Reference implementation.
class ReferenceFrenchTimeToWords extends _BaseFrenchTimeToWords {
  const ReferenceFrenchTimeToWords();
}

/// French implementation.
class FrenchTimeToWords extends ReferenceFrenchTimeToWords {
  const FrenchTimeToWords();
}
