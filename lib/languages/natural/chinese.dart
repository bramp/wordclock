import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/languages/natural/chinese_time_to_words.dart';

final chineseSimplifiedLanguage = WordClockLanguage(
  id: 'CS',
  languageCode: 'zh-Hans-CN',
  displayName: '简体中文',
  englishName: 'Chinese',
  description: 'Simplified',
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-01-31T21:51:07.923522
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 32, Duration: 7ms
    WordClockGrid(
      isDefault: true,
      timeToWords: ChineseSimplifiedTimeToWords(),
      paddingAlphabet: '一七三二五八六分十整是昼点',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            '现在是零点上午点整分七' // 现在是 零点 上午
            '七整一五晚上五是六凌晨' // 晚上 凌晨
            '一下午中午十一点十二点' // 下午 中午 十一点 一点 十二点
            '五五十点分整六点昼九点' // 十点 六点 九点
            '一分分五两点八十整八点' // 两点 八点
            '点一七点七五三点一五点' // 七点 三点 五点
            '昼八整四点六三三零五分' // 四点 零五分
            '三十五分五十五分二十分' // 三十五分 十五分 五十五分 二十分 十分
            '四十五分二十五分四十分' // 四十五分 二十五分 四十分
            '二点一一六八五十分整半', // 五十分 整 半
      ),
    ),
    // @generated end,
    WordClockGrid(
      isReference: true,
      timeToWords: ReferenceChineseSimplifiedTimeToWords(),
      paddingAlphabet: '一七三二五八六分十整是昼点',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            '现在是时间昼上午下午夜' //   现 在  时 间  上 午 下 午 夜
            '十一点半四点五点半六八' //   十 一 点 半 四 点 五 点 半 六 八
            '七点半一九点半四十五分' //   七 点 半 九 点 半 四 十 五 分
            '四十分三十五分零五分七' //   十 分 三 十 五 分 零 五 分
            '六二十五分二十分五十分' //   二 十 五 分
            '五三点半六点十二点半点' //   点 半 十 二
            '十点八点三十分一零五分' //   十 三 十 分 零 五 分
            '六三五十五分二十五分整' //   十 五 分
            '三四十五分五十分二十分' //   四 十 五 分
            '二十分八四十分三十五分',
      ),
    ),
  ],
  minuteIncrement: 5,
  requiresPadding: false,
);

final chineseTraditionalLanguage = WordClockLanguage(
  id: 'CT',
  languageCode: 'zh-Hant-TW',
  displayName: '繁體中文',
  englishName: 'Chinese',
  description: 'Traditional',
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-01-31T21:51:08.243023
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 32, Duration: 4ms
    WordClockGrid(
      isDefault: true,
      timeToWords: ChineseTraditionalTimeToWords(),
      paddingAlphabet: '一七三二五八六分十整是晝點',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            '現在是零點上午點整分七' // 現在是 零點 上午
            '七整一五晚上五是六凌晨' // 晚上 凌晨
            '一下午中午十一點十二點' // 下午 中午 十一點 一點 十二點
            '五五十點分整六點晝九點' // 十點 六點 九點
            '一分分五兩點八十整八點' // 兩點 八點
            '點一七點七五三點一五點' // 七點 三點 五點
            '晝八整四點六三三零五分' // 四點 零五分
            '三十五分五十五分二十分' // 三十五分 十五分 五十五分 二十分 十分
            '四十五分二十五分四十分' // 四十五分 二十五分 四十分
            '二點一一六八五十分整半', // 五十分 整 半
      ),
    ),
    // @generated end,
    WordClockGrid(
      isReference: true,
      timeToWords: ReferenceChineseTraditionalTimeToWords(),
      paddingAlphabet: '一七三二五八六分十整是晝點',
      grid: WordGrid.fromLetters(
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
    ),
  ],
  minuteIncrement: 5,
  requiresPadding: false,
);
