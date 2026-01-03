import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/danish_time_to_words.dart';

const danishLanguage = WordClockLanguage(
  id: 'DK',
  languageCode: 'da-DK',
  displayName: 'Dansk',
  description: null,
  timeToWords: DanishTimeToWords(),
  paddingAlphabet: 'VOSKAMOJEVATAVEMILPMMONALSRRMEA',
  timeCheckGrid: WordGrid(
    width: 11,
    letters:
        'KLOKKENVEROFEMTYVESKAMOJEKVARTVATTIAMINUTTERVEMOVERILPMMONALISHALVETTOTREFIREFEMSEKSRSYVOTTERNIMETIELLEVEATOLV',
  ),
  minuteIncrement: 5,
);
