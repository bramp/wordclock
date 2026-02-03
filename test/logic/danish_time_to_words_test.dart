import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/danish_time_to_words.dart';

void main() {
  group('ReferenceDanishTimeToWords', () {
    const converter = ReferenceDanishTimeToWords();

    test('10:00 is KLOKKEN ER TI', () {
      expect(converter.convert(DateTime(2023, 1, 1, 10, 0)), "KLOKKEN ER TI");
    });

    test('10:05 is KLOKKEN ER FEM MINUTTER OVER TI', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 5)),
        "KLOKKEN ER FEM MINUTTER OVER TI",
      );
    });
  });

  group('DanishTimeToWords', () {
    const converter = DanishTimeToWords();

    test('10:05 is KLOKKEN ER FEM OVER TI', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 5)),
        "KLOKKEN ER FEM OVER TI",
      );
    });

    test('10:25 is KLOKKEN ER FEM I HALV ELLEVE', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 25)),
        "KLOKKEN ER FEM I HALV ELLEVE",
      );
    });
  });
}
