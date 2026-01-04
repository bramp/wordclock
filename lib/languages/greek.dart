import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/greek_time_to_words.dart';

final greekLanguage = WordClockLanguage(
  id: 'GR',
  languageCode: 'el-GR',
  displayName: 'Ελληνικά',
  description: null,
  timeToWords: GreekTimeToWords(),
  paddingAlphabet: 'AEHKPTXΔΧ',
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "HKΩPATEINAI"
        "ENNIAENTEKA"
        "ΔEΞIEΦTAMIA"
        "PHOΧTΩXKHEΧ"
        "ETEΣΣEPIΣXX"
        "PTPEIΣEΔYOX"
        "ΔΩΔEKAΔΧKAI"
        "ΠAPAΔEIKOΣI"
        "ΔPΠENTETKAI"
        "ΠAPAXΧΔEKAH"
        "PKAIΔKΔMIΣH"
        "ΠAPAΔEIKOΣI"
        "EΠENTEKEEΧK"
        "TETAPTOΔEKA",
  ),
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
