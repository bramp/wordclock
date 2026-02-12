import 'package:wordclock/logic/time_to_words.dart';

class TamilTimeToWords implements TimeToWords {
  @override
  String convert(DateTime time) {
    int h = time.hour;
    int m = time.minute;

    // Round to nearest 5
    m = m - (m % 5);

    // Convert to 12-hour format
    h = h > 12 ? h - 12 : h;
    if (h == 0) h = 12;

    String hourWord = _getHourWord(h);
    String minuteWord = _getMinuteWord(m);

    // Handle O'clock
    if (m == 0) {
      // e.g. "ஐந்து மணி" (Five Hour)
      return '$hourWord மணி';
    }

    // Standard colloquial: "X Hour Y Minute" -> "X Y"
    // e.g. "ஐந்து பத்து" (Five Ten)
    // Removing "Nimidam" (Minute) saves significant space and is commonly understood.
    // Retaining "Mani" only for O'clock.

    return '$hourWord $minuteWord';
  }

  String _getHourWord(int h) => switch (h) {
    1 => 'ஒரு', // Oru (adjective form commonly used with Mani)
    2 => 'இரண்டு',
    3 => 'மூன்று',
    4 => 'நான்கு',
    5 => 'ஐந்து',
    6 => 'ஆறு',
    7 => 'ஏழு',
    8 => 'எட்டு',
    9 => 'ஒன்பது',
    10 => 'பத்து',
    11 => 'பதினொன்று',
    12 => 'பன்னிரண்டு',
    _ => '',
  };

  String _getMinuteWord(int m) => switch (m) {
    5 => 'ஐந்து',
    10 => 'பத்து',
    15 => 'பதினைந்து',
    20 => 'இருபது',
    25 => 'இருபது ஐந்து', // Simplified from இருபத்து for grid compactness
    30 => 'முப்பது',
    35 => 'முப்பது ஐந்து', // Simplified from முப்பத்து
    40 => 'நாற்பது',
    45 => 'நாற்பது ஐந்து', // Simplified from நாற்பத்து
    50 => 'ஐம்பது',
    55 => 'ஐம்பது ஐந்து', // Simplified from ஐம்பத்து
    _ => '',
  };
}
