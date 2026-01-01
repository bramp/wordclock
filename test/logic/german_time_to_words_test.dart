import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/german_time_to_words.dart';

void main() {
  group('GermanTimeToWords', () {
    final converter = GermanTimeToWords();

    test('10:00 is ES IST ZEHN UHR', () {
      final time = DateTime(2023, 1, 1, 10, 0);
      expect(converter.convert(time), "ES IST ZEHN UHR");
    });

    test('01:00 is ES IST EIN UHR', () {
      final time = DateTime(2023, 1, 1, 1, 0);
      expect(converter.convert(time), "ES IST EIN UHR");
    });

    test('10:05 is ES IST FÜNF NACH ZEHN', () {
      final time = DateTime(2023, 1, 1, 10, 5);
      expect(converter.convert(time), "ES IST FÜNF NACH ZEHN");
    });

    test('10:15 is ES IST VIERTEL NACH ZEHN', () {
      final time = DateTime(2023, 1, 1, 10, 15);
      expect(converter.convert(time), "ES IST VIERTEL NACH ZEHN");
    });

    test('10:25 is ES IST FÜNF VOR HALB ELF', () {
      final time = DateTime(2023, 1, 1, 10, 25);
      expect(converter.convert(time), "ES IST FÜNF VOR HALB ELF");
    });

    test('10:30 is ES IST HALB ELF', () {
      final time = DateTime(2023, 1, 1, 10, 30);
      expect(converter.convert(time), "ES IST HALB ELF");
    });

    test('10:35 is ES IST FÜNF NACH HALB ELF', () {
      final time = DateTime(2023, 1, 1, 10, 35);
      expect(converter.convert(time), "ES IST FÜNF NACH HALB ELF");
    });

    test('10:45 is ES IST VIERTEL VOR ELF', () {
      final time = DateTime(2023, 1, 1, 10, 45);
      expect(converter.convert(time), "ES IST VIERTEL VOR ELF");
    });

    test('10:55 is ES IST FÜNF VOR ELF', () {
      final time = DateTime(2023, 1, 1, 10, 55);
      expect(converter.convert(time), "ES IST FÜNF VOR ELF");
    });
  });
}
