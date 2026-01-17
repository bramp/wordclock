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
    // Generated: 2026-01-16T16:56:26.283496
    // Algorithm: Trie
    // Seed: 0
    // Iterations: 24751, Duration: 16ms
    WordClockGrid(
      isDefault: true,
      timeToWords: EnglishAlternativeTimeToWords(useSpaceInTwentyFive: true),
      paddingAlphabet: 'ACDEFLMPRSUX',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ITEISLFIVEA' // IT IS FIVE A
            'FTENPTWENTY' // TEN TWENTY
            'TWENTYAFIVE' // TWENTY FIVE
            'HALFQUARTER' // HALF QUARTER
            'EPASTODFIVE' // PAST TO FIVE
            'TENFIVEONEC' // TEN TEN FIVE ONE
            'TWELVELEVEN' // TWELVE ELEVEN
            'THREEIGHTWO' // THREE EIGHT TWO
            'SIXSEVENINE' // SIX SEVEN NINE
            'FOURCO\'CLOCK', // FOUR O'CLOCK
      ),
    ),
    // @generated end,
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
    // @generated begin - do not edit manually
    // Generated: 2026-01-16T16:56:26.294171
    // Algorithm: Trie
    // Seed: 0
    // Iterations: 26, Duration: 5ms
    WordClockGrid(
      isDefault: true,
      timeToWords: EnglishTimeToWords(useSpaceInTwentyFive: true),
      paddingAlphabet: 'ACDEFLMPRSUX',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ITEISLFIVEF' // IT IS FIVE
            'TENPQUARTER' // TEN QUARTER
            'TWENTYAFIVE' // TWENTY FIVE
            'EHALFDPASTO' // HALF PAST TO
            'FIVETENONEC' // FIVE FIVE TEN TEN ONE
            'CTWELVELTWO' // TWELVE TWO
            'ETHREEUFOUR' // THREE FOUR
            'SIXSEVENINE' // SIX SEVEN NINE
            'EIGHTELEVEN' // EIGHT ELEVEN
            'RAEDCO\'CLOCK', // O'CLOCK
      ),
    ),
    // @generated end,
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
