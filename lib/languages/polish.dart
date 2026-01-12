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
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "PIERWSZÓSTP"
        "BCZWARTRZEC"
        "DZIESIJEDEN"
        "DZIEWIÓSMĄT"
        "DWUNDRUGAST"
        "AĘCZTERTRZY"
        "TDWADZIEŚCI"
        "PIĘTANAŚŚCI"
        "PIĘĆEDZIESI"
        "HĄTŚĘĆJPIĘĆ",
  ),
);
