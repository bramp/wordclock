import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/romanian_time_to_words.dart';

final romanianLanguage = WordClockLanguage(
  id: 'RO',
  languageCode: 'ro-RO',
  displayName: 'Română',
  englishName: 'Romanian',
  description: null,
  timeToWords: RomanianTimeToWords(),
  paddingAlphabet: 'ABLMNOPUVZ',
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "ESTEPATRUNU"
        "ORAUNŞAPTEO"
        "ŞISFERTZNZP"
        "CINCINOUĂBN"
        "ZECEBBZZVLL"
        "FĂRĂBNUOVMM"
        "DOUĂZECIOAB"
        "TREIZECIPAU"
        "UNSPREZECEP"
        "ŞASENLAAOPT",
  ),
  timeCheckGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        'ESTEZORAPMO'
        'DOUĂNSPREAM'
        'UNSPREZECEL'
        'NOUĂOPTŞASE'
        'PATRUNUTREI'
        'ŞAPTECINCIA'
        'ŞIBTREIZECI'
        'FĂRĂOZECEUN'
        'DOUĂZECIVŞI'
        'CINCIUSFERT',
  ),
  minuteIncrement: 5,
);
