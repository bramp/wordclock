import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/dutch_time_to_words.dart';

void main() {
  group('DutchTimeToWords', () {
    const converter = DutchTimeToWords();

    test('10:00 is HET IS TIEN UUR', () {
      expect(converter.convert(DateTime(2023, 1, 1, 10, 0)), "HET IS TIEN UUR");
    });

    test('10:05 is HET IS VIJF OVER TIEN', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 5)),
        "HET IS VIJF OVER TIEN",
      );
    });

    test('10:15 is HET IS KWART OVER TIEN', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 15)),
        "HET IS KWART OVER TIEN",
      );
    });

    test('10:20 is HET IS TIEN VOOR HALF ELF', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 20)),
        "HET IS TIEN VOOR HALF ELF",
      );
    });

    test('10:25 is HET IS VIJF VOOR HALF ELF', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 25)),
        "HET IS VIJF VOOR HALF ELF",
      );
    });

    test('10:30 is HET IS HALF ELF', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 30)),
        "HET IS HALF ELF",
      );
    });

    test('10:35 is HET IS VIJF OVER HALF ELF', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 35)),
        "HET IS VIJF OVER HALF ELF",
      );
    });

    test('10:45 is HET IS KWART VOOR ELF', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 45)),
        "HET IS KWART VOOR ELF",
      );
    });

    test('10:55 is HET IS VIJF VOOR ELF', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 55)),
        "HET IS VIJF VOOR ELF",
      );
    });
  });
}
