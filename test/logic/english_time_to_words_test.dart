import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/languages/natural/english_time_to_words.dart';

void main() {
  group('EnglishTimeToWords', () {
    const converter = EnglishTimeToWords();

    test("10:00 is IT IS TEN O’CLOCK", () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 0)),
        "IT IS TEN O’CLOCK",
      );
    });

    test('10:05 is IT IS FIVE PAST TEN', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 5)),
        "IT IS FIVE PAST TEN",
      );
    });

    test('10:15 is IT IS QUARTER PAST TEN', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 15)),
        "IT IS QUARTER PAST TEN",
      );
    });

    test('10:30 is IT IS HALF PAST TEN', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 30)),
        "IT IS HALF PAST TEN",
      );
    });

    test('10:35 is IT IS TWENTY FIVE TO ELEVEN', () {
      // Native uses "TWENTY FIVE" (Space)
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 35)),
        "IT IS TWENTY FIVE TO ELEVEN",
      );
    });

    test('10:45 is IT IS QUARTER TO ELEVEN', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 45)),
        "IT IS QUARTER TO ELEVEN",
      );
    });

    test("12:00 is IT IS TWELVE O’CLOCK", () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 12, 0)),
        "IT IS TWELVE O’CLOCK",
      );
    });

    test("Rounding: 10:02 -> 10:00 (TEN O’CLOCK)", () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 2)),
        "IT IS TEN O’CLOCK",
      );
    });

    test('Rounding: 10:58 -> 10:55 (FIVE TO ELEVEN)', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 58)),
        "IT IS FIVE TO ELEVEN",
      );
    });
  });

  group('ReferenceEnglishTimeToWords', () {
    test('standard behavior (TWENTYFIVE)', () {
      const converter = ReferenceEnglishTimeToWords(
        useSpaceInTwentyFive: false,
      );
      final time = DateTime(2024, 1, 1, 12, 25);
      expect(converter.convert(time), equals('IT IS TWENTYFIVE PAST TWELVE'));
    });

    test('new behavior (TWENTY FIVE)', () {
      const converter = ReferenceEnglishTimeToWords(useSpaceInTwentyFive: true);
      final time = DateTime(2024, 1, 1, 12, 25);
      expect(converter.convert(time), equals('IT IS TWENTY FIVE PAST TWELVE'));
    });

    test('twenty five to (new behavior)', () {
      const converter = ReferenceEnglishTimeToWords(useSpaceInTwentyFive: true);
      final time = DateTime(2024, 1, 1, 12, 35);
      expect(converter.convert(time), equals('IT IS TWENTY FIVE TO ONE'));
    });
  });

  group('ReferenceEnglishAlternativeTimeToWords', () {
    test('new behavior (TWENTY FIVE)', () {
      const converter = ReferenceEnglishAlternativeTimeToWords(
        useSpaceInTwentyFive: true,
      );
      final time = DateTime(2024, 1, 1, 12, 25);
      expect(converter.convert(time), equals('IT IS TWENTY FIVE PAST TWELVE'));
    });
  });
}
