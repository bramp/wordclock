import 'package:wordclock/languages/language.dart';
import 'package:wordclock/logic/portuguese_time_to_words.dart';
import 'package:wordclock/logic/time_to_words.dart';
import 'package:wordclock/model/word_grid.dart';

class PortugueseLanguage implements WordClockLanguage {
  @override
  String get displayName => 'Português';

  @override
  final TimeToWords timeToWords = PortugueseTimeToWords();

  @override
  final String paddingAlphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZÃÇÉÍÓÚ';

  @override
  final int minuteIncrement = 5;

  @override
  WordGrid? get defaultGrid => null;
}
