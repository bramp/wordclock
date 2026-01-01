import 'package:wordclock/logic/time_to_words.dart';

class PortugueseTimeToWords implements TimeToWords {
  static const hours = [
    'DOZE', // Twelve
    'UMA', // One
    'DUAS', // Two
    'TRÊS', // Three
    'QUATRO', // Four
    'CINCO', // Five
    'SEIS', // Six
    'SETE', // Seven
    'OITO', // Eight
    'NOVE', // Nine
    'DEZ', // Ten
    'ONZE', // Eleven
  ];

  static const minutes = {
    5: 'CINCO', // Five
    10: 'DEZ', // Ten
    15: 'QUINZE', // Fifteen
    20: 'VINTE', // Twenty
    25: 'VINTE E CINCO', // Twenty-five
  };

  @override
  String convert(DateTime time) {
    int h = time.hour;
    int m = (time.minute ~/ 5) * 5; // Round down to nearest 5

    int displayHour = h % 12;
    int nextHour = (displayHour + 1) % 12;

    String hStr = hours[displayHour];
    String nextHStr = hours[nextHour];

    return switch (m) {
      0 when h == 12 => 'MEIO DIA', // Noon
      0 when h == 0 => 'MEIA NOITE', // Midnight
      0 => '${displayHour == 1 ? 'É' : 'SÃO'} $hStr HORAS', // X hours
      30 => '${displayHour == 1 ? 'É' : 'SÃO'} $hStr E MEIA', // And half
      < 30 =>
        '${displayHour == 1 ? 'É' : 'SÃO'} $hStr E ${minutes[m]}', // "E" = and
      _ =>
        '${minutes[60 - m]} PARA AS $nextHStr', // "PARA AS" = "to the" (lit: "X for the Y")
    };
  }
}
