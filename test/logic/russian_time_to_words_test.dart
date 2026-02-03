import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/russian_time_to_words.dart';

void main() {
  group('ReferenceRussianTimeToWords', () {
    const converter = ReferenceRussianTimeToWords();

    test('10:00 is ДЕ СЯТЬ ЧАСОВ', () {
      expect(converter.convert(DateTime(2023, 1, 1, 10, 0)), "ДЕ СЯТЬ ЧАСОВ");
    });

    test('04:00 is ЧЕ ТЫ РЕ ЧАСА', () {
      expect(converter.convert(DateTime(2023, 1, 1, 4, 0)), "ЧЕ ТЫ РЕ ЧАСА");
    });
  });

  group('RussianTimeToWords', () {
    const converter = RussianTimeToWords();

    test('10:00 is ДЕСЯТЬ ЧАСОВ', () {
      expect(converter.convert(DateTime(2023, 1, 1, 10, 0)), "ДЕСЯТЬ ЧАСОВ");
    });

    test('04:00 is ЧЕТЫРЕ ЧАСА', () {
      expect(converter.convert(DateTime(2023, 1, 1, 4, 0)), "ЧЕТЫРЕ ЧАСА");
    });

    test('12:15 is ДВЕНАДЦАТЬ ЧАСОВ ПЯТНАДЦАТЬ МИНУТ', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 12, 15)),
        "ДВЕНАДЦАТЬ ЧАСОВ ПЯТНАДЦАТЬ МИНУТ",
      );
    });
  });
}
