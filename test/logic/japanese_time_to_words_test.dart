import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/japanese_time_to_words.dart';

void main() {
  group('JapaneseTimeToWords', () {
    final converter = JapaneseTimeToWords();

    test('10:00 is 午前 十 時', () {
      final time = DateTime(2023, 1, 1, 10, 0);
      expect(converter.convert(time), "午前 十 時");
    });

    test('22:00 is 午後 十 時', () {
      final time = DateTime(2023, 1, 1, 22, 0);
      expect(converter.convert(time), "午後 十 時");
    });

    test('10:05 is 午前 十 時 五 分', () {
      final time = DateTime(2023, 1, 1, 10, 5);
      expect(converter.convert(time), "午前 十 時 五 分");
    });

    test('10:15 is 午前 十 時 十 五 分', () {
      final time = DateTime(2023, 1, 1, 10, 15);
      expect(converter.convert(time), "午前 十 時 十 五 分");
    });

    test('10:30 is 午前 十 時 半', () {
      final time = DateTime(2023, 1, 1, 10, 30);
      expect(converter.convert(time), "午前 十 時 半");
    });

    test('10:45 is 午前 十 時 四 十 五 分', () {
      final time = DateTime(2023, 1, 1, 10, 45);
      expect(converter.convert(time), "午前 十 時 四 十 五 分");
    });

    test('10:59 is 午前 十 時 五 十 九 分', () {
      final time = DateTime(2023, 1, 1, 10, 59);
      expect(converter.convert(time), "午前 十 時 五 十 九 分");
    });

    test('Precision: 10:01 is 午前 十 時 一 分', () {
      final time = DateTime(2023, 1, 1, 10, 1);
      expect(converter.convert(time), "午前 十 時 一 分");
    });
  });
}
