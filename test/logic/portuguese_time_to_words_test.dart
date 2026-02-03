import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/portuguese_time_to_words.dart';

void main() {
  group('ReferencePortugueseTimeToWords', () {
    const converter = ReferencePortugueseTimeToWords();

    test('12:00 is É MEIO DIA', () {
      final time = DateTime(2023, 1, 1, 12, 0);
      expect(converter.convert(time), "É MEIO DIA");
    });

    test('10:15 is SÃO DEZ E UM QUARTO', () {
      final time = DateTime(2023, 1, 1, 10, 15);
      expect(converter.convert(time), "SÃO DEZ E UM QUARTO");
    });
  });

  group('PortugueseTimeToWords', () {
    const converter = PortugueseTimeToWords();

    test('10:00 is SÃO DEZ HORAS', () {
      final time = DateTime(2023, 1, 1, 10, 0);
      expect(converter.convert(time), "SÃO DEZ HORAS");
    });

    test('01:00 is É UMA HORA', () {
      final time = DateTime(2023, 1, 1, 1, 0);
      expect(converter.convert(time), "É UMA HORA");
    });

    test('12:00 (Noon) is É MEIO-DIA', () {
      final time = DateTime(2023, 1, 1, 12, 0);
      expect(converter.convert(time), "É MEIO-DIA");
    });

    test('00:00 (Midnight) is É MEIA-NOITE', () {
      final time = DateTime(2023, 1, 1, 0, 0);
      expect(converter.convert(time), "É MEIA-NOITE");
    });

    test('10:05 is SÃO DEZ E CINCO', () {
      final time = DateTime(2023, 1, 1, 10, 5);
      expect(converter.convert(time), "SÃO DEZ E CINCO");
    });

    test('10:15 is SÃO DEZ E QUARTO', () {
      final time = DateTime(2023, 1, 1, 10, 15);
      expect(converter.convert(time), "SÃO DEZ E QUARTO");
    });

    test('10:30 is SÃO DEZ E MEIA', () {
      final time = DateTime(2023, 1, 1, 10, 30);
      expect(converter.convert(time), "SÃO DEZ E MEIA");
    });

    test('10:55 is SÃO ONZE MENOS CINCO', () {
      final time = DateTime(2023, 1, 1, 10, 55);
      expect(converter.convert(time), "SÃO ONZE MENOS CINCO");
    });

    test('12:30 is É MEIO-DIA E MEIA', () {
      final time = DateTime(2023, 1, 1, 12, 30);
      expect(converter.convert(time), "É MEIO-DIA E MEIA");
    });
  });
}
