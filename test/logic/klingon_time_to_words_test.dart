import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/klingon_time_to_words.dart';

void main() {
  group('KlingonTimeToWords', () {
    test('Standard (xifan) Output', () {
      const converter = KlingonTimeToWords(usePiqad: false);

      // Midnight (12:00)
      expect(converter.convert(DateTime(2023, 1, 1, 0, 0)), 'wazmah caz rep');

      // Noon (12:00)
      expect(converter.convert(DateTime(2023, 1, 1, 12, 0)), 'wazmah caz rep');

      // 1:00
      expect(converter.convert(DateTime(2023, 1, 1, 1, 0)), 'waz rep');

      // 1:01
      expect(converter.convert(DateTime(2023, 1, 1, 1, 1)), 'waz rep waz tup');

      // 1:05
      expect(converter.convert(DateTime(2023, 1, 1, 1, 5)), 'waz rep vag tup');

      // 1:10
      expect(
        converter.convert(DateTime(2023, 1, 1, 1, 10)),
        'waz rep wazmah tup',
      );

      // 1:15
      expect(
        converter.convert(DateTime(2023, 1, 1, 1, 15)),
        'waz rep wazmah vag tup',
      );

      // 1:30
      expect(
        converter.convert(DateTime(2023, 1, 1, 1, 30)),
        'waz rep wejmah tup',
      );

      // 1:45
      expect(
        converter.convert(DateTime(2023, 1, 1, 1, 45)),
        'waz rep loSmah vag tup',
      );

      // 1:59
      expect(
        converter.convert(DateTime(2023, 1, 1, 1, 59)),
        'waz rep vagmah hut tup',
      );
    });

    test('pIqaD Output', () {
      const converter = KlingonTimeToWords(usePiqad: true);

      // Verify basic mapping of "WA' REP"
      // WA' -> \uF8E7\uF8D0\uF8E9
      // SEP (space) -> space
      // REP -> \uF8E1\uF8D4\uF8DE
      // Expected:   (using the PUA chars from the map)

      // Let's rely on checking it contains expected PUA characters
      final result = converter.convert(DateTime(2023, 1, 1, 1, 0));
      expect(result, isNotEmpty);
      expect(result, isNot(contains(RegExp(r'[A-Z]')))); // No Latin letters
      expect(result, contains('\uF8E7')); // W
      expect(result, contains('\uF8D0')); // A
      expect(result, contains('\uF8E9')); // '
    });

    test('Transliteration Logic (indirect)', () {
      // Since we can't easily access _toPiqad, we test via convert.
      // We know that specific numbers map to specific strings.
      // 1 = WA' -> \uF8E7\uF8D0\uF8E9
      // 2 = CHA' -> \uF8D2\uF8D0\uF8E9
      // 3 = WEJ -> \uF8E7\uF8D4\uF8D8
      // 4 = LOS -> \uF8D9\uF8DD\uF8E2
      // 5 = VAGH -> \uF8E6\uF8D0\uF8D5

      const converter = KlingonTimeToWords(usePiqad: true);

      // Test 5 (VAGH)
      // VAGH REP VAGH TUP
      // \uF8E6\uF8D0\uF8D5 ...
      final fiveResult = converter.convert(DateTime(2023, 1, 1, 5, 5));
      expect(fiveResult, contains('\uF8E6\uF8D0\uF8D5')); // VAGH
    });
  });
}
