import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/russian_time_to_words.dart';

void main() {
  group('RussianTimeToWords', () {
    final converter = RussianTimeToWords();

    test('10:00 is ДЕСЯТЬ', () {
      final time = DateTime(2023, 1, 1, 10, 0);
      expect(converter.convert(time), "ДЕСЯТЬ");
    });

    test('01:00 is ЧАС', () {
      final time = DateTime(2023, 1, 1, 1, 0);
      expect(converter.convert(time), "ЧАС");
    });

    test('02:00 is ДВА', () {
      final time = DateTime(2023, 1, 1, 2, 0);
      expect(converter.convert(time), "ДВА");
    });

    test('10:05 is ПЯТЬ ОДИННАДЦАТОГО', () {
      final time = DateTime(2023, 1, 1, 10, 5);
      expect(converter.convert(time), "ПЯТЬ ОДИННАДЦАТОГО");
    });

    test('10:30 is ПОЛ ОДИННАДЦАТОГО', () {
      final time = DateTime(2023, 1, 1, 10, 30);
      expect(converter.convert(time), "ПОЛ ОДИННАДЦАТОГО");
    });

    test('10:45 is БЕЗ ЧЕТВЕРТИ ОДИННАДЦАТЬ', () {
      final time = DateTime(2023, 1, 1, 10, 45);
      expect(converter.convert(time), "БЕЗ ЧЕТВЕРТИ ОДИННАДЦАТЬ");
    });
  });
}
