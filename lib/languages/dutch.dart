import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/dutch_time_to_words.dart';

const dutchLanguage = WordClockLanguage(
  id: 'NL',
  languageCode: 'nl-NL',
  displayName: 'Nederlands',
  description: null,
  timeToWords: DutchTimeToWords(),
  paddingAlphabet: 'KAATZMESPMTHGSAMCOPM',
  timeCheckGrid: WordGrid(
    width: 11,
    letters:
        'HETKISAVIJFTIENATZVOOROVERMEKWARTHALFSPMOVERVOORTHGÉÉNSTWEEAMCDRIEVIERVIJFZESZEVENONEGENACHTTIENELFTWAALFPMUUR',
  ),
  minuteIncrement: 5,
);
