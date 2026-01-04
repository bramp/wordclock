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
  // Seed: 0
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "現在の時前後三四八時六"
        "五六時七二四刻十は一分"
        "七八前時分九四十三後七"
        "後九八後六二十時一七七"
        "十四後二午午五六一九三"
        "前時時前八二四七十一分"
        "前分二五分分時八一分後"
        "午ま午前一半五五七分で"
        "前あ後三と四午二後十七"
        "八七六七前七一五分です",
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
