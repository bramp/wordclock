import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/catalan_time_to_words.dart';

void main() {
  group('ReferenceCatalanTimeToWords', () {
    const converter = ReferenceCatalanTimeToWords();

    test('10:00 is SÓN LES DEU', () {
      expect(converter.convert(DateTime(2023, 1, 1, 10, 0)), "SÓN LES DEU");
    });

    test('01:00 is ÉS LA UNA', () {
      expect(converter.convert(DateTime(2023, 1, 1, 1, 0)), "ÉS LA UNA");
    });

    test('10:05 is SÓN LES DEU I CINC', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 5)),
        "SÓN LES DEU I CINC",
      );
    });

    test('10:15 is ÉS UN QUART D\' ONZE', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 15)),
        "ÉS UN QUART D' ONZE",
      );
    });

    test('10:30 is SÓN DOS QUARTS D\' ONZE', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 30)),
        "SÓN DOS QUARTS D' ONZE",
      );
    });

    test('10:45 is SÓN TRES QUARTS D\' ONZE', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 45)),
        "SÓN TRES QUARTS D' ONZE",
      );
    });

    test('10:55 is SÓN LES ONZE MENYS CINC', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 55)),
        "SÓN LES ONZE MENYS CINC",
      );
    });
  });

  group('CatalanTimeToWords', () {
    const converter = CatalanTimeToWords();

    test('10:15 is ÉS UN QUART D\'ONZE', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 15)),
        "ÉS UN QUART D'ONZE",
      );
    });

    test('10:55 is SÓN LES ONZE MENYS CINC', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 55)),
        "SÓN LES ONZE MENYS CINC",
      );
    });
  });
}
