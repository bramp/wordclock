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
    // Generated: 2026-01-31T22:03:12.756432
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 23, Duration: 13ms
    WordClockGrid(
      isDefault: true,
      timeToWords: EnglishAlternativeTimeToWords(),
      paddingAlphabet: 'ACDEFLMPRSUX',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ITEISLFPMED' // IT IS
            'CCLEURAHALF' // HALF
            'QUARTERETEN' // QUARTER TEN
            'TWENTYDFIVE' // TWENTY FIVE
            'PASTOCEIGHT' // PAST TO EIGHT
            'TWELVELEVEN' // TWELVE ELEVEN
            'SEVENLTHREE' // SEVEN THREE
            'FIVENINETEN' // FIVE NINE TEN
            'RFOURCTWONE' // FOUR TWO ONE
            'XSIXPO\'CLOCK', // SIX O'CLOCK
      ),
    ),
    // @generated end,
    WordClockGrid(
      isReference: true,
      timeToWords: ReferenceEnglishAlternativeTimeToWords(
        useSpaceInTwentyFive: false,
      ),
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
    // Generated: 2026-01-31T21:51:10.082228
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 23, Duration: 4ms
    WordClockGrid(
      isDefault: true,
      timeToWords: EnglishTimeToWords(),
      paddingAlphabet: 'ACDEFLMPRSUX',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ITEISLFPMED' // IT IS
            'CCLEURAHALF' // HALF
            'QUARTERETEN' // QUARTER TEN
            'TWENTYDFIVE' // TWENTY FIVE
            'PASTOCEIGHT' // PAST TO EIGHT
            'TWELVELEVEN' // TWELVE ELEVEN
            'SEVENLTHREE' // SEVEN THREE
            'FIVENINETEN' // FIVE NINE TEN
            'RFOURCTWONE' // FOUR TWO ONE
            'XSIXPO\'CLOCK', // SIX O'CLOCK
      ),
    ),
    // @generated end,
    WordClockGrid(
      isReference: true,
      timeToWords: ReferenceEnglishTimeToWords(useSpaceInTwentyFive: true),
      paddingAlphabet: 'ACDEFLMPRSUX',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ITEISLFPMED' // IT IS
            'CCLEURAHALF' // HALF
            'QUARTERETEN' // QUARTER TEN
            'TWENTYDFIVE' // TWENTY FIVE
            'PASTOCEIGHT' // PAST TO EIGHT
            'TWELVELEVEN' // TWELVE ELEVEN
            'SEVENLTHREE' // SEVEN THREE
            'FIVENINETEN' // FIVE NINE TEN
            'RFOURCTWONE' // FOUR TWO ONE
            'XSIXPO\'CLOCK', // SIX O'CLOCK
      ),
    ),
  ],
  minuteIncrement: 5,
);
