import 'package:wordclock/logic/time_to_words.dart';

/// Base implementation for Catalan language.
abstract class _BaseCatalanTimeToWords implements TimeToWords {
  final bool useSpaceAfterApostrophe;

  const _BaseCatalanTimeToWords({this.useSpaceAfterApostrophe = true});

  String getHour(int hour) => switch (hour) {
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

  @override
  String convert(DateTime time) {
    int m = (time.minute ~/ 5) * 5;
    int h = time.hour;

    // Hour increment (hourDisplayLimit: 10) for delta logic
    if (m >= 10) h++;

    final dh = h % 12;
    final exact = getHour(dh);

    if (m < 10) {
      final intro = (dh == 1) ? 'ÉS LA' : 'SÓN LES';
      final delta = (m == 5) ? 'I CINC' : '';
      return '$intro $exact $delta'.trim().replaceAll('  ', ' ');
    }

    if (m == 55) {
      final intro = (dh == 1) ? 'ÉS LA' : 'SÓN LES';
      return '$intro $exact MENYS CINC'.trim().replaceAll('  ', ' ');
    }

    // Logic for Quarts (m >= 10 and < 55)
    final delta = switch (m) {
      10 => 'ÉS UN QUART MENYS CINC',
      15 => 'ÉS UN QUART',
      20 => 'ÉS UN QUART I CINC',
      25 => 'SÓN DOS QUARTS MENYS CINC',
      30 => 'SÓN DOS QUARTS',
      35 => 'SÓN DOS QUARTS I CINC',
      40 => 'SÓN TRES QUARTS MENYS CINC',
      45 => 'SÓN TRES QUARTS',
      50 => 'SÓN TRES QUARTS I CINC',
      _ => '',
    };

    final link = (dh == 1 || dh == 11)
        ? (useSpaceAfterApostrophe ? "D' " : "D'")
        : "DE ";

    return '$delta $link$exact'.trim().replaceAll('  ', ' ');
  }
}

/// Catalan (CA) Reference implementation.
class ReferenceCatalanTimeToWords extends _BaseCatalanTimeToWords {
  const ReferenceCatalanTimeToWords() : super(useSpaceAfterApostrophe: true);
}

/// Catalan implementation.
/// Fixes the spacing issue in the reference implementation.
class CatalanTimeToWords extends _BaseCatalanTimeToWords {
  const CatalanTimeToWords() : super(useSpaceAfterApostrophe: false);
}
