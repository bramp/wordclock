import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/french_time_to_words.dart';

const frenchLanguage = WordClockLanguage(
  id: 'FR',
  languageCode: 'fr-FR',
  displayName: 'Français',
  description: null,
  timeToWords: FrenchTimeToWords(),
  paddingAlphabet: 'NORORPMDUSPAM',
  timeCheckGrid: WordGrid(
    width: 11,
    letters:
        'ILNESTODEUXQUATRETROISNEUFUNESEPTHUITSIXCINQMIDIXMINUITONZERHEURESMOINSOLEDIXETRQUARTPMDVINGT-CINQUETSDEMIEPAM',
  ),
  minuteIncrement: 5,
);
