import 'package:wordclock/languages/language.dart';
import 'package:wordclock/logic/polish_time_to_words.dart';
import 'package:wordclock/model/word_grid.dart';

final polishLanguage = WordClockLanguage(
  id: 'PL',
  languageCode: 'pl-PL',
  displayName: 'Polski',
  englishName: 'Polish',
  timeToWords: PolishTimeToWords(),
  paddingAlphabet: 'ABCDEFGHIJKLMNOPQRSTUWXYZÓĄĆĘŃŚŻ',
  minuteIncrement: 5,
  // TODO: Fix language/grammar to make this fit in a smaller grid.
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "JESTPWPÓŁZA"
        "DWADZIEŚCIA"
        "KWADRANSBDO"
        "ĘTŚDZIESIĘĆ"
        "PIĘĆHSIÓDMA"
        "JEDENASTAPO"
        "ŚJDZIESIĄTA"
        "ÓJDZIEWIĄTA"
        "YCIPIERWSZA"
        "ZTŚDWUNASTA"
        "TRZECIAÓSMA"
        "BNAŃCZWARTA"
        "SZÓSTAPIĄTA"
        "DRUGAPIĄTEJ"
        "ĆDZIESIĄTEJ"
        "PJEDENASTEJ"
        "ŚDZIEWIĄTEJ"
        "ŃEDWUNASTEJ"
        "KJPIERWSZEJ"
        "QĘKTRZECIEJ"
        "ŚŚQCZWARTEJ"
        "OZUISIÓDMEJ"
        "QMŃZSZÓSTEJ"
        "KIŚĘDRUGIEJ"
        "BSKGUSÓSMEJ"
        "ĆUHLWHŻÓŚBŃ"
        "EBĆBYFURNIZ"
        "HLHLÓAĆGĆRT"
        "GŚFJMBGQIDK"
        "WUJLĆIŻTIZI",
  ),
);
