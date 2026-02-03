import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/spanish_time_to_words.dart';

void main() {
  group('SpanishTimeToWords', () {
    const converter = SpanishTimeToWords();

    test('10:00 is SON LAS DIEZ', () {
      expect(converter.convert(DateTime(2023, 1, 1, 10, 0)), "SON LAS DIEZ");
    });

    test('01:00 is ES LA UNA', () {
      expect(converter.convert(DateTime(2023, 1, 1, 1, 0)), "ES LA UNA");
    });

    test('12:00 (Noon) is SON LAS DOCE', () {
      // Standard implementation uses "SON LAS DOCE" for noon
      expect(converter.convert(DateTime(2023, 1, 1, 12, 0)), "SON LAS DOCE");
    });

    test('00:00 (Midnight) is SON LAS DOCE', () {
      // Standard implementation uses "SON LAS DOCE" for midnight
      expect(converter.convert(DateTime(2023, 1, 1, 0, 0)), "SON LAS DOCE");
    });

    test('10:30 is SON LAS DIEZ Y MEDIA', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 30)),
        "SON LAS DIEZ Y MEDIA",
      );
    });

    test('10:45 is SON LAS ONCE MENOS CUARTO', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 45)),
        "SON LAS ONCE MENOS CUARTO",
      );
    });
  });
}
