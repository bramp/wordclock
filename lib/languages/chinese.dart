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
    // Generated: 2026-01-16T16:56:16.142050
    // Algorithm: Trie
    // Seed: 0
    // Iterations: 32, Duration: 2ms
    WordClockGrid(
      isDefault: true,
      timeToWords: ChineseSimplifiedTimeToWords(),
      paddingAlphabet: '一七三二五八六分十整是昼点',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            '现在时间上下午夜五三四' // 现 在 时 间 上 下 午 夜 五 三 四
            '六七八九十二一点五三四' // 六 七 八 九 十 二 一 点 五 三 四
            '点整十五二十五零五半分' // 十 五 二 十 五 零 五 半 分
            '分七七整一五五是六一五'
            '五分整昼一分分五八十整'
            '点一七五一昼八整六三三'
            '二点一一六八七七十三整'
            '三二七五点整二八五二六'
            '十点二点二二十八五是二'
            '一五分五一整是二十二整',
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
    // Generated: 2026-01-16T16:56:16.158808
    // Algorithm: Trie
    // Seed: 0
    // Iterations: 32, Duration: 1ms
    WordClockGrid(
      isDefault: true,
      timeToWords: ChineseTraditionalTimeToWords(),
      paddingAlphabet: '一七三二五八六分十整是晝點',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            '現在時間上下午夜五三四' // 現 在 時 間 上 下 午 夜 五 三 四
            '六七八九十二一點五三四' // 六 七 八 九 十 二 一 點 五 三 四
            '點整十五二十五零五半分' // 十 五 二 十 五 零 五 半 分
            '分七七整一五五是六一五'
            '五分整晝一分分五八十整'
            '點一七五一晝八整六三三'
            '二點一一六八七七十三整'
            '三二七五點整二八五二六'
            '十點二點二二十八五是二'
            '一五分五一整是二十二整',
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
