import 'package:wordclock/languages/language.dart';
import 'package:wordclock/logic/polish_time_to_words.dart';
import 'package:wordclock/model/word_grid.dart';

const polishLanguage = WordClockLanguage(
  id: 'pl',
  languageCode: 'pl-PL',
  displayName: 'Polski',
  timeToWords: PolishTimeToWords(),
  paddingAlphabet: 'AĄBCĆDEĘFGHIJKLŁMNŃOÓPQRSŚTUVWXYZŹŻ',
  minuteIncrement: 5,
  defaultGrid: WordGrid(
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
