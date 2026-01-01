import 'package:wordclock/logic/time_to_words.dart';

class GermanTimeToWords implements TimeToWords {
  static const hours = [
    'ZWÖLF', // Twelve
    'EINS', // One
    'ZWEI', // Two
    'DREI', // Three
    'VIER', // Four
    'FÜNF', // Five
    'SECHS', // Six
    'SIEBEN', // Seven
    'ACHT', // Eight
    'NEUN', // Nine
    'ZEHN', // Ten
    'ELF', // Eleven
  ];

  static const minutes = {
    5: 'FÜNF', // Five
    10: 'ZEHN', // Ten
    15: 'VIERTEL', // Quarter
    20: 'ZWANZIG', // Twenty
    25: 'FÜNF', // Used in "5 before half"
  };

  @override
  String convert(DateTime time) {
    int h = time.hour;
    int m = (time.minute ~/ 5) * 5; // Round down to nearest 5

    int displayHour = h % 12;
    int nextHour = (displayHour + 1) % 12;

    // "Ein Uhr" instead of "Eins Uhr"
    final hStr = (displayHour == 1 && m == 0) ? 'EIN' : hours[displayHour];

    return switch (m) {
      0 => 'ES IST $hStr UHR', // It is X o'clock
      15 => 'ES IST VIERTEL NACH ${hours[displayHour]}', // Quarter after X
      30 => 'ES IST HALB ${hours[nextHour]}', // Half to Y (lit: "half Y")
      45 => 'ES IST VIERTEL VOR ${hours[nextHour]}', // Quarter before Y
      < 20 => 'ES IST ${minutes[m]} NACH ${hours[displayHour]}', // X after Y
      < 30 =>
        'ES IST ${minutes[30 - m]} VOR HALB ${hours[nextHour]}', // X before half Y
      < 40 =>
        'ES IST ${minutes[m - 30]} NACH HALB ${hours[nextHour]}', // X after half Y
      _ => 'ES IST ${minutes[60 - m]} VOR ${hours[nextHour]}', // X before Y
    };
  }
}
