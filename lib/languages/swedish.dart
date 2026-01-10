import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/swedish_time_to_words.dart';

final swedishLanguage = WordClockLanguage(
  id: 'SE',
  languageCode: 'sv-SE',
  displayName: 'Svenska',
  englishName: 'Swedish',
  description: null,
  timeToWords: SwedishTimeToWords(),
  paddingAlphabet: 'AEFIKLMNOPQRSTUVXYZ',
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "KLOCKANIÄRY"
        "UUKVARTJUGO"
        "EVHALVYOTIO"
        "KÖVERZFEMZI"
        "VÖVERVPHALV"
        "TOLVELVATIO"
        "ÄTTAFYRAETT"
        "NIOVTVÅQSJU"
        "SEXUTREPFEM"
        "ANKLYMMKLAS",
  ),
  timeCheckGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        'KLOCKANTÄRK'
        'FEMYISTIONI'
        'KVARTQIENZO'
        'TJUGOLIVIPM'
        'ÖVERKAMHALV'
        'ETTUSVLXTVÅ'
        'TREMYKYFYRA'
        'FEMSFLORSEX'
        'SJUÄTTAINIO'
        'TIOELVATOLV',
  ),
  minuteIncrement: 5,
);
