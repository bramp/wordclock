import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/dutch_time_to_words.dart';

final dutchLanguage = WordClockLanguage(
  id: 'NL',
  languageCode: 'nl-NL',
  displayName: 'Nederlands',
  englishName: 'Dutch',
  description: null,
  timeToWords: DutchTimeToWords(),
  paddingAlphabet: 'ACEGHKMOPSTZ',
  // Seed: 0
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "HETGISEVIJF"
        "TIENPKWARTC"
        "SVOORAOVERE"
        "HHALFCZEVEN"
        "MACHTPNEGEN"
        "ELFHTIENHKP"
        "KMVIJFTÉÉNT"
        "ZESZATWAALF"
        "DRIEZOSTWEE"
        "CKAVIERTUUR",
  ),
  timeCheckGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        'HETKISAVIJF'
        'TIENATZVOOR'
        'OVERMEKWART'
        'HALFSPMOVER'
        'VOORTHGÉÉNS'
        'TWEEAMCDRIE'
        'VIERVIJFZES'
        'ZEVENONEGEN'
        'ACHTTIENELF'
        'TWAALFPMUUR',
  ),
  minuteIncrement: 5,
);
