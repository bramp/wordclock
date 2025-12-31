import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/time_to_words.dart';

void main() {
  group('TimeToWords', () {
    test('10:00 is IT IS TEN OCLOCK', () {
      final time = DateTime(2023, 1, 1, 10, 0);
      final words = TimeToWords.convert(time);
      expect(words, "IT IS TEN OCLOCK");
    });

    test('10:05 is IT IS FIVE PAST TEN', () {
      final time = DateTime(2023, 1, 1, 10, 5);
      final words = TimeToWords.convert(time);
      expect(words, "IT IS FIVE PAST TEN");
    });

    test('10:15 is IT IS QUARTER PAST TEN', () {
      final time = DateTime(2023, 1, 1, 10, 15);
      final words = TimeToWords.convert(time);
      expect(words, "IT IS QUARTER PAST TEN");
    });

    test('10:30 is IT IS HALF PAST TEN', () {
      final time = DateTime(2023, 1, 1, 10, 30);
      final words = TimeToWords.convert(time);
      expect(words, "IT IS HALF PAST TEN");
    });

    test('10:35 is IT IS TWENTY FIVE TO ELEVEN', () {
      final time = DateTime(2023, 1, 1, 10, 35);
      final words = TimeToWords.convert(time);
      expect(words, "IT IS TWENTY FIVE TO ELEVEN");
    });

    test('10:45 is IT IS QUARTER TO ELEVEN', () {
      final time = DateTime(2023, 1, 1, 10, 45);
      final words = TimeToWords.convert(time);
      expect(words, "IT IS QUARTER TO ELEVEN");
    });

    test('10:55 is IT IS FIVE TO ELEVEN', () {
      final time = DateTime(2023, 1, 1, 10, 55);
      final words = TimeToWords.convert(time);
      expect(words, "IT IS FIVE TO ELEVEN");
    });

    test('12:00 is TWELVE OCLOCK', () {
      final time = DateTime(2023, 1, 1, 12, 0);
      final words = TimeToWords.convert(time);
      expect(words, "IT IS TWELVE OCLOCK");
    });
    
    test('00:00 is TWELVE OCLOCK', () {
       final time = DateTime(2023, 1, 1, 0, 0);
       final words = TimeToWords.convert(time);
       expect(words, "IT IS TWELVE OCLOCK");
    });

    test('Rounding: 10:02 -> 10:00', () {
      final time = DateTime(2023, 1, 1, 10, 2);
      final words = TimeToWords.convert(time);
      expect(words, "IT IS TEN OCLOCK");
    });

    test('Rounding: 10:03 -> 10:00', () {
      final time = DateTime(2023, 1, 1, 10, 3);
      final words = TimeToWords.convert(time);
      // Floor(3) = 0 -> Ten OClock
      expect(words, "IT IS TEN OCLOCK");
    });
    
    test('Rounding: 10:58 -> 10:55', () {
      final time = DateTime(2023, 1, 1, 10, 58);
      final words = TimeToWords.convert(time);
      // Floor(58) = 55 -> Five To Eleven
      expect(words, "IT IS FIVE TO ELEVEN");
    });
  });
}
