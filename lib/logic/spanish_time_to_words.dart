import 'package:wordclock/logic/time_to_words.dart';

class SpanishTimeToWords implements TimeToWords {
  static const hours = [
    'DOCE', // Twelve
    'UNA', // One
    'DOS', // Two
    'TRES', // Three
    'CUATRO', // Four
    'CINCO', // Five
    'SEIS', // Six
    'SIETE', // Seven
    'OCHO', // Eight
    'NUEVE', // Nine
    'DIEZ', // Ten
    'ONCE', // Eleven
  ];

  static const minutes = {
    5: 'CINCO', // Five
    10: 'DIEZ', // Ten
    15: 'CUARTO', // Quarter
    20: 'VEINTE', // Twenty
    25: 'VEINTICINCO', // Twenty-five
    30: 'MEDIA', // Half
  };

  @override
  String convert(DateTime time) {
    int h = time.hour;
    int m = (time.minute ~/ 5) * 5; // Round down to nearest 5

    int displayHour = h % 12;
    int nextHour = (displayHour + 1) % 12;

    return switch (m) {
      0 when h == 12 => 'ES MEDIODÍA', // It is noon
      0 when h == 0 => 'ES MEDIANOCHE', // It is midnight
      0 => '${displayHour == 1 ? 'ES LA' : 'SON LAS'} ${hours[displayHour]}',
      <= 30 =>
        '${displayHour == 1 ? 'ES LA' : 'SON LAS'} ${hours[displayHour]} Y ${minutes[m]}', // "Y" = and
      _ =>
        '${nextHour == 1 ? 'ES LA' : 'SON LAS'} ${hours[nextHour]} MENOS ${minutes[60 - m]}', // "MENOS" = minus
    };
  }
}
