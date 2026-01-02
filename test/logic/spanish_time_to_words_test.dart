import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/spanish_time_to_words.dart';

void main() {
  group('NativeSpanishTimeToWords', () {
    final converter = NativeSpanishTimeToWords();

    test('10:00 is SON LAS DIEZ', () {
      final time = DateTime(2023, 1, 1, 10, 0);
      expect(converter.convert(time), "SON LAS DIEZ");
    });

    test('01:00 is ES LA UNA', () {
      final time = DateTime(2023, 1, 1, 1, 0);
      expect(converter.convert(time), "ES LA UNA");
    });

    test('12:00 (Noon) is ES MEDIODÍA', () {
      final time = DateTime(2023, 1, 1, 12, 0);
      expect(converter.convert(time), "ES MEDIODÍA");
    });

    test('00:00 (Midnight) is ES MEDIANOCHE', () {
      final time = DateTime(2023, 1, 1, 0, 0);
      expect(converter.convert(time), "ES MEDIANOCHE");
    });

    test('10:05 is SON LAS DIEZ Y CINCO', () {
      final time = DateTime(2023, 1, 1, 10, 5);
      expect(converter.convert(time), "SON LAS DIEZ Y CINCO");
    });

    test('01:15 is ES LA UNA Y CUARTO', () {
      final time = DateTime(2023, 1, 1, 1, 15);
      expect(converter.convert(time), "ES LA UNA Y CUARTO");
    });

    test('10:30 is SON LAS DIEZ Y MEDIA', () {
      final time = DateTime(2023, 1, 1, 10, 30);
      expect(converter.convert(time), "SON LAS DIEZ Y MEDIA");
    });

    test('10:45 is SON LAS ONCE MENOS CUARTO', () {
      final time = DateTime(2023, 1, 1, 10, 45);
      expect(converter.convert(time), "SON LAS ONCE MENOS CUARTO");
    });

    test('01:55 is SON LAS DOS MENOS CINCO', () {
      final time = DateTime(2023, 1, 1, 1, 55);
      expect(converter.convert(time), "SON LAS DOS MENOS CINCO");
    });

    test('Rounding: 10:04 -> 10:00', () {
      final time = DateTime(2023, 1, 1, 10, 4);
      expect(converter.convert(time), "SON LAS DIEZ");
    });
  });
}
