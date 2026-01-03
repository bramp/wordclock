import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/russian_time_to_words.dart';

const russianLanguage = WordClockLanguage(
  id: 'RU',
  languageCode: 'ru-RU',
  displayName: 'Русский',
  description: null,
  timeToWords: RussianTimeToWords(),
  paddingAlphabet: 'ДЕАМЯР',
  timeCheckGrid: WordGrid(
    width: 11,
    letters:
        'ОДИНПЯТЬДВАДЕШЕСТЬВЯТЬВОЧЕСЕМЬТРИТЫДВЕРЕСЯТЬНАДЦАТЬЧАСАЧАСОВДСОРОКТРИДВАДПЯТЬПЯТНАДЕЦАТЬАМДЕСЯТСЯТЬПЯТЬЯРМИНУТ',
  ),
  minuteIncrement: 5,
);
