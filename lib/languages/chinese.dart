import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/chinese_time_to_words.dart';

final chineseSimplifiedLanguage = WordClockLanguage(
  id: 'CS',
  languageCode: 'zh-Hans-CN',
  displayName: '简体中文',
  englishName: 'Chinese',
  description: 'Simplified',
  timeToWords: ChineseSimplifiedTimeToWords(),
  paddingAlphabet: '一七三二五八六分十整是昼点',
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "现在点时间整上午下午分"
        "一点一点半七点七点半七"
        "三点一三点半九点九点半"
        "二点是六五点五点半八点"
        "八点三十分六点五十一点"
        "十一点半昼十点四点五一"
        "三十分午夜分十二点分八"
        "三十五分二十五分二十分"
        "五十五分五十分整十五分"
        "七十分四十五分五四十分"
        "一昼八整零五分十二点半",
  ),
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
  requiresPadding: false,
);

final chineseTraditionalLanguage = WordClockLanguage(
  id: 'CT',
  languageCode: 'zh-Hant-TW',
  displayName: '繁體中文',
  englishName: 'Chinese',
  description: 'Traditional',
  timeToWords: ChineseTraditionalTimeToWords(),
  paddingAlphabet: '一七三二五八六分十整是晝點',
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "現在點時間整上午下午分"
        "一點一點半七點七點半七"
        "三點一三點半九點九點半"
        "二點是六五點五點半八點"
        "八點三十分六點五十一點"
        "十一點半晝十點四點五一"
        "三十分午夜分十二點分八"
        "三十五分二十五分二十分"
        "五十五分五十分整十五分"
        "七十分四十五分五四十分"
        "一晝八整零五分十二點半",
  ),
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
  requiresPadding: false,
);
