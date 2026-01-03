import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/italian_time_to_words.dart';

const italianLanguage = WordClockLanguage(
  id: 'IT',
  languageCode: 'it-IT',
  displayName: 'Italiano',
  description: null,
  timeToWords: ItalianTimeToWords(),
  paddingAlphabet: 'RBORERAEOEENIA',
  timeCheckGrid: WordGrid(
    width: 11,
    letters:
        'SONORLEBOREÈRL’UNASDUEZTREOTTONOVEDIECIUNDICIDODICISETTEQUATTROCSEICINQUEAMENOEKUNLQUARTOVENTICINQUEDIECILMEZZA',
  ),
  minuteIncrement: 5,
);
