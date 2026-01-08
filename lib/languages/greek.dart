import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/greek_time_to_words.dart';

final greekLanguage = WordClockLanguage(
  id: 'GR',
  languageCode: 'el-GR',
  displayName: 'Ελληνικά',
  englishName: 'Greek',
  description: null,
  timeToWords: GreekTimeToWords(),
  paddingAlphabet: 'AEHKPTXΔΧ',

  // TODO Add a defaultGrid
  timeCheckGrid: WordGrid.fromLetters(
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
  minuteIncrement: 5,
);
