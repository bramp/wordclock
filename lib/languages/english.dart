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
    // Generated: 2026-01-31T21:41:19.078532
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 23, Duration: 5ms
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
      customTokenizer: (phrase) {
        if (phrase.contains('TWENTY FIVE')) {
          phrase = phrase.replaceAll('TWENTY FIVE', 'TWENTYFIVE');
        }
        return phrase.split(' ').where((w) => w.isNotEmpty).toList();
      },
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
    // Generated: 2026-01-31T21:41:19.379080
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
      customTokenizer: (phrase) {
        if (phrase.contains('TWENTY FIVE')) {
          phrase = phrase.replaceAll('TWENTY FIVE', 'TWENTYFIVE');
        }
        return phrase.split(' ').where((w) => w.isNotEmpty).toList();
      },
    ),
  ],
  minuteIncrement: 5,
);
