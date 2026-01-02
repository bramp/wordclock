import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/english_time_to_word.dart';

void main() {
  group('NativeEnglishTimeToWords', () {
    const converter = NativeEnglishTimeToWords();

    test('10:00 is IT IS TEN OCLOCK', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 0)),
        "IT IS TEN OCLOCK",
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

    test('12:00 is IT IS TWELVE OCLOCK', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 12, 0)),
        "IT IS TWELVE OCLOCK",
      );
    });

    test('Rounding: 10:02 -> 10:00 (TEN OCLOCK)', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 2)),
        "IT IS TEN OCLOCK",
      );
    });

    test('Rounding: 10:58 -> 10:55 (FIVE TO ELEVEN)', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 58)),
        "IT IS FIVE TO ELEVEN",
      );
    });
  });
}
