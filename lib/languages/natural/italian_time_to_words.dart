import 'package:wordclock/logic/time_to_words.dart';

/// Base implementation for Italian language.
abstract class _BaseItalianTimeToWords implements TimeToWords {
  const _BaseItalianTimeToWords();

  String getHour(int hour) => switch (hour) {
    0 => 'SONO LE DODICI',
    1 => 'È L’UNA',
    2 => 'SONO LE DUE',
    3 => 'SONO LE TRE',
    4 => 'SONO LE QUATTRO',
    5 => 'SONO LE CINQUE',
    6 => 'SONO LE SEI',
    7 => 'SONO LE SETTE',
    8 => 'SONO LE OTTO',
    9 => 'SONO LE NOVE',
    10 => 'SONO LE DIECI',
    11 => 'SONO LE UNDICI',
    _ => '',
  };

  String getDelta(int minute) => switch (minute) {
    5 => 'E CINQUE',
    10 => 'E DIECI',
    15 => 'E UN QUARTO',
    20 => 'E VENTI',
    25 => 'E VENTICINQUE',
    30 => 'E MEZZA',
    35 => 'MENO VENTICINQUE',
    40 => 'MENO VENTI',
    45 => 'MENO UN QUARTO',
    50 => 'MENO DIECI',
    55 => 'MENO CINQUE',
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

    final displayHour = h % 12;

    final exact = getHour(displayHour);
    final delta = getDelta(m);

    String words = exact;
    if (delta.isNotEmpty) {
      words += ' $delta';
    }

    return words.replaceAll('  ', ' ').trim();
  }
}

/// Standard Italian (IT) Reference implementation.
class ReferenceItalianTimeToWords extends _BaseItalianTimeToWords {
  const ReferenceItalianTimeToWords();
}

/// Italian implementation.
/// Matches [ReferenceItalianTimeToWords].
class ItalianTimeToWords extends ReferenceItalianTimeToWords {
  const ItalianTimeToWords();
}
