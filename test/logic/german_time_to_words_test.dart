import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/german_time_to_word.dart';

void main() {
  group('NativeGermanTimeToWords', () {
    const converter = NativeGermanTimeToWords();

    test('10:00 is ES IST ZEHN UHR', () {
      expect(converter.convert(DateTime(2023, 1, 1, 10, 0)), "ES IST ZEHN UHR");
    });

    test('01:00 is ES IST EIN UHR', () {
      expect(converter.convert(DateTime(2023, 1, 1, 1, 0)), "ES IST EIN UHR");
    });

    // ... (keep existing individual tests if desired, or rely on fixtures)
    test('10:05 is ES IST FÜNF NACH ZEHN', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 5)),
        "ES IST FÜNF NACH ZEHN",
      );
    });

    test('10:15 is ES IST VIERTEL NACH ZEHN', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 15)),
        "ES IST VIERTEL NACH ZEHN",
      );
    });

    test('10:25 is ES IST FÜNF VOR HALB ELF', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 25)),
        "ES IST FÜNF VOR HALB ELF",
      );
    });

    test('10:30 is ES IST HALB ELF', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 30)),
        "ES IST HALB ELF",
      );
    });

    test('10:35 is ES IST FÜNF NACH HALB ELF', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 35)),
        "ES IST FÜNF NACH HALB ELF",
      );
    });

    test('10:45 is ES IST VIERTEL VOR ELF', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 45)),
        "ES IST VIERTEL VOR ELF",
      );
    });

    test('10:55 is ES IST FÜNF VOR ELF', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 55)),
        "ES IST FÜNF VOR ELF",
      );
    });
  });
}
