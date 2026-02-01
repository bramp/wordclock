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
    // @generated begin - do not edit manually
    // Generated: 2026-01-25T09:42:52.224383
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 24, Duration: 4ms
    WordClockGrid(
      isDefault: true,
      timeToWords: ReferenceEnglishAlternativeTimeToWords(useSpaceInTwentyFive: true),
      paddingAlphabet: 'ACDEFLMPRSUX',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ITEISLHALFF' // IT IS HALF A
            'PTWENTYMTEN' // TWENTY TEN
            'QUARTERFIVE' // QUARTER FIVE
            'PASTOEEIGHT' // PAST TO EIGHT
            'TWELVELEVEN' // TWELVE ELEVEN
            'SEVENDTHREE' // SEVEN THREE
            'FIVENINETEN' // FIVE NINE TEN
            'CFOURCTWONE' // FOUR TWO ONE
            'LSIXEO\'CLOCK' // SIX O'CLOCK
            'URAEDCLRCXP',
      ),
    ),
    // @generated end,
    WordClockGrid(
      isReference: true,
      timeToWords: ReferenceEnglishAlternativeTimeToWords(),
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
    // @generated begin - do not edit manually
    // Generated: 2026-01-25T09:42:52.234047
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 23, Duration: 3ms
    WordClockGrid(
      isDefault: true,
      timeToWords: ReferenceEnglishTimeToWords(useSpaceInTwentyFive: true),
      paddingAlphabet: 'ACDEFLMPRSUX',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ITEISLHALFF' // IT IS HALF
            'QUARTERPTEN' // QUARTER TEN
            'TWENTYMFIVE' // TWENTY FIVE
            'PASTOEEIGHT' // PAST TO EIGHT
            'TWELVELEVEN' // TWELVE ELEVEN
            'SEVENDTHREE' // SEVEN THREE
            'FIVENINETEN' // FIVE NINE TEN
            'CFOURCTWONE' // FOUR TWO ONE
            'LSIXEO\'CLOCK' // SIX O'CLOCK
            'URAEDCLRCXP',
      ),
    ),
    // @generated end,
    WordClockGrid(
      isReference: true,
      timeToWords: ReferenceEnglishTimeToWords(),
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
