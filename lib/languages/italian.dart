import 'package:wordclock/languages/language.dart';
import 'package:wordclock/logic/italian_time_to_words.dart';
import 'package:wordclock/logic/time_to_words.dart';
import 'package:wordclock/model/word_grid.dart';

class ItalianLanguage implements WordClockLanguage {
  @override
  String get displayName => 'Italiano';

  @override
  final TimeToWords timeToWords = ItalianTimeToWords();

  @override
  final String paddingAlphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÈÉÌÒÙ';

  @override
  final int minuteIncrement = 5;

  @override
  WordGrid? get defaultGrid => null;
}
