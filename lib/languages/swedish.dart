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
        "KLOCKANQUPA"
        "ÄRNMKVARTMK"
        "SFEMQTTJUGO"
        "ZIOQKIEÖVER"
        "RAHALVPOFEM"
        "STIOQTOLVKO"
        "LELVANLESEX"
        "AÄTTAPFYRAA"
        "FNYETTTRESO"
        "LVNIOTVÅSJU",
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
