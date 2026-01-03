import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/chinese_time_to_words.dart';

final chineseSimplifiedLanguage = WordClockLanguage(
  id: 'CS',
  languageCode: 'zh-Hans-CN',
  displayName: 'Chinese',
  description: 'Simplified',
  timeToWords: ChineseSimplifiedTimeToWords(),
  paddingAlphabet: '是昼六八一七六五点一六三整三二十分八',
  timeCheckGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        '现在是时间昼上午下午夜'
        '十一点半四点五点半六八'
        '七点半一九点半四十五分'
        '四十分三十五分零五分七'
        '六二十五分二十分五十分'
        '五三点半六点十二点半点'
        '十点八点三十分一零五分'
        '六三五十五分二十五分整'
        '三四十五分五十分二十分'
        '二十分八四十分三十五分',
  ),
  minuteIncrement: 5,
);

final chineseTraditionalLanguage = WordClockLanguage(
  id: 'CT',
  languageCode: 'zh-Hant-TW',
  displayName: 'Chinese',
  description: 'Traditional',
  timeToWords: ChineseTraditionalTimeToWords(),
  paddingAlphabet: '是晝六八一七六五點一六三整三二十分八',
  timeCheckGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        '現在是時間晝上午下午夜'
        '十一點半四點五點半六八'
        '七點半一九點半四十五分'
        '四十分三十五分零五分七'
        '六二十五分二十分五十分'
        '五三點半六點十二點半點'
        '十點八點三十分一零五分'
        '六三五十五分二十五分整'
        '三四十五分五十分二十分'
        '二十分八四十分三十五分',
  ),
  minuteIncrement: 5,
);
