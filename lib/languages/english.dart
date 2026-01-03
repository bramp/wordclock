import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/english_time_to_word.dart';

const englishAlternativeLanguage = WordClockLanguage(
  id: 'E2',
  languageCode: 'en-US-x-alt',
  displayName: 'English',
  description: 'Alternative',
  timeToWords: EnglishAlternativeTimeToWords(),
  paddingAlphabet: 'LASAMPMCDCXSFERUSEK',
  timeCheckGrid: WordGrid(
    width: 11,
    letters:
        'ITLISASAMPMACQUARTERDCTWENTYFIVEXHALFSTENFTOPASTERUNINEONESIXTHREEFOURFIVETWOEIGHTELEVENSEVENTWELVETENSEO\'CLOCK',
  ),
  minuteIncrement: 5,
);

const englishLanguage = WordClockLanguage(
  id: 'EN',
  languageCode: 'en-US',
  displayName: 'English',
  description: null,
  timeToWords: EnglishTimeToWords(),
  paddingAlphabet: 'LASAMPMACDCXSFERUSEK',
  timeCheckGrid: WordGrid(
    width: 11,
    letters:
        'ITLISASAMPMACQUARTERDCTWENTYFIVEXHALFSTENFTOPASTERUNINEONESIXTHREEFOURFIVETWOEIGHTELEVENSEVENTWELVETENSEO\'CLOCK',
  ),
  minuteIncrement: 5,
);

const englishDigitalLanguage = WordClockLanguage(
  id: 'E3',
  languageCode: 'en-US-x-digital',
  displayName: 'English',
  description: 'Digital',
  timeToWords: EnglishDigitalTimeToWords(),
  paddingAlphabet: 'LASAMPMACDCXSFERUSEK',
  timeCheckGrid: WordGrid(
    width: 11,
    letters:
        'ITLISASAMPMACQUARTERDCTWENTYFIVEXHALFSTENFTOPASTERUNINEONESIXTHREEFOURFIVETWOEIGHTELEVENSEVENTWELVETENSEO\'CLOCK',
  ),
  minuteIncrement: 5,
);
