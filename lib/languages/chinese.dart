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
  // Seed: 0
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "现在时五分整昼一分分五"
        "昼八整间六三上三二下点"
        "整三二七五午点八整二六"
        "九七点二夜二十八十五是"
        "是二十一二二整点二三五"
        "五点整二四点分点分三三"
        "七零七一二一四六十是十"
        "三七五五整点八半三二三"
        "一六分二八四十分零十点"
        "十六七二八二是五十五分",
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
  atomizePhrases: true,
);

final chineseTraditionalLanguage = WordClockLanguage(
  id: 'CT',
  languageCode: 'zh-Hant-TW',
  displayName: '繁體中文',
  englishName: 'Chinese',
  description: 'Traditional',
  timeToWords: ChineseTraditionalTimeToWords(),
  paddingAlphabet: '一七三二五八六分十整是晝點',
  // Seed: 0
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "現在時五分整晝一分分五"
        "晝八整間六三上三二下點"
        "整三二七五午點八整二六"
        "九七點二夜二十八十五是"
        "是二十一二二整點二三五"
        "五點整二四點分點分三三"
        "七零七一二一四六十是十"
        "三七五五整點八半三二三"
        "一六分二八四十分零十點"
        "十六七二八二是五十五分",
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
  atomizePhrases: true,
);
