import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/french_time_to_words.dart';

void main() {
  group('FrenchTimeToWords', () {
    final converter = FrenchTimeToWords();

    test('10:00 is IL EST DIX HEURES', () {
      final time = DateTime(2023, 1, 1, 10, 0);
      expect(converter.convert(time), "IL EST DIX HEURES");
    });

    test('01:00 is IL EST UNE HEURE', () {
      final time = DateTime(2023, 1, 1, 1, 0);
      expect(converter.convert(time), "IL EST UNE HEURE");
    });

    test('12:00 (Noon) is IL EST MIDI', () {
      final time = DateTime(2023, 1, 1, 12, 0);
      expect(converter.convert(time), "IL EST MIDI");
    });

    test('00:00 (Midnight) is IL EST MINUIT', () {
      final time = DateTime(2023, 1, 1, 0, 0);
      expect(converter.convert(time), "IL EST MINUIT");
    });

    test('10:05 is IL EST DIX HEURES CINQ', () {
      final time = DateTime(2023, 1, 1, 10, 5);
      expect(converter.convert(time), "IL EST DIX HEURES CINQ");
    });

    test('10:15 is IL EST DIX HEURES ET QUART', () {
      final time = DateTime(2023, 1, 1, 10, 15);
      expect(converter.convert(time), "IL EST DIX HEURES ET QUART");
    });

    test('10:30 is IL EST DIX HEURES ET DEMIE', () {
      final time = DateTime(2023, 1, 1, 10, 30);
      expect(converter.convert(time), "IL EST DIX HEURES ET DEMIE");
    });

    test('10:45 is IL EST ONZE HEURES MOINS LE QUART', () {
      final time = DateTime(2023, 1, 1, 10, 45);
      expect(converter.convert(time), "IL EST ONZE HEURES MOINS LE QUART");
    });

    test('10:55 is IL EST ONZE HEURES MOINS CINQ', () {
      final time = DateTime(2023, 1, 1, 10, 55);
      expect(converter.convert(time), "IL EST ONZE HEURES MOINS CINQ");
    });
  });
}
