import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/catalan_time_to_words.dart';

final catalanLanguage = WordClockLanguage(
  id: 'CA',
  languageCode: 'ca-ES',
  displayName: 'Català',
  englishName: 'Catalan',
  description: null,
  timeToWords: CatalanTimeToWords(),
  paddingAlphabet: 'ADEMNOPRUZ',
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "CINCD'QUATRE"
        "SÓNLESVUITO"
        "DEUNDOTZEZN"
        "QUARTSNOUZP"
        "MENYSDNDDZZ"
        "TRESETUEEDN"
        "ÉSUNAROUMMO"
        "DOSISADPARP"
        "DUESNEAAUPE"
        "ONZEUPNEZLA",
  ),
  timeCheckGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        'ÉSÓNRLAMUNA'
        'DOSLESNTRES'
        'CINCQUARTSU'
        'MENYSIECINC'
        'DED\'RUNAONZE'
        'DUESTRESETD'
        'QUATREDOTZE'
        'VUITNOUONZE'
        'SISAMDEUNPM'
        'MENYSIACINC',
  ),
  minuteIncrement: 5,
);
