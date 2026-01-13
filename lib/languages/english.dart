import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/english_time_to_word.dart';

final englishAlternativeLanguage = WordClockLanguage(
  id: 'E2',
  languageCode: 'en-US-x-alt',
  displayName: 'English',
  englishName: 'English',
  description: 'Alternative',
  grids: [
    WordClockGrid(
      isDefault: true,
      timeToWords: EnglishAlternativeTimeToWords(),
      paddingAlphabet: 'ACDEFLMPRSUX',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            "ITEISLFIVEA"
            "FTWENTYFIVE"
            "PMHALFEDTEN"
            "CQUARTERCTO"
            "PASTLTWELVE"
            "ELEVENEIGHT"
            "SEVENETHREE"
            "FIVENINETEN"
            "UFOURRTWONE"
            "ASIXEO'CLOCK",
      ),
    ),
    WordClockGrid(
      isTimeCheck: true,
      timeToWords: EnglishAlternativeTimeToWords(),
      paddingAlphabet: 'ACDEFLMPRSUX',
      grid: WordGrid.fromLetters(
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
    ),
  ],
  minuteIncrement: 5,
);

final englishLanguage = WordClockLanguage(
  id: 'EN',
  languageCode: 'en-US',
  displayName: 'English',
  englishName: 'English',
  description: null,
  grids: [
    WordClockGrid(
      isDefault: true,
      timeToWords: EnglishTimeToWords(),
      paddingAlphabet: 'ACDEFLMPRSUX',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            "ITEISLFIVEF"
            "PTWENTYFIVE"
            "QUARTERHALF"
            "MTENEDPASTO"
            "TWELVELEVEN"
            "EIGHTCSEVEN"
            "CTHREELFIVE"
            "NINEFOURTEN"
            "ETWONEURSIX"
            "AEDCLO'CLOCK",
      ),
    ),
    WordClockGrid(
      isTimeCheck: true,
      timeToWords: EnglishTimeToWords(),
      paddingAlphabet: 'ACDEFLMPRSUX',
      grid: WordGrid.fromLetters(
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
    ),
  ],
  minuteIncrement: 5,
);
