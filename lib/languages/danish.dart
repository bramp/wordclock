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
    WordClockGrid(
      isDefault: true,
      timeToWords: DanishTimeToWords(),
      paddingAlphabet: 'AEIJKLMNOPRSTV',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            "KLOKKENPERL"
            "KVARTHALVIM"
            "TYVEOVERSTI"
            "IJIPEJPRFEM"
            "MMINUTTERII"
            "NOVERONHALV"
            "ELLEVESSEKS"
            "OTTETOLVSYV"
            "FIREFEMTREI"
            "ESLMSTTIINI",
      ),
    ),
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
