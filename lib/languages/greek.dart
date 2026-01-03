import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/greek_time_to_words.dart';

const greekLanguage = WordClockLanguage(
  id: 'GR',
  languageCode: 'el-GR',
  displayName: 'Ελληνικά',
  description: null,
  timeToWords: GreekTimeToWords(),
  paddingAlphabet: 'ΧTPHEXEPEHEP',
  timeCheckGrid: WordGrid(
    width: 11,
    letters:
        'HΧΩPATEINAIMIAΔYOTPEIΣTEΣΣEPIΣEΞIΠENTEPOΧTΩHEΦTAEENTEKAΔΩΔEKAENNIAΔEKAXΠAPAEPKAIETETAPTOEIKOΣIHΔEKAMIΣHEΠENTEP',
  ),
  minuteIncrement: 5,
);
