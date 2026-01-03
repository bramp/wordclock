import 'package:wordclock/logic/time_to_words.dart';

class NativeDutchTimeToWords implements TimeToWords {
  const NativeDutchTimeToWords();
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
      0 => 'HET IS ${hours[displayHour]} UUR', // It is X o'clock
      15 => 'HET IS KWART OVER ${hours[displayHour]}', // Quarter after X
      30 => 'HET IS HALF ${hours[nextHour]}', // Half to Y (lit: "half Y")
      45 => 'HET IS KWART VOOR ${hours[nextHour]}', // Quarter before Y
      < 15 => 'HET IS ${minutes[m]} OVER ${hours[displayHour]}', // X after Y
      < 30 =>
        'HET IS ${minutes[30 - m]} VOOR HALF ${hours[nextHour]}', // X before half Y
      < 45 =>
        'HET IS ${minutes[m - 30]} OVER HALF ${hours[nextHour]}', // X after half Y
      _ => 'HET IS ${minutes[60 - m]} VOOR ${hours[nextHour]}', // X before Y
    };
  }
}

class DutchTimeToWords implements TimeToWords {
  const DutchTimeToWords();
  @override
  String convert(DateTime time) {
    int m = time.minute;
    int h = time.hour;

    // Round down to nearest 5 minutes
    m = m - (m % 5);

    // 1. Conditionals (None for NL)

    // 2. Hour display limit (20 minutes)
    if (m >= 20) {
      h++;
    }

    final displayHour = h % 12;

    String words = 'HET IS';

    // 5. Delta
    String delta = switch (m) {
      0 => ' UUR', // O'clock
      5 => ' VIJF OVER', // Five past
      10 => ' TIEN OVER', // Ten past
      15 => ' KWART OVER', // Quarter past
      20 => ' TIEN VOOR HALF', // Ten before half
      25 => ' VIJF VOOR HALF', // Five before half
      30 => ' HALF', // Half (to)
      35 => ' VIJF OVER HALF', // Five past half
      40 => ' TIEN OVER HALF', // Ten past half
      45 => ' KWART VOOR', // Quarter before
      50 => ' TIEN VOOR', // Ten before
      55 => ' VIJF VOOR', // Five before
      _ => '',
    };

    // 6. Exact hour
    String exact = switch (displayHour) {
      0 => 'TWAALF', // 12
      1 => 'ÉÉN', // 1
      2 => 'TWEE', // 2
      3 => 'DRIE', // 3
      4 => 'VIER', // 4
      5 => 'VIJF', // 5
      6 => 'ZES', // 6
      7 => 'ZEVEN', // 7
      8 => 'ACHT', // 8
      9 => 'NEGEN', // 9
      10 => 'TIEN', // 10
      11 => 'ELF', // 11
      _ => '',
    };

    if (m == 0) {
      // Intro -> Exact -> Delta (UUR)
      words += ' $exact$delta';
    } else {
      // Intro -> Delta -> Exact
      words += '$delta $exact';
    }

    return words.replaceAll('  ', ' ').trim();
  }
}
