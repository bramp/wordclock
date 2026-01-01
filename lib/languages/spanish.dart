import 'package:wordclock/languages/language.dart';
import 'package:wordclock/logic/spanish_time_to_words.dart';
import 'package:wordclock/logic/time_to_words.dart';
import 'package:wordclock/model/word_grid.dart';

class SpanishLanguage implements WordClockLanguage {
  @override
  String get displayName => 'Español';

  @override
  final TimeToWords timeToWords = SpanishTimeToWords();

  @override
  final String paddingAlphabet = 'ABCDEFGHIJKLMNÑOPQRSTUVWXYZ';

  @override
  final int minuteIncrement = 5;

  @override
  WordGrid? get defaultGrid => null;
}
