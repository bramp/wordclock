import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/french_time_to_words.dart';

final frenchLanguage = WordClockLanguage(
  id: 'FR',
  languageCode: 'fr-FR',
  displayName: 'Français',
  englishName: 'French',
  description: null,
  timeToWords: FrenchTimeToWords(),
  paddingAlphabet: 'ADEMNOPRSTU',
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "ILEESTEDEUX"
        "UHUITTOMIDI"
        "MINUITANEUF"
        "MONZEQUATRE"
        "DDSEPTSIXAT"
        "USPTROISUAR"
        "DHEURESUNEA"
        "HEURESMOINS"
        "CINQTHEURES"
        "MOINSNTDIXM"
        "HEURESUEETN"
        "DEMIDEMIETU"
        "RMOINSTCINQ"
        "DIXLETQUART"
        "NVINGTTANDP"
        "OVINGT-CINQ",
  ),
  timeCheckGrid: WordGrid.fromLetters(
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
  minuteIncrement: 5,
);
