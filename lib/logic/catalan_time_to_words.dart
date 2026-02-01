import 'package:wordclock/logic/time_to_words.dart';

class ReferenceCatalanTimeToWords implements TimeToWords {
  const ReferenceCatalanTimeToWords();
  @override
  String convert(DateTime time) {
    int m = (time.minute ~/ 5) * 5;
    int h = time.hour;

    // Hour increment (hourDisplayLimit: 10) for delta logic
    if (m >= 10) h++;

    final dh = h % 12;

    // Word parts
    String intro = '';
    String exact = '';
    String delta = '';
    String link = ''; // "DE" or "D'R"

    // Logic for Exact Hour Word
    exact = switch (dh) {
      0 => 'DOTZE',
      1 => 'UNA',
      2 => 'DUES',
      3 => 'TRES',
      4 => 'QUATRE',
      5 => 'CINC',
      6 => 'SIS',
      7 => 'SET',
      8 => 'VUIT',
      9 => 'NOU',
      10 => 'DEU',
      11 => 'ONZE',
      _ => '',
    };

    if (m < 10) {
      // Logic for 0 and 5 minutes: Intro + Exact + Delta
      // Intro selection
      if (dh == 1) {
        intro = 'ÉS LA';
      } else {
        intro = 'SÓN LES';
      }

      if (m == 5) {
        delta = 'I CINC';
      } else {
        delta = '';
      }

      // Construct: Intro Exact Delta
      return '$intro $exact $delta'.trim().replaceAll('  ', ' ');
    } else {
      // Logic for Quarts (m >= 10)

      // Delta phrases
      delta = switch (m) {
        10 => 'ÉS UN QUART MENYS CINC',
        15 => 'ÉS UN QUART',
        20 => 'ÉS UN QUART I CINC',
        25 => 'SÓN DOS QUARTS MENYS CINC',
        30 => 'SÓN DOS QUARTS',
        35 => 'SÓN DOS QUARTS I CINC',
        40 => 'SÓN TRES QUARTS MENYS CINC',
        45 => 'SÓN TRES QUARTS',
        50 => 'SÓN TRES QUARTS I CINC',
        55 => 'SÓN LES MENYS CINC', // Special case?
        _ => '',
      };

      // Notes on m=55: "SÓN LES MENYS CINC" usually implies "Next Hour".
      // Let's check consistency. The old code had:
      // 55 => (dh == 1) ? 'ÉS LA' : 'SÓN LES MENYS CINC',

      if (m == 55) {
        if (dh == 1) {
          delta = 'ÉS LA'; // "It is the (one)"?
        } else {
          delta = 'SÓN LES MENYS CINC';
        }
        // Wait, if m=55, we are pointing to next hour.
        // "SÓN LES MENYS CINC DE ..." or just "SÓN LES MENYS CINC"?
        // Usually "Són les tres menys cinc" (It is three minus five).
        // Structure: "Són les menys cinc" + "Exact"? No.
        // "Són les" + "Exact" + "menys cinc".

        // If `delta` includes "SÓN LES", then structure `Delta + Link + Exact` becomes `SÓN LES ... DE ...`.
        // But 55 is special. It's not a "Quart".

        // Let's assume m=55 is like m=0/5 but "Minus".
        // Structure: Intro + Exact + "MENYS CINC".

        String suffix = 'MENYS CINC';
        if (dh == 1) {
          intro = 'ÉS LA';
        } else {
          intro = 'SÓN LES';
        }

        return '$intro $exact $suffix'.trim().replaceAll('  ', ' ');
      }

      // Link word
      if (dh == 1 || dh == 11) {
        link = "D'"; // UNA or ONZE starts with vowel
      } else {
        link = "DE";
      }

      // Construct: Delta Link Exact
      return '$delta $link $exact'.trim().replaceAll('  ', ' ');
    }
  }
}

/// Catalan implementation that differs from [ReferenceCatalanTimeToWords] by:
/// - Removing the space after apostrophes in "D' UNA" and "D' ONZE" (e.g., "D'UNA", "D'ONZE").
class CatalanTimeToWords extends ReferenceCatalanTimeToWords {
  const CatalanTimeToWords();

  @override
  String convert(DateTime time) {
    // Call the reference implementation and then fix the spacing issues
    // identified in the expert review.
    final result = super.convert(time);

    // Fix: Remove space after the apostrophe in "D' UNA" and "D' ONZE"
    return result.replaceAll("D' ", "D'");
  }
}
