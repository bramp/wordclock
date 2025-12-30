import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/time_to_words.dart';
import 'package:wordclock/model/word_type.dart';

void main() {
  group('TimeToWords', () {
    test('10:00 is IT IS TEN OCLOCK', () {
      final time = DateTime(2023, 1, 1, 10, 0);
      final words = TimeToWords.convert(time);
      expect(words, containsAll([WordType.it, WordType.isVerb, WordType.ten, WordType.oclock]));
      expect(words, isNot(contains(WordType.past)));
      expect(words, isNot(contains(WordType.to)));
    });

    test('10:05 is IT IS FIVE PAST TEN', () {
      final time = DateTime(2023, 1, 1, 10, 5);
      final words = TimeToWords.convert(time);
      expect(words, containsAll([WordType.it, WordType.isVerb, WordType.fiveMinutes, WordType.past, WordType.ten]));
      expect(words, isNot(contains(WordType.oclock)));
    });

    test('10:15 is IT IS QUARTER PAST TEN', () {
      final time = DateTime(2023, 1, 1, 10, 15);
      final words = TimeToWords.convert(time);
      expect(words, containsAll([WordType.it, WordType.isVerb, WordType.quarter, WordType.past, WordType.ten]));
    });

    test('10:30 is IT IS HALF PAST TEN', () {
      final time = DateTime(2023, 1, 1, 10, 30);
      final words = TimeToWords.convert(time);
      expect(words, containsAll([WordType.it, WordType.isVerb, WordType.half, WordType.past, WordType.ten]));
    });

    test('10:35 is IT IS TWENTY FIVE TO ELEVEN', () {
      final time = DateTime(2023, 1, 1, 10, 35);
      final words = TimeToWords.convert(time);
      expect(words, containsAll([WordType.it, WordType.isVerb, WordType.twenty, WordType.fiveMinutes, WordType.to, WordType.eleven]));
      expect(words, isNot(contains(WordType.ten)));
    });

    test('10:45 is IT IS QUARTER TO ELEVEN', () {
      final time = DateTime(2023, 1, 1, 10, 45);
      final words = TimeToWords.convert(time);
      expect(words, containsAll([WordType.it, WordType.isVerb, WordType.quarter, WordType.to, WordType.eleven]));
    });

    test('10:55 is IT IS FIVE TO ELEVEN', () {
      final time = DateTime(2023, 1, 1, 10, 55);
      final words = TimeToWords.convert(time);
      expect(words, containsAll([WordType.it, WordType.isVerb, WordType.fiveMinutes, WordType.to, WordType.eleven]));
    });

    test('12:00 is TWELVE OCLOCK', () {
      final time = DateTime(2023, 1, 1, 12, 0);
      final words = TimeToWords.convert(time);
      expect(words, containsAll([WordType.twelve, WordType.oclock]));
    });
    
    test('00:00 is TWELVE OCLOCK', () {
       final time = DateTime(2023, 1, 1, 0, 0);
       final words = TimeToWords.convert(time);
       expect(words, containsAll([WordType.twelve, WordType.oclock]));
    });

    test('Rounding: 10:02 -> 10:00', () {
      final time = DateTime(2023, 1, 1, 10, 2);
      final words = TimeToWords.convert(time);
      expect(words, containsAll([WordType.ten, WordType.oclock]));
      expect(words, isNot(contains(WordType.fiveMinutes)));
    });

    test('Rounding: 10:03 -> 10:00', () {
      final time = DateTime(2023, 1, 1, 10, 3);
      final words = TimeToWords.convert(time);
      // Floor(3) = 0 -> Ten OClock
      expect(words, containsAll([WordType.ten, WordType.oclock]));
    });
    
    test('Rounding: 10:58 -> 10:55', () {
      final time = DateTime(2023, 1, 1, 10, 58);
      final words = TimeToWords.convert(time);
      // Floor(58) = 55 -> Five To Eleven
      expect(words, containsAll([WordType.fiveMinutes, WordType.to, WordType.eleven]));
    });
  });
}
