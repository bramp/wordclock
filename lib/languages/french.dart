import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/french_time_to_words.dart';

final frenchLanguage = WordClockLanguage(
  id: 'FR',
  languageCode: 'fr-FR',
  displayName: 'Français',
  englishName: 'French',
  description: null,
  grids: [
    WordClockGrid(
      isDefault: true,
      timeToWords: FrenchTimeToWords(),
      paddingAlphabet: 'ADEMNOPRSTU',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            "ILEESTEONZE"
            "QUATRETROIS"
            "MINUITNDEUX"
            "HUITMIDISIX"
            "UNEUFRHEURE"
            "SEPTCINQDIX"
            "PHEURESUTET"
            "MOINSODEMIE"
            "MVINGT-CINQ"
            "DIXLEAQUART",
      ),
    ),
    WordClockGrid(
      isTimeCheck: true,
      timeToWords: FrenchTimeToWords(),
      paddingAlphabet: 'ADEMNOPRSTU',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ILNESTODEUX'
            'QUATRETROIS'
            'NEUFUNESEPT'
            'HUITSIXCINQ'
            'MIDIXMINUIT'
            'ONZERHEURES'
            'MOINSOLEDIX'
            'ETRQUARTPMD'
            'VINGT-CINQU'
            'ETSDEMIEPAM',
      ),
    ),
  ],
  minuteIncrement: 5,
);
