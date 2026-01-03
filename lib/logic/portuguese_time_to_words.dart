import 'package:wordclock/logic/time_to_words.dart';

class NativePortugueseTimeToWords implements TimeToWords {
  const NativePortugueseTimeToWords();
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

class PortugueseTimeToWords implements TimeToWords {
  const PortugueseTimeToWords();
  @override
  String convert(DateTime time) {
    int m = time.minute;
    int h = time.hour;

    // Round down to nearest 5 minutes
    m = m - (m % 5);

    // 1. Conditionals
    int h24 = h % 24;
    String? conditional = switch (m) {
      0 => switch (h24) {
        1 || 13 => 'É UMA HORA',
        2 => 'SÃO DUAS HORAS',
        3 => 'SÃO TRÊS HORAS',
        4 => 'SÃO QUATRO HORAS',
        5 => 'SÃO CINCO HORAS',
        6 => 'SÃO SEIS HORAS',
        7 => 'SÃO SETE HORAS',
        8 => 'SÃO OITO HORAS',
        9 => 'SÃO NOVE HORAS',
        10 => 'SÃO DEZ HORAS',
        11 => 'SÃO ONZE HORAS',
        _ => null,
      },
      30 when h24 == 12 => 'É MEIA HORA',
      _ => null,
    };
    if (conditional != null) return conditional;

    // 2. Hour display limit (35 minutes)
    if (m >= 35) {
      h++;
    }

    final displayHour = h % 12;

    String words = '';

    // 5. Delta
    String delta = switch (m) {
      5 => 'E CINCO', // And five
      10 => 'E DEZ', // And ten
      15 => 'E UM QUARTO', // And one quarter
      20 => 'E VINTE', // And twenty
      25 => 'E VINTE E CINCO', // And twenty-five
      30 => 'E MEIA', // And half
      35 => 'MENOS VINTE E CINCO', // Minus twenty-five
      40 => 'MENOS VINTE', // Minus twenty
      45 => 'MENOS UM QUARTO', // Minus one quarter
      50 => 'MENOS DEZ', // Minus ten
      55 => 'MENOS CINCO', // Minus five
      _ => '',
    };

    // 6. Exact hour
    String hExact = switch (h % 24) {
      0 => 'É MEIA NOITE', // It is midnight
      12 => 'É MEIO DIA', // It is mid day
      _ => switch (displayHour) {
        1 => 'É UMA', // It is one
        2 => 'SÃO DUAS', // It is two
        3 => 'SÃO TRÊS', // It is three
        4 => 'SÃO QUATRO', // It is four
        5 => 'SÃO CINCO', // It is five
        6 => 'SÃO SEIS', // It is six
        7 => 'SÃO SETE', // It is seven
        8 => 'SÃO OITO', // It is eight
        9 => 'SÃO NOVE', // It is nine
        10 => 'SÃO DEZ', // It is ten
        11 => 'SÃO ONZE', // It is eleven
        _ => '',
      },
    };

    words += hExact;
    if (m == 0 && (h % 24 != 12) && (h % 24 != 0)) {
      // Append HORA/HORAS for exact hours (except noon/midnight)
      int h12 = h % 12;
      if (h12 == 0) h12 = 12;
      if (h12 == 1) {
        words += ' HORA';
      } else {
        words += ' HORAS';
      }
    }
    if (delta.isNotEmpty) words += ' $delta';

    return words.replaceAll('  ', ' ').trim();
  }
}
