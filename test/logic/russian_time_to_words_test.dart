import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/russian_time_to_words.dart';

void main() {
  group('RussianTimeToWords', () {
    final converter = RussianTimeToWords();

    test('10:00 is СЕЙЧАС ДЕСЯТЬ ЧАСОВ', () {
      final time = DateTime(2023, 1, 1, 10, 0);
      expect(converter.convert(time), "СЕЙЧАС ДЕСЯТЬ ЧАСОВ");
    });

    test('01:00 is СЕЙЧАС ЧАС', () {
      final time = DateTime(2023, 1, 1, 1, 0);
      expect(converter.convert(time), "СЕЙЧАС ЧАС");
    });

    test('02:00 is СЕЙЧАС ДВА ЧАСА', () {
      final time = DateTime(2023, 1, 1, 2, 0);
      expect(converter.convert(time), "СЕЙЧАС ДВА ЧАСА");
    });

    test('10:05 is ДЕСЯТЬ ЧАСОВ ПЯТЬ МИНУТ', () {
      final time = DateTime(2023, 1, 1, 10, 5);
      expect(converter.convert(time), "ДЕСЯТЬ ЧАСОВ ПЯТЬ МИНУТ");
    });

    test('10:30 is ДЕСЯТЬ ЧАСОВ ПОЛОВИНА', () {
      final time = DateTime(2023, 1, 1, 10, 30);
      expect(converter.convert(time), "ДЕСЯТЬ ЧАСОВ ПОЛОВИНА");
    });

    test('10:45 is ДЕСЯТЬ ЧАСОВ СОРОК ПЯТЬ МИНУТ', () {
      final time = DateTime(2023, 1, 1, 10, 45);
      expect(converter.convert(time), "ДЕСЯТЬ ЧАСОВ СОРОК ПЯТЬ МИНУТ");
    });
  });
}
