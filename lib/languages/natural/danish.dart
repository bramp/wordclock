import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/languages/natural/danish_time_to_words.dart';

final danishLanguage = WordClockLanguage(
  id: 'DK',
  languageCode: 'da-DK',
  displayName: 'Dansk',
  englishName: 'Danish',
  description: null,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-01-31T21:51:08.867352
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 23, Duration: 5ms
    WordClockGrid(
      isDefault: true,
      timeToWords: DanishTimeToWords(),
      paddingAlphabet: 'AEIJKLMNOPRSTV',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'KLOKKENPERL' // KLOKKEN ER
            'MKVARTSHALV' // KVART HALV
            'IJTYVEIPFEM' // TYVE FEM
            'EJPRTIMINOI' // TI I
            'NOVERSIHALV' // OVER HALV
            'ELLEVEOTTET' // ELLEVE OTTE ET
            'ETOLVSLFIRE' // TOLV TO FIRE
            'MSTIVAIIFEM' // FEM
            'SEKSTRESYVK' // SEKS TRE SYV
            'AKKRRRTIMNI', // TI NI
      ),
    ),
    // @generated end,
    WordClockGrid(
      isReference: true,
      timeToWords: ReferenceDanishTimeToWords(),
      paddingAlphabet: 'AEIJKLMNOPRSTV',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'KLOKKENVERO'
            'FEMTYVESKAM'
            'OJEKVARTVAT'
            'TIAMINUTTER'
            'VEMOVERILPM'
            'MONALISHALV'
            'ETTOTREFIRE'
            'FEMSEKSRSYV'
            'OTTERNIMETI'
            'ELLEVEATOLV',
      ),
    ),
  ],
  minuteIncrement: 5,
);
