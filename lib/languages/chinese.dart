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
    // Generated: 2026-01-25T09:42:49.132306
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 29, Duration: 2ms
    WordClockGrid(
      isDefault: true,
      timeToWords: ChineseSimplifiedTimeToWords(),
      paddingAlphabet: '一七三二五八六分十整是昼点',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            '现在时间下上午七九八六' // 现 在 时 间 下 上 午 七 九 八 六
            '五四三夜十一二点四二三' // 五 四 三 夜 十 一 二 点 四 二 三
            '点整分七七半零五十五分' // 半 零 五 十 五 分
            '整一五五是六一五五分整'
            '昼一分分五八十整点一七'
            '五一昼八整六三三二点一'
            '一六八七七十三整三二七'
            '五点整二八五二六十点二'
            '点二二十八五是二一五分'
            '五一整是二十二整二五七',
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
    ),
  ],
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
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-01-25T09:42:49.144095
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 29, Duration: 1ms
    WordClockGrid(
      isDefault: true,
      timeToWords: ChineseTraditionalTimeToWords(),
      paddingAlphabet: '一七三二五八六分十整是晝點',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            '現在時間下上午七九八六' // 現 在 時 間 下 上 午 七 九 八 六
            '五四三夜十一二點四二三' // 五 四 三 夜 十 一 二 點 四 二 三
            '點整分七七半零五十五分' // 半 零 五 十 五 分
            '整一五五是六一五五分整'
            '晝一分分五八十整點一七'
            '五一晝八整六三三二點一'
            '一六八七七十三整三二七'
            '五點整二八五二六十點二'
            '點二二十八五是二一五分'
            '五一整是二十二整二五七',
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
  atomizePhrases: true,
);
