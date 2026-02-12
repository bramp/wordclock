import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/languages/natural/greek_time_to_words.dart';

void main() {
  group('ReferenceGreekTimeToWords', () {
    const converter = ReferenceGreekTimeToWords();

    test('10:00 is H ΩPA EINAI ΔEKA', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 0)),
        "H ΩPA EINAI ΔEKA",
      );
    });

    test('10:30 is H ΩPA EINAI ΔEKA KAI MIΣH', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 30)),
        "H ΩPA EINAI ΔEKA KAI MIΣH",
      );
    });
  });

  group('GreekTimeToWords', () {
    const converter = GreekTimeToWords();

    test('10:00 is Η ΩΡΑ ΕΙΝΑΙ ΔΕΚΑ', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 0)),
        "Η ΩΡΑ ΕΙΝΑΙ ΔΕΚΑ",
      );
    });

    test('10:45 is Η ΩΡΑ ΕΙΝΑΙ ΕΝΤΕΚΑ ΠΑΡΑ ΤΕΤΑΡΤΟ', () {
      expect(
        converter.convert(DateTime(2023, 1, 1, 10, 45)),
        "Η ΩΡΑ ΕΙΝΑΙ ΕΝΤΕΚΑ ΠΑΡΑ ΤΕΤΑΡΤΟ",
      );
    });
  });
}
