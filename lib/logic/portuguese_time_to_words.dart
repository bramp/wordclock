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
    if (h == 12 || h == 0) {
      hStr = h == 12 ? 'MEIO DIA' : 'MEIA NOITE';
    }

    return switch (m) {
      0 when h == 12 => 'MEIO DIA', // Noon
      0 when h == 0 => 'MEIA NOITE', // Midnight
      0 => '${displayHour == 1 ? 'É' : 'SÃO'} $hStr HORAS', // It is X hours
      30 =>
        '${(h == 12 || h == 0 || displayHour == 1) ? 'É' : 'SÃO'} $hStr E MEIA', // It is X and half
      < 30 =>
        '${(h == 12 || h == 0 || displayHour == 1) ? 'É' : 'SÃO'} $hStr E ${minutes[m]}', // It is X and Y minutes
      _ =>
        '${minutes[60 - m]} PARA ${nextHour == 0
            ? 'A MEIA NOITE'
            : nextHour == 12
            ? 'O MEIO DIA'
            : 'AS ${hours[nextHour]}'}', // X minutes to Y
    };
  }
}
