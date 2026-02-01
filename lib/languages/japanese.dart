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
    // Generated: 2026-01-31T16:35:42.587600
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 34, Duration: 12ms
    WordClockGrid(
      isDefault: true,
      timeToWords: JapaneseTimeToWords(),
      paddingAlphabet: '一七三九二五八六分前十午四後時',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            '現在の時刻は一時二二八' // 現在の時刻は
            '八時七七時前後十二時半' // 十二時半 十二時 二時半 二時
            '三四十一時半八時六時半' // 十一時半 十一時 一時半 一時 六時半 六時
            '六五分後分十一八七時半' // 七時半 七時
            '八五六八時半七二十時半' // 八時半 八時 十時半 十時
            '四十一三時半分七三四時' // 三時半 三時 四時
            '分午二四時半六時五時半' // 四時半 五時半 五時
            '分七八九時半前時分まで' // 九時半 九時 まで
            '九十後あと後十二十五分' // あと 二十五分 十五分 五分
            '三四六六二時二十分です', // 二十分 十分 です
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
  atomizePhrases: false,
);
