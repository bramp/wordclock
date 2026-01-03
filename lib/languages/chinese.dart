import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/chinese_time_to_words.dart';

const chineseSimplifiedLanguage = WordClockLanguage(
  id: 'CS',
  languageCode: 'zh-Hans-CN',
  displayName: 'Chinese',
  description: 'Simplified',
  timeToWords: ChineseSimplifiedTimeToWords(),
  paddingAlphabet: '是昼六八一七六五点一六三整三二十分八',
  timeCheckGrid: WordGrid(
    width: 11,
    letters:
        '现在是时间昼上午下午夜十一点半四点五点半六八七点半一九点半四十五分四十分三十五分零五分七六二十五分二十分五十分五三点半六点十二点半点十点八点三十分一零五分六三五十五分二十五分整三四十五分五十分二十分二十分八四十分三十五分',
  ),
  minuteIncrement: 5,
);

const chineseTraditionalLanguage = WordClockLanguage(
  id: 'CT',
  languageCode: 'zh-Hant-TW',
  displayName: 'Chinese',
  description: 'Traditional',
  timeToWords: ChineseTraditionalTimeToWords(),
  paddingAlphabet: '是晝六八一七六五點一六三整三二十分八',
  timeCheckGrid: WordGrid(
    width: 11,
    letters:
        '現在是時間晝上午下午夜十一點半四點五點半六八七點半一九點半四十五分四十分三十五分零五分七六二十五分二十分五十分五三點半六點十二點半點十點八點三十分一零五分六三五十五分二十五分整三四十五分五十分二十分二十分八四十分三十五分',
  ),
  minuteIncrement: 5,
);
