import 'package:wordclock/logic/time_to_words.dart';

/// Base implementation for Greek language.
abstract class _BaseGreekTimeToWords implements TimeToWords {
  final List<String> hours;
  final Map<int, String> deltas;
  final String intro;

  const _BaseGreekTimeToWords({
    required this.hours,
    required this.deltas,
    required this.intro,
  });

  @override
  String convert(DateTime time) {
    int m = time.minute;
    int h = time.hour;
    m = m - (m % 5);

    if (m >= 35) h++;

    final displayHour = h % 12;
    final exact = hours[displayHour];
    final delta = deltas[m] ?? '';

    return '$intro $exact $delta'.trim().replaceAll('  ', ' ');
  }
}

/// Greek (GR) Reference implementation.
/// Uses some Latin-lookalike characters and legacy orthography.
class ReferenceGreekTimeToWords extends _BaseGreekTimeToWords {
  const ReferenceGreekTimeToWords()
    : super(
        intro: 'H ΩPA EINAI',
        hours: const [
          'ΔΩΔEKA',
          'MIA',
          'ΔYO',
          'TPEIΣ',
          'TEΣΣEPIΣ',
          'ΠENTE',
          'EΞI',
          'EΦTA',
          'OΧTΩ',
          'ENNIA',
          'ΔEKA',
          'ENTEKA',
        ],
        deltas: const {
          5: 'KAI ΠENTE',
          10: 'KAI ΔEKA',
          15: 'KAI TETAPTO',
          20: 'KAI EIKOΣI',
          25: 'KAI EIKOΣI ΠENTE',
          30: 'KAI MIΣH',
          35: 'ΠAPA EIKOΣI ΠENTE',
          40: 'ΠAPA EIKOΣI',
          45: 'ΠAPA TETAPTO',
          50: 'ΠAPA ΔEKA',
          55: 'ΠAPA ΠENTE',
        },
      );
}

/// Greek implementation.
/// Fixes orthography and spelling.
class GreekTimeToWords extends _BaseGreekTimeToWords {
  const GreekTimeToWords()
    : super(
        intro: 'Η ΩΡΑ ΕΙΝΑΙ',
        hours: const [
          'ΔΩΔΕΚΑ',
          'ΜΙΑ',
          'ΔΥΟ',
          'ΤΡΕΙΣ',
          'ΤΕΣΣΕΡΙΣ',
          'ΠΕΝΤΕ',
          'ΕΞΙ',
          'ΕΦΤΑ',
          'ΟΚΤΩ',
          'ΕΝΝΕΑ',
          'ΔΕΚΑ',
          'ΕΝΤΕΚΑ',
        ],
        deltas: const {
          5: 'ΚΑΙ ΠΕΝΤΕ',
          10: 'ΚΑΙ ΔΕΚΑ',
          15: 'ΚΑΙ ΤΕΤΑΡΤΟ',
          20: 'ΚΑΙ ΕΙΚΟΣΙ',
          25: 'ΚΑΙ ΕΙΚΟΣΙ ΠΕΝΤΕ',
          30: 'ΚΑΙ ΜΙΣΗ',
          35: 'ΠΑΡΑ ΕΙΚΟΣΙ ΠΕΝΤΕ',
          40: 'ΠΑΡΑ ΕΙΚΟΣΙ',
          45: 'ΠΑΡΑ ΤΕΤΑΡΤΟ',
          50: 'ΠΑΡΑ ΔΕΚΑ',
          55: 'ΠΑΡΑ ΠΕΝΤΕ',
        },
      );
}
