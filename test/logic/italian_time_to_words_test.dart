import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/italian_time_to_words.dart';

void main() {
  group('ItalianTimeToWords', () {
    const converter = ItalianTimeToWords();

    test('10:00 is SONO LE DIECI', () {
      expect(converter.convert(DateTime(2023, 1, 1, 10, 0)), "SONO LE DIECI");
    });

    test('01:00 is È L’UNA', () {
      expect(converter.convert(DateTime(2023, 1, 1, 1, 0)), "È L’UNA");
    });

    test('12:00 (Noon) is SONO LE DODICI', () {
      expect(converter.convert(DateTime(2023, 1, 1, 12, 0)), "SONO LE DODICI");
    });

    test('00:00 (Midnight) is SONO LE DODICI', () {
      expect(converter.convert(DateTime(2023, 1, 1, 0, 0)), "SONO LE DODICI");
    });

    test('10:05 is SONO LE DIECI E CINQUE', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 5)),
        "SONO LE DIECI E CINQUE",
      );
    });

    test('10:15 is SONO LE DIECI E UN QUARTO', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 15)),
        "SONO LE DIECI E UN QUARTO",
      );
    });

    test('10:30 is SONO LE DIECI E MEZZA', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 30)),
        "SONO LE DIECI E MEZZA",
      );
    });

    test('10:45 is SONO LE UNDICI MENO UN QUARTO', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 45)),
        "SONO LE UNDICI MENO UN QUARTO",
      );
    });

    test('10:55 is SONO LE UNDICI MENO CINQUE', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 55)),
        "SONO LE UNDICI MENO CINQUE",
      );
    });
  });
}
