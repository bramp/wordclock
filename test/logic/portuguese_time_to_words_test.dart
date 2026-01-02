import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/portuguese_time_to_words.dart';

void main() {
  group('NativePortugueseTimeToWords', () {
    final converter = NativePortugueseTimeToWords();

    test('10:00 is SÃO DEZ HORAS', () {
      final time = DateTime(2023, 1, 1, 10, 0);
      expect(converter.convert(time), "SÃO DEZ HORAS");
    });

    test('01:00 is É UMA HORAS', () {
      final time = DateTime(2023, 1, 1, 1, 0);
      expect(converter.convert(time), "É UMA HORAS");
    });

    test('12:00 (Noon) is MEIO DIA', () {
      final time = DateTime(2023, 1, 1, 12, 0);
      expect(converter.convert(time), "MEIO DIA");
    });

    test('00:00 (Midnight) is MEIA NOITE', () {
      final time = DateTime(2023, 1, 1, 0, 0);
      expect(converter.convert(time), "MEIA NOITE");
    });

    test('10:05 is SÃO DEZ E CINCO', () {
      final time = DateTime(2023, 1, 1, 10, 5);
      expect(converter.convert(time), "SÃO DEZ E CINCO");
    });

    test('10:15 is SÃO DEZ E QUINZE', () {
      final time = DateTime(2023, 1, 1, 10, 15);
      expect(converter.convert(time), "SÃO DEZ E QUINZE");
    });

    test('10:30 is SÃO DEZ E MEIA', () {
      final time = DateTime(2023, 1, 1, 10, 30);
      expect(converter.convert(time), "SÃO DEZ E MEIA");
    });

    test('10:55 is CINCO PARA AS ONZE', () {
      final time = DateTime(2023, 1, 1, 10, 55);
      expect(converter.convert(time), "CINCO PARA AS ONZE");
    });

    test('01:50 is DEZ PARA AS DUAS', () {
      final time = DateTime(2023, 1, 1, 1, 50);
      expect(converter.convert(time), "DEZ PARA AS DUAS");
    });
  });
}
