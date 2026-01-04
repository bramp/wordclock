import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/russian_time_to_words.dart';

final russianLanguage = WordClockLanguage(
  id: 'RU',
  languageCode: 'ru-RU',
  displayName: 'Русский',
  englishName: 'Russian',
  description: null,
  timeToWords: RussianTimeToWords(),
  paddingAlphabet: 'АДМРЯ',
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "ВОАСЕМЬДВАЯ"
        "ДВЕОДИНЯЯДД"
        "НАДЦАТЬЧАСЯ"
        "ТРИЧЕРТЫМРЕ"
        "ЧАСАШЕСТЬМЯ"
        "ЧАСОВРМДВАД"
        "ПЯТНАДСОРОК"
        "АТРИДРЦАТЬР"
        "АПЯТЬДДЕСЯТ"
        "ЧАСОВМАДЕДА"
        "ВЯТЬРЧАСОВД"
        "ДЕЯМРСЯТЬРД"
        "ЧАСОВДЯДВАД"
        "АДЕРМММСЯТЬ"
        "ПЯТНАДСОРОК"
        "ТРИДМЦАТЬЯР"
        "ПЯТЬРДЕСЯТР"
        "ЯПЯТЬЯМИНУТ",
  ),
  timeCheckGrid: WordGrid.fromLetters(
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
  minuteIncrement: 5,
);
