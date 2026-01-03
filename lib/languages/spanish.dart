import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/spanish_time_to_words.dart';

const spanishLanguage = WordClockLanguage(
  id: 'ES',
  languageCode: 'es-ES',
  displayName: 'Español',
  description: null,
  timeToWords: SpanishTimeToWords(),
  paddingAlphabet: 'EIOAMANPMLASLO',
  timeCheckGrid: WordGrid(
    width: 11,
    letters:
        'ESONELASUNADOSITRESOAMCUATROCINCOSEISASIETENOCHONUEVEPMLADIEZSONCEDOCELYMENOSOVEINTEDIEZVEINTICINCOMEDIACUARTO',
  ),
  minuteIncrement: 5,
);
