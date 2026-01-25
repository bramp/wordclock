import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/danish_time_to_words.dart';

final danishLanguage = WordClockLanguage(
  id: 'DK',
  languageCode: 'da-DK',
  displayName: 'Dansk',
  englishName: 'Danish',
  description: null,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-01-25T09:42:52.180856
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 24, Duration: 3ms
    WordClockGrid(
      isDefault: true,
      timeToWords: DanishTimeToWords(),
      paddingAlphabet: 'AEIJKLMNOPRSTV',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'KLOKKENPERL' // KLOKKEN ER
            'MSIKVARTYVE' // KVART TYVE
            'HALVJFEMITI' // HALV FEM TI
            'PMINUTTEREI' // MINUTTER I
            'JOVERPRHALV' // OVER HALV
            'MELLEVETOLV' // ELLEVE ET TOLV TO
            'FIRESEKSFEM' // FIRE SEKS FEM
            'OTTETRESYVI' // OTTE TRE SYV
            'NONSIETISNI' // TI NI
            'LMSTIVAIIKA',
      ),
    ),
    // @generated end,
    WordClockGrid(
      isTimeCheck: true,
      timeToWords: DanishTimeToWords(),
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
