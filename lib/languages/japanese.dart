import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/japanese_time_to_words.dart';

final japaneseLanguage = WordClockLanguage(
  id: 'JP',
  languageCode: 'ja-JP',
  displayName: '日本語',
  description: null,
  timeToWords: JapaneseTimeToWords(),
  paddingAlphabet: '六午前午後一七八分時九二五二一六九四三五分八二六七九時六一八四六九三六二四三一五',
  timeCheckGrid: WordGrid.fromLetters(
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
  minuteIncrement: 5,
);
