import 'package:wordclock/languages/language.dart';
import 'package:wordclock/logic/polish_time_to_words.dart';
import 'package:wordclock/model/word_grid.dart';

final polishLanguage = WordClockLanguage(
  id: 'pl',
  languageCode: 'pl-PL',
  displayName: 'Polski',
  englishName: 'Polish',
  timeToWords: PolishTimeToWords(),
  paddingAlphabet: 'ABCDEFGHIJKLMNOPQRSTUWXYZÓĄĆĘŃŚŻ',
  minuteIncrement: 5,
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        'JESTXOŻĆMYG'
        'PIERWSZAGMC'
        'DWADZIEŚCIA'
        'FŃDÓPIĘĆITX'
        'BŚDZIESIĘĆA'
        'KWADRANSCŃY'
        'TĄŻCZWARTAL'
        'JNBUŻDRUGAO'
        'ĆDWUNASTAOÓ'
        'DZIESIĄTAES'
        'JDZIEWIĄTAO'
        'DZJEDENASTA'
        'PIERWSZAXNN'
        'BPIĄTAŚMJPO'
        'EDKSIÓDMAĘR'
        'FLSZÓSTACLR'
        'TRZECIAÓSMA'
        'WPÓŁPADOĄEX'
        'LEĄCZWARTEJ'
        'IRDRUGIEJLY'
        'ĘĄDWUNASTEJ'
        'DZIESIĄTEJL'
        'DZIEWIĄTEJN'
        'MJEDENASTEJ'
        'IPIERWSZEJE'
        'CPIĄTEJBĆHT'
        'IQĄSIÓDMEJY'
        'DUBSZÓSTEJW'
        'FTRZECIEJĘÓ'
        'FŃPĘMCÓSMEJ',
  ),
);
