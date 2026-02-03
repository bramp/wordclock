import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/chinese_time_to_words.dart';

void main() {
  group('ReferenceChineseSimplifiedTimeToWords', () {
    const converter = ReferenceChineseSimplifiedTimeToWords();

    test('10:00 is 现在 时间 上午 十点', () {
      expect(converter.convert(DateTime(2023, 1, 1, 10, 0)), "现在 时间 上午 十点");
    });

    test('10:30 uses 三十分 in reference', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 30)),
        "现在 时间 上午 十点 三十分",
      );
    });
  });

  group('ChineseSimplifiedTimeToWords', () {
    const converter = ChineseSimplifiedTimeToWords();

    test('10:00 is 现在是 上午 十点 整', () {
      expect(converter.convert(DateTime(2023, 1, 1, 10, 0)), "现在是 上午 十点 整");
    });

    test('10:30 uses 半 in standard', () {
      expect(converter.convert(DateTime(2023, 1, 1, 10, 30)), "现在是 上午 十点 半");
    });

    test('02:00 uses 两点 in standard', () {
      expect(converter.convert(DateTime(2023, 1, 1, 2, 0)), "现在是 凌晨 两点 整");
    });
  });
}
