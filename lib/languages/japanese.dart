import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/japanese_time_to_words.dart';

final japaneseLanguage = WordClockLanguage(
  id: 'JP',
  languageCode: 'ja-JP',
  displayName: '日本語',
  englishName: 'Japanese',
  description: null,
  timeToWords: JapaneseTimeToWords(),
  paddingAlphabet: '一七三九二五八六分前十午四後時',
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "現在の時刻は一一時時二"
        "一時半七時七時半三時八"
        "三時半時九時九時半二時"
        "二時半七五時五時半八時"
        "八時半六時六時半十一時"
        "十一時半十二時十二時半"
        "十時十時半四時時まで前"
        "あと後四二十五分二十分"
        "五分十五分十分四時半八"
        "時六五分後分十一八です",
  ),
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
  requiresPadding: false,
  atomizePhrases: true,
);
