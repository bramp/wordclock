import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/languages/natural/french_time_to_words.dart';

void main() {
  group('FrenchTimeToWords', () {
    const converter = FrenchTimeToWords();

    test('10:00 is IL EST DIX HEURES', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 0)),
        "IL EST DIX HEURES",
      );
    });

    test('01:00 is IL EST UNE HEURE', () {
      expect(converter.convert(DateTime(2023, 1, 1, 1, 0)), "IL EST UNE HEURE");
    });

    test('12:00 (Noon) is IL EST MIDI', () {
      expect(converter.convert(DateTime(2023, 1, 1, 12, 0)), "IL EST MIDI");
    });

    test('00:00 (Midnight) is IL EST MINUIT', () {
      expect(converter.convert(DateTime(2023, 1, 1, 0, 0)), "IL EST MINUIT");
    });

    test('10:05 is IL EST DIX HEURES CINQ', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 5)),
        "IL EST DIX HEURES CINQ",
      );
    });

    test('10:15 is IL EST DIX HEURES ET QUART', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 15)),
        "IL EST DIX HEURES ET QUART",
      );
    });

    test('10:30 is IL EST DIX HEURES ET DEMIE', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 30)),
        "IL EST DIX HEURES ET DEMIE",
      );
    });

    test('12:30 (Noon) is IL EST MIDI ET DEMI', () {
      // Masculine DEMI for Midi
      expect(
        converter.convert(DateTime(2023, 1, 1, 12, 30)),
        "IL EST MIDI ET DEMI",
      );
    });

    test('00:30 (Midnight) is IL EST MINUIT ET DEMI', () {
      // Masculine DEMI for Minuit
      expect(
        converter.convert(DateTime(2023, 1, 1, 0, 30)),
        "IL EST MINUIT ET DEMI",
      );
    });

    test('10:45 is IL EST ONZE HEURES MOINS LE QUART', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 45)),
        "IL EST ONZE HEURES MOINS LE QUART",
      );
    });

    test('10:55 is IL EST ONZE HEURES MOINS CINQ', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 55)),
        "IL EST ONZE HEURES MOINS CINQ",
      );
    });
  });
}
