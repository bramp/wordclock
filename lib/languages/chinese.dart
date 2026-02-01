import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/chinese_time_to_words.dart';

final chineseSimplifiedLanguage = WordClockLanguage(
  id: 'CS',
  languageCode: 'zh-Hans-CN',
  displayName: '简体中文',
  englishName: 'Chinese',
  description: 'Simplified',
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-01-31T16:35:27.440393
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 37, Duration: 13ms
    WordClockGrid(
      isDefault: true,
      timeToWords: ChineseSimplifiedTimeToWords(),
      paddingAlphabet: '一七三二五八六分十整是昼点',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            '现在时间点整分七七整一' // 现在 时间
            '五五是六一五五分整下午' // 下午
            '昼一分上午夜分五八一点' // 上午 午夜 一点
            '八点三十分十一点半六点' // 八点三十分 八点 十一点半 十一点 一点半 六点
            '十十二点半九点半七点半' // 十二点半 十二点 二点 九点半 九点 七点半 七点
            '整点一五点半七五三点半' // 五点半 五点 三点半 三点
            '一昼八整十点六三三四点' // 十点 四点
            '四十五分五十五分五十分' // 四十五分 十五分 五十五分 五十分 十分
            '二十五分三十五分四十分' // 二十五分 三十五分 四十分
            '二点零五分二十分三十分', // 零五分 二十分 三十分
      ),
    ),
    // @generated end,
    WordClockGrid(
      isTimeCheck: true,
      timeToWords: ChineseSimplifiedTimeToWords(),
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
  atomizePhrases: false,
);

final chineseTraditionalLanguage = WordClockLanguage(
  id: 'CT',
  languageCode: 'zh-Hant-TW',
  displayName: '繁體中文',
  englishName: 'Chinese',
  description: 'Traditional',
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-01-31T16:35:28.002368
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 37, Duration: 12ms
    WordClockGrid(
      isDefault: true,
      timeToWords: ChineseTraditionalTimeToWords(),
      paddingAlphabet: '一七三二五八六分十整是晝點',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            '現在時間點整分七七整一' // 現在 時間
            '五五是六一五五分整下午' // 下午
            '晝一分上午夜分五八一點' // 上午 午夜 一點
            '八點三十分十一點半六點' // 八點三十分 八點 十一點半 十一點 一點半 六點
            '十十二點半九點半七點半' // 十二點半 十二點 二點 九點半 九點 七點半 七點
            '整點一五點半七五三點半' // 五點半 五點 三點半 三點
            '一晝八整十點六三三四點' // 十點 四點
            '四十五分五十五分五十分' // 四十五分 十五分 五十五分 五十分 十分
            '二十五分三十五分四十分' // 二十五分 三十五分 四十分
            '二點零五分二十分三十分', // 零五分 二十分 三十分
      ),
    ),
    // @generated end,
    WordClockGrid(
      isTimeCheck: true,
      timeToWords: ChineseTraditionalTimeToWords(),
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
  atomizePhrases: false,
);
