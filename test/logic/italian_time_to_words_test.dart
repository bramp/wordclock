import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/italian_time_to_words.dart';

void main() {
  group('NativeItalianTimeToWords', () {
    final converter = NativeItalianTimeToWords();

    test('10:00 is SONO LE DIECI', () {
      final time = DateTime(2023, 1, 1, 10, 0);
      expect(converter.convert(time), "SONO LE DIECI");
    });

    test('01:00 is È L\'UNA', () {
      final time = DateTime(2023, 1, 1, 1, 0);
      expect(converter.convert(time), "È L'UNA");
    });

    test('12:00 (Noon) is È MEZZOGIORNO', () {
      final time = DateTime(2023, 1, 1, 12, 0);
      expect(converter.convert(time), "È MEZZOGIORNO");
    });

    test('00:00 (Midnight) is È MEZZANOTTE', () {
      final time = DateTime(2023, 1, 1, 0, 0);
      expect(converter.convert(time), "È MEZZANOTTE");
    });

    test('10:05 is SONO LE DIECI E CINQUE', () {
      final time = DateTime(2023, 1, 1, 10, 5);
      expect(converter.convert(time), "SONO LE DIECI E CINQUE");
    });

    test('10:15 is SONO LE DIECI E UN QUARTO', () {
      final time = DateTime(2023, 1, 1, 10, 15);
      expect(converter.convert(time), "SONO LE DIECI E UN QUARTO");
    });

    test('10:30 is SONO LE DIECI E MEZZA', () {
      final time = DateTime(2023, 1, 1, 10, 30);
      expect(converter.convert(time), "SONO LE DIECI E MEZZA");
    });

    test('10:45 is SONO LE UNDICI MENO UN QUARTO', () {
      final time = DateTime(2023, 1, 1, 10, 45);
      expect(converter.convert(time), "SONO LE UNDICI MENO UN QUARTO");
    });

    test('10:55 is SONO LE UNDICI MENO CINQUE', () {
      final time = DateTime(2023, 1, 1, 10, 55);
      expect(converter.convert(time), "SONO LE UNDICI MENO CINQUE");
    });
  });
}
