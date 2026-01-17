import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/japanese_time_to_words.dart';

final japaneseLanguage = WordClockLanguage(
  id: 'JP',
  languageCode: 'ja-JP',
  displayName: '日本語',
  englishName: 'Japanese',
  description: null,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-01-16T16:56:41.859678
    // Algorithm: Trie
    // Seed: 0
    // Iterations: 66, Duration: 2ms
    WordClockGrid(
      isDefault: true,
      timeToWords: JapaneseTimeToWords(),
      paddingAlphabet: '一七三九二五八六分前十午四後時',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            '現在の時刻は十時十五時' // 現 在 の 時 刻 は 十 時 十 五 時
            '十五三時十五四時十五六' // 十 五 三 時 十 五 四 時 十 五 六
            '時十五七時十五八時十五' // 時 十 五 七 時 十 五 八 時 十 五
            '九時十五二時十五二十五' // 九 時 十 五 二 時 十 五 二 十 五
            '一時十五二十五半ま分で' // 一 時 十 五 二 十 五 半 ま 分 で
            '一あと十五二十五分です' // あ と 十 五 二 十 五 分 で す
            '時二二八八時七七時前後'
            '三四八時六五分後分十一'
            '八八五六七二四十一分七'
            '三分午二六時分七八前時',
      ),
    ),
    // @generated end,
    WordClockGrid(
      isTimeCheck: true,
      timeToWords: JapaneseTimeToWords(),
      paddingAlphabet: '一七三九二五八六分前十午四後時',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            '現在の時刻は六午前午後'
            '一四時半七八分時九二五'
            '五時半七時半二十一時半'
            '十二時半十時半八時半一'
            '九時半六時半三時半です'
            '二十五分六九五分四まで'
            'あと三五分十分八二六七'
            '二十分九時六一十五分八'
            '四二十五分二十分六九三'
            '六十五分二四三一五です',
      ),
    ),
  ],
  minuteIncrement: 5,
  requiresPadding: false,
  atomizePhrases: true,
);
