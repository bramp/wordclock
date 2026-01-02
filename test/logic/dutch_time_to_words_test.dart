import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/dutch_time_to_words.dart';

void main() {
  group('NativeDutchTimeToWords', () {
    final converter = NativeDutchTimeToWords();

    test('10:00 is HET IS TIEN UUR', () {
      final time = DateTime(2023, 1, 1, 10, 0);
      expect(converter.convert(time), "HET IS TIEN UUR");
    });

    test('10:05 is HET IS VIJF OVER TIEN', () {
      final time = DateTime(2023, 1, 1, 10, 5);
      expect(converter.convert(time), "HET IS VIJF OVER TIEN");
    });

    test('10:15 is HET IS KWART OVER TIEN', () {
      final time = DateTime(2023, 1, 1, 10, 15);
      expect(converter.convert(time), "HET IS KWART OVER TIEN");
    });

    test('10:20 is HET IS TIEN VOOR HALF ELF', () {
      final time = DateTime(2023, 1, 1, 10, 20);
      expect(converter.convert(time), "HET IS TIEN VOOR HALF ELF");
    });

    test('10:25 is HET IS VIJF VOOR HALF ELF', () {
      final time = DateTime(2023, 1, 1, 10, 25);
      expect(converter.convert(time), "HET IS VIJF VOOR HALF ELF");
    });

    test('10:30 is HET IS HALF ELF', () {
      final time = DateTime(2023, 1, 1, 10, 30);
      expect(converter.convert(time), "HET IS HALF ELF");
    });

    test('10:35 is HET IS VIJF OVER HALF ELF', () {
      final time = DateTime(2023, 1, 1, 10, 35);
      expect(converter.convert(time), "HET IS VIJF OVER HALF ELF");
    });

    test('10:45 is HET IS KWART VOOR ELF', () {
      final time = DateTime(2023, 1, 1, 10, 45);
      expect(converter.convert(time), "HET IS KWART VOOR ELF");
    });

    test('10:55 is HET IS VIJF VOOR ELF', () {
      final time = DateTime(2023, 1, 1, 10, 55);
      expect(converter.convert(time), "HET IS VIJF VOOR ELF");
    });
  });
}
