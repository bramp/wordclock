import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/english_time_to_word.dart';

final englishAlternativeLanguage = WordClockLanguage(
  id: 'E2',
  languageCode: 'en-US-x-alt',
  displayName: 'English',
  description: 'Alternative',
  timeToWords: EnglishAlternativeTimeToWords(),
  paddingAlphabet: 'LASAMPMCDCXSFERUSEK',
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
  description: null,
  timeToWords: EnglishTimeToWords(),
  paddingAlphabet: 'LASAMPMACDCXSFERUSEK',
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

final englishDigitalLanguage = WordClockLanguage(
  id: 'E3',
  languageCode: 'en-US-x-digital',
  displayName: 'English',
  description: 'Digital',
  timeToWords: EnglishDigitalTimeToWords(),
  paddingAlphabet: 'LASAMPMACDCXSFERUSEK',
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
