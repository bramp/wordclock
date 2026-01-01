import 'package:wordclock/languages/language.dart';
import 'package:wordclock/logic/dutch_time_to_words.dart';
import 'package:wordclock/logic/time_to_words.dart';
import 'package:wordclock/model/word_grid.dart';

class DutchLanguage implements WordClockLanguage {
  @override
  String get displayName => 'Nederlands';

  @override
  final TimeToWords timeToWords = DutchTimeToWords();

  @override
  final String paddingAlphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  @override
  final int minuteIncrement = 5;

  @override
  WordGrid? get defaultGrid => null;
}
