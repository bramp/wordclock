import 'package:wordclock/logic/time_to_words.dart';

class DutchTimeToWords implements TimeToWords {
  static const hours = [
    'TWAALF', // Twelve
    'ÉÉN', // One
    'TWEE', // Two
    'DRIE', // Three
    'VIER', // Four
    'VIJF', // Five
    'ZES', // Six
    'ZEVEN', // Seven
    'ACHT', // Eight
    'NEGEN', // Nine
    'TIEN', // Ten
    'ELF', // Eleven
  ];

  static const minutes = {
    5: 'VIJF', // Five
    10: 'TIEN', // Ten
    20: 'TWINTIG', // Twenty
    25: 'VIJF', // Used in "5 before half"
  };

  @override
  String convert(DateTime time) {
    int h = time.hour;
    int m = (time.minute ~/ 5) * 5; // Round down to nearest 5

    int displayHour = h % 12;
    int nextHour = (displayHour + 1) % 12;

    return switch (m) {
      0 => 'HET IS ${hours[displayHour]} UUR', // X o'clock
      15 => 'HET IS KWART OVER ${hours[displayHour]}', // Quarter after
      30 => 'HET IS HALF ${hours[nextHour]}', // Half to (lit: "half X")
      45 => 'HET IS KWART VOOR ${hours[nextHour]}', // Quarter before
      < 15 => 'HET IS ${minutes[m]} OVER ${hours[displayHour]}', // X after
      < 30 =>
        'HET IS ${minutes[30 - m]} VOOR HALF ${hours[nextHour]}', // X before half
      < 45 =>
        'HET IS ${minutes[m - 30]} OVER HALF ${hours[nextHour]}', // X after half
      _ => 'HET IS ${minutes[60 - m]} VOOR ${hours[nextHour]}', // X before
    };
  }
}
