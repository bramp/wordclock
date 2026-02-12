import 'package:wordclock/logic/time_to_words.dart';

/// Base implementation for Portuguese language.
abstract class _BasePortugueseTimeToWords implements TimeToWords {
  final bool useHyphens;
  final bool useUmQuarto;
  final bool useMeiaHoraForNoon;

  const _BasePortugueseTimeToWords({
    this.useHyphens = false,
    this.useUmQuarto = true,
    this.useMeiaHoraForNoon = false,
  });

  String getHour(int hour24) {
    if (hour24 == 0) return 'É MEIA${useHyphens ? '-' : ' '}NOITE';
    if (hour24 == 12) return 'É MEIO${useHyphens ? '-' : ' '}DIA';

    final h12 = hour24 % 12;
    final prefix = h12 == 1 ? 'É' : 'SÃO';
    final name = switch (h12) {
      0 => 'DOZE',
      1 => 'UMA',
      2 => 'DUAS',
      3 => 'TRÊS',
      4 => 'QUATRO',
      5 => 'CINCO',
      6 => 'SEIS',
      7 => 'SETE',
      8 => 'OITO',
      9 => 'NOVE',
      10 => 'DEZ',
      11 => 'ONZE',
      _ => '',
    };
    return '$prefix $name';
  }

  String getDelta(int minute) => switch (minute) {
    5 => 'E CINCO',
    10 => 'E DEZ',
    15 => useUmQuarto ? 'E UM QUARTO' : 'E QUARTO',
    20 => 'E VINTE',
    25 => 'E VINTE E CINCO',
    30 => 'E MEIA',
    35 => 'MENOS VINTE E CINCO',
    40 => 'MENOS VINTE',
    45 => useUmQuarto ? 'MENOS UM QUARTO' : 'MENOS QUARTO',
    50 => 'MENOS DEZ',
    55 => 'MENOS CINCO',
    _ => '',
  };

  @override
  String convert(DateTime time) {
    int m = time.minute;
    int h = time.hour;

    // Round down to nearest 5 minutes
    m = m - (m % 5);

    // Special case for Reference: 12:30 -> É MEIA HORA
    if (useMeiaHoraForNoon && h % 24 == 12 && m == 30) {
      return 'É MEIA HORA';
    }

    // Rollover hour if minutes >= 35
    if (m >= 35) {
      h++;
    }

    final h24 = h % 24;
    final exact = getHour(h24);
    final delta = getDelta(m);

    String words = exact;

    // Append HORA/HORAS for exact hours (except noon/midnight)
    if (m == 0 && h24 != 0 && h24 != 12) {
      final h12 = h24 % 12;
      words += (h12 == 1) ? ' HORA' : ' HORAS';
    }

    if (delta.isNotEmpty) {
      words += ' $delta';
    }

    return words.replaceAll('  ', ' ').trim();
  }
}

/// Standard Portuguese (PE) Reference implementation.
class ReferencePortugueseTimeToWords extends _BasePortugueseTimeToWords {
  const ReferencePortugueseTimeToWords()
    : super(useHyphens: false, useUmQuarto: true, useMeiaHoraForNoon: true);
}

/// Portuguese implementation.
class PortugueseTimeToWords extends _BasePortugueseTimeToWords {
  const PortugueseTimeToWords()
    : super(useHyphens: true, useUmQuarto: false, useMeiaHoraForNoon: false);
}
