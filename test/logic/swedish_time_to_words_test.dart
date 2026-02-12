import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/languages/natural/swedish_time_to_words.dart';

void main() {
  group('ReferenceSwedishTimeToWords', () {
    const converter = ReferenceSwedishTimeToWords();

    test('10:00 is KLOCKAN ÄR TIO', () {
      final time = DateTime(2023, 1, 1, 10, 0);
      expect(converter.convert(time), "KLOCKAN ÄR TIO");
    });

    test('10:08 uses ÄTTA in reference', () {
      final time = DateTime(2023, 1, 1, 10, 8); // Rounds to 10:05
      expect(converter.convert(time), "KLOCKAN ÄR FEM ÖVER TIO");

      final time8 = DateTime(2023, 1, 1, 8, 0);
      expect(converter.convert(time8), "KLOCKAN ÄR ÄTTA");
    });
  });

  group('SwedishTimeToWords', () {
    const converter = SwedishTimeToWords();

    test('10:00 is KLOCKAN ÄR TIO', () {
      final time = DateTime(2023, 1, 1, 10, 0);
      expect(converter.convert(time), "KLOCKAN ÄR TIO");
    });

    test('10:05 is KLOCKAN ÄR FEM ÖVER TIO', () {
      final time = DateTime(2023, 1, 1, 10, 5);
      expect(converter.convert(time), "KLOCKAN ÄR FEM ÖVER TIO");
    });

    test('10:25 is KLOCKAN ÄR FEM I HALV ELVA', () {
      final time = DateTime(2023, 1, 1, 10, 25);
      expect(converter.convert(time), "KLOCKAN ÄR FEM I HALV ELVA");
    });

    test('10:30 is KLOCKAN ÄR HALV ELVA', () {
      final time = DateTime(2023, 1, 1, 10, 30);
      expect(converter.convert(time), "KLOCKAN ÄR HALV ELVA");
    });

    test('08:00 uses ÅTTA in standard', () {
      final time = DateTime(2023, 1, 1, 8, 0);
      expect(converter.convert(time), "KLOCKAN ÄR ÅTTA");
    });
  });
}
