import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/russian_time_to_words.dart';

final russianLanguage = WordClockLanguage(
  id: 'RU',
  languageCode: 'ru-RU',
  displayName: 'Русский',
  englishName: 'Russian',
  description: null,
  grids: [
    // @generated begin - do not edit manually
    WordClockGrid(
      isDefault: true,
      timeToWords: RussianTimeToWords(),
      paddingAlphabet: 'АДМРЯ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ШЕСТЬОДИНЧЕ'
            'ДВАТРИДВЕВО'
            'НАДЦАТЬСЕМЬ'
            'ТЫЧАСРЕПЯТЬ'
            'ЧАСАДЕАВЯТЬ'
            'ЯСЯТЬЯЧАСОВ'
            'ПЯТНАДСОРОК'
            'ЯДВАДАТРИДЕ'
            'ЯТРИДРМЦАТЬ'
            'ПЯТЬМДЕСЯТЬ'
            'ДПЯТЬЯМИНУТ',
      ),
    ),
    // @generated end,
    WordClockGrid(
      isReference: true,
      timeToWords: ReferenceRussianTimeToWords(),
      paddingAlphabet: 'АДМРЯ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ОДИНПЯТЬДВА'
            'ДЕШЕСТЬВЯТЬ'
            'ВОЧЕСЕМЬТРИ'
            'ТЫДВЕРЕСЯТЬ'
            'НАДЦАТЬЧАСА'
            'ЧАСОВДСОРОК'
            'ТРИДВАДПЯТЬ'
            'ПЯТНАДЕЦАТЬ'
            'АМДЕСЯТСЯТЬ'
            'ПЯТЬЯРМИНУТ',
      ),
    ),
  ],
  minuteIncrement: 5,
  atomizePhrases: true,
);
