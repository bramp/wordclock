import 'package:wordclock/logic/time_to_words.dart';
import 'package:wordclock/model/word_grid.dart';

abstract class WordClockLanguage {
  String get displayName;
  TimeToWords get timeToWords;
  String get paddingAlphabet;
  WordGrid? get defaultGrid;
}
