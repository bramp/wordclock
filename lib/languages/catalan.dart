import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/catalan_time_to_words.dart';

const catalanLanguage = WordClockLanguage(
  id: 'CA',
  languageCode: 'ca-ES',
  displayName: 'Català',
  description: null,
  timeToWords: CatalanTimeToWords(),
  paddingAlphabet: 'RMANCINCUE\'TUONZSAUNPIC',
  timeCheckGrid: WordGrid(
    width: 11,
    letters:
        'ÉSÓNRLAMUNADOSLESNTRESCINCQUARTSUMENYSIECINCDED\'RUNAONZEDUESTRESETDQUATREDOTZEVUITNOUONZESISAMDEUNPMMENYSIACINC',
  ),
  minuteIncrement: 5,
);
