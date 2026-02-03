import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/norwegian_time_to_words.dart';

void main() {
  group('ReferenceNorwegianTimeToWords', () {
    const converter = ReferenceNorwegianTimeToWords();

    test('10:00 uses Tl in reference', () {
      final time = DateTime(2023, 1, 1, 10, 0);
      expect(converter.convert(time), "KLOKKEN ER Tl");
    });

    test('04:00 uses FlRE in reference', () {
      final time = DateTime(2023, 1, 1, 4, 0);
      expect(converter.convert(time), "KLOKKEN ER FlRE");
    });
  });

  group('NorwegianTimeToWords', () {
    const converter = NorwegianTimeToWords();

    test('10:00 is KLOKKEN ER TI', () {
      final time = DateTime(2023, 1, 1, 10, 0);
      expect(converter.convert(time), "KLOKKEN ER TI");
    });

    test('10:10 is KLOKKEN ER TI OVER TI', () {
      final time = DateTime(2023, 1, 1, 10, 10);
      expect(converter.convert(time), "KLOKKEN ER TI OVER TI");
    });

    test('10:20 is KLOKKEN ER TI PÅ HALV ELVA', () {
      final time = DateTime(2023, 1, 1, 10, 20);
      expect(converter.convert(time), "KLOKKEN ER TI PÅ HALV ELLEVE");
    });

    test('10:30 is KLOKKEN ER HALV ELVA', () {
      final time = DateTime(2023, 1, 1, 10, 30);
      expect(converter.convert(time), "KLOKKEN ER HALV ELLEVE");
    });

    test('04:00 is KLOKKEN ER FIRE', () {
      final time = DateTime(2023, 1, 1, 4, 0);
      expect(converter.convert(time), "KLOKKEN ER FIRE");
    });
  });
}
