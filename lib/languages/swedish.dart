import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/swedish_time_to_words.dart';

const swedishLanguage = WordClockLanguage(
  id: 'SE',
  languageCode: 'sv-SE',
  displayName: 'Svenska',
  description: null,
  timeToWords: SwedishTimeToWords(),
  paddingAlphabet: 'TKYSNQENZOLVIPMKAMUSVLXMYKYSFLORI',
  timeCheckGrid: WordGrid(
    width: 11,
    letters:
        'KLOCKANTÄRKFEMYISTIONIKVARTQIENZOTJUGOLIVIPMÖVERKAMHALVETTUSVLXTVÅTREMYKYFYRAFEMSFLORSEXSJUÄTTAINIOTIOELVATOLV',
  ),
  minuteIncrement: 5,
);
