import 'package:wordclock/languages/language.dart';
import 'package:wordclock/logic/japanese_time_to_words.dart';
import 'package:wordclock/logic/time_to_words.dart';
import 'package:wordclock/model/word_grid.dart';

class JapaneseLanguage implements WordClockLanguage {
  @override
  String get displayName => '日本語';

  @override
  final TimeToWords timeToWords = JapaneseTimeToWords();

  @override
  final String paddingAlphabet = '東西南北春夏秋冬日月火水木金土山川海空星花鳥風月上下左右中心光闇世界';

  @override
  WordGrid? get defaultGrid => null;
}
