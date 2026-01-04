import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/english_time_to_word.dart';

final englishAlternativeLanguage = WordClockLanguage(
  id: 'E2',
  languageCode: 'en-US-x-alt',
  displayName: 'English',
  englishName: 'English',
  description: 'Alternative',
  timeToWords: EnglishAlternativeTimeToWords(),
  paddingAlphabet: 'ACDEFLMPRSUX',
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "ITEISLAFPME"
        "QUARTERFIVE"
        "HALFEUTENRA"
        "CXTWENTYPMS"
        "TWENTYFIVEA"
        "UMPASTRTOUD"
        "EIGHTELEVEN"
        "FIVEFOURFFL"
        "RLNINEMONEU"
        "SEVENSIXTEN"
        "THREETWELVE"
        "FTWOUO'CLOCK",
  ),
  timeCheckGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        'ITLISASAMPM'
        'ACQUARTERDC'
        'TWENTYFIVEX'
        'HALFSTENFTO'
        'PASTERUNINE'
        'ONESIXTHREE'
        'FOURFIVETWO'
        'EIGHTELEVEN'
        'SEVENTWELVE'
        'TENSEO\'CLOCK',
  ),
  minuteIncrement: 5,
);

final englishLanguage = WordClockLanguage(
  id: 'EN',
  languageCode: 'en-US',
  displayName: 'English',
  englishName: 'English',
  description: null,
  timeToWords: EnglishTimeToWords(),
  paddingAlphabet: 'ACDEFLMPRSUX',
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "ITEISDTENLF"
        "ARQUARTERFM"
        "TWENTYFIVED"
        "TOHALFCPAST"
        "TWELVEEIGHT"
        "FIVETWONINE"
        "LSEVENMEONE"
        "XELEVENFTEN"
        "RCSIXPTHREE"
        "FOURDO'CLOCK",
  ),
  timeCheckGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        'ITLISASAMPM'
        'ACQUARTERDC'
        'TWENTYFIVEX'
        'HALFSTENFTO'
        'PASTERUNINE'
        'ONESIXTHREE'
        'FOURFIVETWO'
        'EIGHTELEVEN'
        'SEVENTWELVE'
        'TENSEO\'CLOCK',
  ),
  minuteIncrement: 5,
);
