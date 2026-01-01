import 'package:wordclock/logic/time_to_words.dart';

class FrenchTimeToWords implements TimeToWords {
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
      30 => 'IL EST ${hLabel(displayHour)} ET DEMIE', // And half
      45 =>
        'IL EST ${hLabel(nextDisplayHour)} MOINS LE QUART', // Minus the quarter
      < 30 => 'IL EST ${hLabel(displayHour)} ${minutes[m]}',
      _ =>
        'IL EST ${hLabel(nextDisplayHour)} MOINS ${minutes[60 - m]}', // MOINS = minus
    };
  }
}
