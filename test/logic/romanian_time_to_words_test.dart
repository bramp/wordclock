import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/romanian_time_to_words.dart';

void main() {
  group('ReferenceRomanianTimeToWords', () {
    const converter = ReferenceRomanianTimeToWords();

    test('12:00 is ESTE ORA DOUĂ SPRE ZECE', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 12, 0)),
        "ESTE ORA DOUĂ SPRE ZECE",
      );
    });

    test('10:30 is ESTE ORA ZECE ŞI TREIZECI', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 30)),
        "ESTE ORA ZECE ŞI TREIZECI",
      );
    });
  });

  group('RomanianTimeToWords', () {
    const converter = RomanianTimeToWords();

    test('12:00 is ESTE ORA DOUĂSPREZECE', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 12, 0)),
        "ESTE ORA DOUĂSPREZECE",
      );
    });

    test('10:30 is ESTE ORA ZECE ŞI JUMĂTATE', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 30)),
        "ESTE ORA ZECE ŞI JUMĂTATE",
      );
    });
  });
}
