import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/turkish_time_to_words.dart';

void main() {
  group('ReferenceTurkishTimeToWords', () {
    const converter = ReferenceTurkishTimeToWords();

    test('10:00 is SAAT ON', () {
      expect(converter.convert(DateTime(2023, 1, 1, 10, 0)), "SAAT ON");
    });

    test('10:30 is SAAT ON BUÇUK', () {
      expect(converter.convert(DateTime(2023, 1, 1, 10, 30)), "SAAT ON BUÇUK");
    });

    test('10:05 uses SEKIZ spelling and GEÇİYOR', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 5)),
        "SAAT ONU BEŞ GEÇİYOR",
      );
    });

    test('08:00 uses SEKIZ in reference', () {
      expect(converter.convert(DateTime(2023, 1, 1, 8, 0)), "SAAT SEKIZ");
    });
  });

  group('TurkishTimeToWords', () {
    const converter = TurkishTimeToWords();

    test('10:00 is SAAT ON', () {
      expect(converter.convert(DateTime(2023, 1, 1, 10, 0)), "SAAT ON");
    });

    test('08:00 uses SEKİZ in standard', () {
      expect(converter.convert(DateTime(2023, 1, 1, 8, 0)), "SAAT SEKİZ");
    });

    test('10:05 is SAAT ONU BEŞ GEÇİYOR', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 5)),
        "SAAT ONU BEŞ GEÇİYOR",
      );
    });
  });
}
