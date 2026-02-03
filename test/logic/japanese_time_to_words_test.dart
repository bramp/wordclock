import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/japanese_time_to_words.dart';

void main() {
  group('ReferenceJapaneseTimeToWords', () {
    const converter = ReferenceJapaneseTimeToWords();

    test('10:00 is 現在の時刻は 十時 です', () {
      expect(converter.convert(DateTime(2023, 1, 1, 10, 0)), "現在の時刻は 十時 です");
    });

    test('10:30 is 現在の時刻は 十時半 です', () {
      expect(converter.convert(DateTime(2023, 1, 1, 10, 30)), "現在の時刻は 十時半 です");
    });

    test('10:45 is 現在の時刻は 十一時 まで あと 十五分 です', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 45)),
        "現在の時刻は 十一時 まで あと 十五分 です",
      );
    });
  });

  group('JapaneseTimeToWords', () {
    const converter = JapaneseTimeToWords();

    test('10:00 is ただいま 十時 です', () {
      expect(converter.convert(DateTime(2023, 1, 1, 10, 0)), "ただいま 十時 です");
    });

    test('00:00 is ただいま 零時 です', () {
      expect(converter.convert(DateTime(2023, 1, 1, 0, 0)), "ただいま 零時 です");
    });

    test('10:45 is 十一時 まで あと 十五分 です', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 45)),
        "十一時 まで あと 十五分 です",
      );
    });
  });
}
