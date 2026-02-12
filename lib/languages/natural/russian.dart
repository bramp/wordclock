import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/languages/natural/russian_time_to_words.dart';

final russianLanguage = WordClockLanguage(
  id: 'RU',
  languageCode: 'ru-RU',
  displayName: 'Русский',
  englishName: 'Russian',
  description: null,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-02-02T21:47:49.181250
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 24, Duration: 26ms
    WordClockGrid(
      isDefault: true,
      timeToWords: RussianTimeToWords(),
      paddingAlphabet: 'АДМРЯ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ОДИННАДЦАТЬ' // ОДИННАДЦАТЬ ОДИН
            'АДВЕНАДЦАТЬ' // ДВЕНАДЦАТЬ
            'ЯЯЯДДЧЕТЫРЕ' // ЧЕТЫРЕ
            'ЯДДЯЯРШЕСТЬ' // ШЕСТЬ
            'МВОСЕМЬМДВА' // ВОСЕМЬ СЕМЬ ДВА
            'ДДЕВЯТЬЯТРИ' // ДЕВЯТЬ ТРИ
            'ЧАСАМДЕСЯТЬ' // ЧАСА ЧАС ДЕСЯТЬ
            'АПЯТЬРЧАСОВ' // ПЯТЬ ЧАСОВ
            'РПЯТНАДЦАТЬ' // ПЯТНАДЦАТЬ
            'РПЯТЬДЕСЯТЬ' // ПЯТЬДЕСЯТ ДЕСЯТЬ
            'ААДДВАДЦАТЬ' // ДВАДЦАТЬ
            'ДАМТРИДЦАТЬ' // ТРИДЦАТЬ
            'ДСОРОКЯПЯТЬ' // СОРОК ПЯТЬ
            'МААРДММИНУТ', // МИНУТ
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
);
