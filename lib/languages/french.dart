import 'package:wordclock/languages/language.dart';
import 'package:wordclock/logic/french_time_to_words.dart';
import 'package:wordclock/logic/time_to_words.dart';
import 'package:wordclock/model/word_grid.dart';

class FrenchLanguage implements WordClockLanguage {
  @override
  String get displayName => 'Français';

  @override
  final TimeToWords timeToWords = FrenchTimeToWords();

  @override
  final String paddingAlphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÂÇÉÈÊËÎÏÔÛÙ';

  @override
  final int minuteIncrement = 5;

  @override
  WordGrid? get defaultGrid => null;
}
