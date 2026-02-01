import 'package:wordclock/logic/time_to_words.dart';

class ReferenceGreekTimeToWords implements TimeToWords {
  const ReferenceGreekTimeToWords();
  @override
  String convert(DateTime time) {
    int m = time.minute;
    int h = time.hour;
    m = m - (m % 5);

    if (m >= 35) h++;

    final displayHour = h % 12;

    // Intro: 'H ΩPA EINAI' (Latin H, P, A, E, I, N)
    String words = 'H ΩPA EINAI';

    // Exact Hour
    words +=
        " ${switch (displayHour) {
          0 => 'ΔΩΔEKA',
          1 => 'MIA',
          2 => 'ΔYO',
          3 => 'TPEIΣ',
          4 => 'TEΣΣEPIΣ',
          5 => 'ΠENTE',
          6 => 'EΞI',
          7 => 'EΦTA',
          8 => 'OΧTΩ',
          9 => 'ENNIA',
          10 => 'ΔEKA',
          11 => 'ENTEKA',
          _ => '',
        }}";

    // Delta
    words += switch (m) {
      0 => '',
      5 => ' KAI ΠENTE',
      10 => ' KAI ΔEKA',
      15 => ' KAI TETAPTO',
      20 => ' KAI EIKOΣI',
      25 => ' KAI EIKOΣI ΠENTE',
      30 => ' KAI MIΣH',
      35 => ' ΠAPA EIKOΣI ΠENTE',
      40 => ' ΠAPA EIKOΣI',
      45 => ' ΠAPA TETAPTO',
      50 => ' ΠAPA ΔEKA',
      55 => ' ΠAPA ΠENTE',
      _ => '',
    };

    return words.replaceAll('  ', ' ').trim();
  }
}

/// Greek implementation that differs from [ReferenceGreekTimeToWords] by:
/// - Fixing orthography (using Greek letters instead of mixed Latin/Greek).
/// - Correcting number spellings (e.g., "ΟΚΤΩ" instead of "ΟΧΤΩ", "ΕΝΝΕΑ" instead of "ΕΝΝΙΑ").
/// - Flipping the word order for times after 30 minutes (e.g., "ΔΕΚΑ ΠΑΡΑ ΜΙΑ" instead of "ΜΙΑ ΠΑΡΑ ΔΕΚΑ").
/// - Using "ΕΙΝΑΙ" as a more compact intro instead of "Η ΩΡΑ ΕΙΝΑΙ".
class GreekTimeToWords extends ReferenceGreekTimeToWords {
  const GreekTimeToWords();

  @override
  String convert(DateTime time) {
    int m = time.minute;
    int h = time.hour;
    m = m - (m % 5);

    if (m >= 35) h++;

    final displayHour = h % 12;

    const hourWords = [
      'ΔΩΔΕΚΑ', // 12
      'ΜΙΑ', // 1
      'ΔΥΟ', // 2
      'ΤΡΕΙΣ', // 3
      'ΤΕΣΣΕΡΙΣ', // 4
      'ΠΕΝΤΕ', // 5
      'ΕΞΙ', // 6
      'ΕΦΤΑ', // 7
      'ΟΚΤΩ', // 8
      'ΕΝΝΕΑ', // 9
      'ΔΕΚΑ', // 10
      'ΕΝΤΕΚΑ', // 11
    ];

    const intro = 'ΕΙΝΑΙ'; // It is

    if (m == 0) return '$intro ${hourWords[displayHour]}';

    if (m <= 30) {
      final delta = switch (m) {
        5 => 'ΚΑΙ ΠΕΝΤΕ', // and five
        10 => 'ΚΑΙ ΔΕΚΑ', // and ten
        15 => 'ΚΑΙ ΤΕΤΑΡΤΟ', // and a quarter
        20 => 'ΚΑΙ ΕΙΚΟΣΙ', // and twenty
        25 => 'ΚΑΙ ΕΙΚΟΣΙ ΠΕΝΤΕ', // and twenty-five
        30 => 'ΚΑΙ ΜΙΣΗ', // and half
        _ => '',
      };
      return '$intro ${hourWords[displayHour]} $delta';
    } else {
      final delta = switch (m) {
        35 => 'ΕΙΚΟΣΙ ΠΕΝΤΕ ΠΑΡΑ', // twenty-five until
        40 => 'ΕΙΚΟΣΙ ΠΑΡΑ', // twenty until
        45 => 'ΤΕΤΑΡΤΟ ΠΑΡΑ', // a quarter until
        50 => 'ΔΕΚΑ ΠΑΡΑ', // ten until
        55 => 'ΠΕΝΤΕ ΠΑΡΑ', // five until
        _ => '',
      };
      return '$intro $delta ${hourWords[displayHour]}';
    }
  }
}
