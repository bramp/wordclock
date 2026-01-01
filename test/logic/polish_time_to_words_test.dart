import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/polish_time_to_words.dart';

void main() {
  group('PolishTimeToWords', () {
    final converter = PolishTimeToWords();

    test('10:00 is JEST DZIESIĄTA', () {
      final time = DateTime(2023, 1, 1, 10, 0);
      expect(converter.convert(time), "JEST DZIESIĄTA");
    });

    test('10:05 is JEST PIĘĆ PO DZIESIĄTA', () {
      final time = DateTime(2023, 1, 1, 10, 5);
      expect(converter.convert(time), "JEST PIĘĆ PO DZIESIĄTA");
    });

    test('10:15 is JEST KWADRANS PO DZIESIĄTA', () {
      final time = DateTime(2023, 1, 1, 10, 15);
      expect(converter.convert(time), "JEST KWADRANS PO DZIESIĄTA");
    });

    test('10:30 is JEST WPÓŁ DO JEDENASTA', () {
      final time = DateTime(2023, 1, 1, 10, 30);
      expect(converter.convert(time), "JEST WPÓŁ DO JEDENASTA");
    });

    test('10:45 is JEST ZA KWADRANS JEDENASTA', () {
      final time = DateTime(2023, 1, 1, 10, 45);
      expect(converter.convert(time), "JEST ZA KWADRANS JEDENASTA");
    });

    test('10:55 is JEST ZA PIĘĆ JEDENASTA', () {
      final time = DateTime(2023, 1, 1, 10, 55);
      expect(converter.convert(time), "JEST ZA PIĘĆ JEDENASTA");
    });
  });
}
