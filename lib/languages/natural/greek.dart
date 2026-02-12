import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/languages/natural/greek_time_to_words.dart';

final greekLanguage = WordClockLanguage(
  id: 'GR',
  languageCode: 'el-GR',
  displayName: 'Ελληνικά',
  englishName: 'Greek',
  description: null,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-02-01T17:01:56.356869
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 23, Duration: 14ms
    WordClockGrid(
      isDefault: true,
      timeToWords: GreekTimeToWords(),
      paddingAlphabet: 'ΑΔΕΗΙΚΜΝΞΟΠΡΣΤΥΦΩ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ΗΩΩΡΑΑΕΙΝΑΙ' // Η ΩΡΑ ΕΙΝΑΙ
            'ΤΕΣΣΕΡΙΣΜΙΑ' // ΤΕΣΣΕΡΙΣ ΜΙΑ
            'ΔΩΔΕΚΑΤΡΕΙΣ' // ΔΩΔΕΚΑ ΔΕΚΑ ΤΡΕΙΣ
            'ΕΝΤΕΚΑΠΕΝΤΕ' // ΕΝΤΕΚΑ ΠΕΝΤΕ
            'ΑΕΝΝΕΑΜΕΦΤΑ' // ΕΝΝΕΑ ΕΦΤΑ
            'ΟΚΤΩΔΥΟΕΞΙΥ' // ΟΚΤΩ ΔΥΟ ΕΞΙ
            'ΤΕΠΑΡΑΩΑΚΑΙ' // ΠΑΡΑ ΚΑΙ
            'ΤΕΤΑΡΤΟΔΕΚΑ' // ΤΕΤΑΡΤΟ ΔΕΚΑ
            'ΕΙΚΟΣΙΑΜΙΣΗ' // ΕΙΚΟΣΙ ΜΙΣΗ
            'ΥΝΠΗΗΦΠΕΝΤΕ', // ΠΕΝΤΕ
      ),
    ),
    // @generated end,
    WordClockGrid(
      isReference: true,
      timeToWords: ReferenceGreekTimeToWords(),
      paddingAlphabet: 'AEHKPTXΔΧ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'HΧΩPATEINAI'
            'MIAΔYOTPEIΣ'
            'TEΣΣEPIΣEΞI'
            'ΠENTEPOΧTΩH'
            'EΦTAEENTEKA'
            'ΔΩΔEKAENNIA'
            'ΔEKAXΠAPAEP'
            'KAIETETAPTO'
            'EIKOΣIHΔEKA'
            'MIΣHEΠENTEP',
      ),
    ),
  ],
  minuteIncrement: 5,
);
