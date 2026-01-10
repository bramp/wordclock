import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/chinese_time_to_words.dart';

final chineseSimplifiedLanguage = WordClockLanguage(
  id: 'CS',
  languageCode: 'zh-Hans-CN',
  displayName: '简体中文',
  englishName: 'Chinese',
  description: 'Simplified',
  timeToWords: ChineseSimplifiedTimeToWords(),
  paddingAlphabet: '一七三二五八六分十整是昼点',
  // Seed: 0
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "现在时间下上午七九八六"
        "五四三夜十一二点四二三"
        "点整分七七半零五十五分"
        "整一五五是六一五五分整"
        "昼一分分五八十整点一七"
        "五一昼八整六三三二点一"
        "一六八七七十三整三二七"
        "五点整二八五二六十点二"
        "点二二十八五是二一五分"
        "五一整是二十二整二五七",
  ),
  timeCheckGrid: WordGrid.fromLetters(
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
  timeToWords: ChineseTraditionalTimeToWords(),
  paddingAlphabet: '一七三二五八六分十整是晝點',
  // Seed: 0
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "現在時間下上午七九八六"
        "五四三夜十一二點四二三"
        "點整分七七半零五十五分"
        "整一五五是六一五五分整"
        "晝一分分五八十整點一七"
        "五一晝八整六三三二點一"
        "一六八七七十三整三二七"
        "五點整二八五二六十點二"
        "點二二十八五是二一五分"
        "五一整是二十二整二五七",
  ),
  timeCheckGrid: WordGrid.fromLetters(
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
  minuteIncrement: 5,
  requiresPadding: false,
  atomizePhrases: true,
);
