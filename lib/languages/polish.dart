import 'package:wordclock/languages/language.dart';
import 'package:wordclock/logic/polish_time_to_words.dart';
import 'package:wordclock/logic/time_to_words.dart';
import 'package:wordclock/model/word_grid.dart';

class PolishLanguage implements WordClockLanguage {
  @override
  String get displayName => 'Polski';

  @override
  final TimeToWords timeToWords = PolishTimeToWords();

  @override
  final String paddingAlphabet = 'AĄBCĆDEĘFGHIJKLŁMNŃOÓPQRSŚTUVWXYZŹŻ';

  @override
  final int minuteIncrement = 5;

  @override
  WordGrid? get defaultGrid => null;
}
