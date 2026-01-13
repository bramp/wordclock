import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/greek_time_to_words.dart';

final greekLanguage = WordClockLanguage(
  id: 'GR',
  languageCode: 'el-GR',
  displayName: 'Ελληνικά',
  englishName: 'Greek',
  description: null,
  grids: [
    WordClockGrid(
      isDefault: true,
      timeToWords: GreekTimeToWords(),
      paddingAlphabet: 'AEHKPTXΔΧ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            "HKΩPATEINAI"
            "TEΣΣEPIΣMIA"
            "ENTEKAENNIA"
            "ΔΩΔEKATPEIΣ"
            "OΧTΩEΦTAΔYO"
            "EΞIEΠAPAKAI"
            "ΔΠENTEXΔEKA"
            "KAIΠAPAMIΣH"
            "EIKOΣIXΔEKA"
            "TΠENTETAPTO",
      ),
    ),
    WordClockGrid(
      isTimeCheck: true,
      timeToWords: GreekTimeToWords(),
      paddingAlphabet: 'AEHKPTXΔΧ',
      grid: WordGrid.fromLetters(
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
    ),
  ],
  minuteIncrement: 5,
);
