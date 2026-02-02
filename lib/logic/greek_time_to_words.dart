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
/// - Correcting number spellings.
/// - Using "ΕΙΝΑΙ" to save grid space.
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

    const intro = 'Η ΩΡΑ ΕΙΝΑΙ'; // The time is

    if (m == 0) return '$intro ${hourWords[displayHour]}';

    // Logic: Intro -> Hour -> [Connector] -> Minute
    // This order (Hour first) avoids cycles in the grid graph.
    // Example: "Five (Hour) minus Ten (Minute)" -> Hour->PARA->Minute.

    String delta = '';

    if (m <= 30) {
      // Past: Hour KAI Minute
      delta = switch (m) {
        5 => ' ΚΑΙ ΠΕΝΤΕ',
        10 => ' ΚΑΙ ΔΕΚΑ',
        15 => ' ΚΑΙ ΤΕΤΑΡΤΟ',
        20 => ' ΚΑΙ ΕΙΚΟΣΙ',
        25 => ' ΚΑΙ ΕΙΚΟΣΙ ΠΕΝΤΕ',
        30 => ' ΚΑΙ ΜΙΣΗ',
        _ => '',
      };
    } else {
      // To: Hour PARA Minute
      // (Reverted to Reference order to solve grid cycle issues)
      delta = switch (m) {
        35 => ' ΠΑΡΑ ΕΙΚΟΣΙ ΠΕΝΤΕ',
        40 => ' ΠΑΡΑ ΕΙΚΟΣΙ',
        45 => ' ΠΑΡΑ ΤΕΤΑΡΤΟ',
        50 => ' ΠΑΡΑ ΔΕΚΑ',
        55 => ' ΠΑΡΑ ΠΕΝΤΕ',
        _ => '',
      };
    }

    return '$intro ${hourWords[displayHour]}$delta';
  }
}
