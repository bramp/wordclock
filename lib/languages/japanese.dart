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
    // Generated: 2026-01-31T21:51:12.852609
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 24, Duration: 4ms
    WordClockGrid(
      isDefault: true,
      timeToWords: JapaneseTimeToWords(),
      paddingAlphabet: '一七三九二五八六分前十午四後時',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ただいま十一時一時二二' // ただいま 十一時 一時
            '八八時七七時前後十二時' // 十二時 二時
            '三四八時三時六五分四時' // 三時 四時
            '後分十一八八五六七零時' // 零時
            '二四十一五時分七三六時' // 五時 六時
            '分午二六七時時分七八時' // 七時 八時
            '八前時分九十後後十九時' // 九時
            '三四十時六六まで二時半' // 十時 まで 半
            '後九後あと二時二十五分' // あと 二十五分 十五分 五分
            '一七七八前四二十分です', // 二十分 十分 です
      ),
    ),
    // @generated end,
    WordClockGrid(
      isReference: true,
      timeToWords: ReferenceJapaneseTimeToWords(),
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
);
