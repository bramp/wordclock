import 'package:wordclock/languages/language.dart';
import 'package:wordclock/logic/german_time_to_word.dart';
import 'package:wordclock/logic/time_to_words.dart';
import 'package:wordclock/model/word_grid.dart';

class GermanLanguage implements WordClockLanguage {
  @override
  String get displayName => 'Deutsch';

  @override
  final TimeToWords timeToWords = GermanTimeToWords();

  @override
  final String paddingAlphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜẞ';

  @override
  final int minuteIncrement = 5;

  @override
  WordGrid? get defaultGrid => null;
}
