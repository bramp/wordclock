import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/czech_time_to_words.dart';

void main() {
  group('ReferenceCzechTimeToWords', () {
    const converter = ReferenceCzechTimeToWords();

    test('10:00 is JE DESET', () {
      expect(converter.convert(DateTime(2023, 1, 1, 10, 0)), "JE DESET");
    });

    test('02:00 is JSOU DVĚ', () {
      expect(converter.convert(DateTime(2023, 1, 1, 2, 0)), "JSOU DVĚ");
    });

    test('10:05 is JE DESET NULA PĚT', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 5)),
        "JE DESET NULA PĚT",
      );
    });
  });

  group('CzechTimeToWords', () {
    const converter = CzechTimeToWords();

    test('02:00 is JE DVĚ', () {
      expect(converter.convert(DateTime(2023, 1, 1, 2, 0)), "JE DVĚ");
    });

    test('10:05 is JE DESET PĚT', () {
      expect(converter.convert(DateTime(2023, 1, 1, 10, 5)), "JE DESET PĚT");
    });
  });
}
