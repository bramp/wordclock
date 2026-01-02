import 'package:wordclock/logic/time_to_words.dart';

class CzechTimeToWords implements TimeToWords {
  @override
  String convert(DateTime time) {
    int m = (time.minute ~/ 5) * 5;
    int h = time.hour % 12;

    String exact = switch (h) {
      0 => 'DVANÁCT', // 12
      1 => 'JEDNA', // 1
      2 => 'DVĚ', // 2
      3 => 'TŘI', // 3
      4 => 'ČTYŘI', // 4
      5 => 'PĚT', // 5
      6 => 'ŠEST', // 6
      7 => 'SEDM', // 7
      8 => 'OSM', // 8
      9 => 'DEVĚT', // 9
      10 => 'DESET', // 10
      11 => 'JEDENÁCT', // 11
      _ => '',
    };

    String intro = switch (h) {
      0 || 5 || 6 || 7 || 8 || 9 || 10 || 11 => 'JE', // It is (singular-ish)
      1 => 'JE', // It is
      2 || 3 || 4 => 'JSOU', // They are
      _ => '',
    };

    String delta = switch (m) {
      0 => '',
      5 => 'NULA PĚT', // Zero five
      10 => 'DESET', // Ten
      15 => 'PATNÁCT', // Fifteen
      20 => 'DVACET', // Twenty
      25 => 'DVACET PĚT', // Twenty-five
      30 => 'TŘICET', // Thirty
      35 => 'TŘICET PĚT', // Thirty-five
      40 => 'ČTYŘICET', // Forty
      45 => 'ČTYŘICET PĚT', // Forty-five
      50 => 'PADESÁT', // Fifty
      55 => 'PADESÁT PĚT', // Fifty-five
      _ => '',
    };

    return '$intro $exact $delta'.replaceAll('  ', ' ').trim();
  }
}
