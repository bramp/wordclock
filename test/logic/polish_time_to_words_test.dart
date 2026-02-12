import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/languages/natural/polish_time_to_words.dart';

void main() {
  group('ReferencePolishTimeToWords', () {
    const converter = ReferencePolishTimeToWords();

    test('12:00 is DWUN AST A', () {
      expect(converter.convert(DateTime(2023, 1, 1, 12, 0)), "DWUN AST A");
    });

    test('10:10 is DZIESI ĄT A DZIESI ĘĆ', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 10)),
        "DZIESI ĄT A DZIESI ĘĆ",
      );
    });
  });

  group('PolishTimeToWords', () {
    const converter = PolishTimeToWords();

    test('12:00 is DWUNASTA', () {
      expect(converter.convert(DateTime(2023, 1, 1, 12, 0)), "DWUNASTA");
    });

    test('10:10 is DZIESIĄTA DZIESIĘĆ', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 10)),
        "DZIESIĄTA DZIESIĘĆ",
      );
    });
  });
}
