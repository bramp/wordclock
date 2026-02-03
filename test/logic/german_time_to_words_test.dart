import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/german_time_to_words.dart';

void main() {
  group('GermanTimeToWords', () {
    const converter = GermanTimeToWords();

    test('10:00 is ES IST ZEHN', () {
      expect(converter.convert(DateTime(2023, 1, 1, 10, 0)), "ES IST ZEHN");
    });

    test('01:00 is ES IST EINS', () {
      expect(converter.convert(DateTime(2023, 1, 1, 1, 0)), "ES IST EINS");
    });

    test('10:05 is ES IST FÜNF NACH ZEHN', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 5)),
        "ES IST FÜNF NACH ZEHN",
      );
    });
  });

  group('ReferenceGermanTimeToWords', () {
    const converter = ReferenceGermanTimeToWords();

    test('10:00 is ES IST ZEHN UHR', () {
      expect(converter.convert(DateTime(2023, 1, 1, 10, 0)), "ES IST ZEHN UHR");
    });

    test('01:00 is ES IST EIN UHR', () {
      expect(converter.convert(DateTime(2023, 1, 1, 1, 0)), "ES IST EIN UHR");
    });
  });

  group('BerneseGermanTimeToWords', () {
    const converter = BerneseGermanTimeToWords();

    test('10:00 is ES ISCH ZÄNI', () {
      expect(converter.convert(DateTime(2023, 1, 1, 10, 0)), "ES ISCH ZÄNI");
    });
  });
}
