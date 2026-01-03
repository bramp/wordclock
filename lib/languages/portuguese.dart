import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/portuguese_time_to_words.dart';

const portugueseLanguage = WordClockLanguage(
  id: 'PE',
  languageCode: 'pt-PT',
  displayName: 'Português',
  description: null,
  timeToWords: PortugueseTimeToWords(),
  paddingAlphabet: 'LYHZLYCAVPMOY',
  timeCheckGrid: WordGrid(
    width: 11,
    letters:
        'ÉSÃOUMATRÊSMEIOLDIADEZDUASEISETEYQUATROHNOVECINCOITONZEZMEIALNOITEHORASYMENOSVINTECAMEIAUMVQUARTOPMDEZOEYCINCO',
  ),
  minuteIncrement: 5,
);
