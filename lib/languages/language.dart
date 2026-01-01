import 'package:wordclock/logic/time_to_words.dart';
import 'package:wordclock/model/word_grid.dart';

abstract class WordClockLanguage {
  String get displayName;
  TimeToWords get timeToWords;
  String get paddingAlphabet;
  WordGrid? get defaultGrid;

  /// The minute increment this language supports (e.g., 1 or 5).
  int get minuteIncrement;
}
