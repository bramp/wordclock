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
    // Generated: 2026-01-16T16:56:16.185354
    // Algorithm: Trie
    // Seed: 0
    // Iterations: 27, Duration: 5ms
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
            'JOVERPRHALV' // OVER HALV HALV
            'FEMTITOLVET' // FEM FEM TI TI TOLV TO ET
            'TREFIRESEKS' // TRE FIRE SEKS
            'SYVMOTTEINI' // SYV OTTE NI
            'NONSIELLEVE' // ELLEVE
            'ESLMSTIVAII',
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
