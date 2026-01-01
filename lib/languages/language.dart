import 'package:wordclock/logic/time_to_words.dart';
import 'package:wordclock/model/word_grid.dart';

abstract class WordClockLanguage {
  TimeToWords get timeToWords;
  String get paddingAlphabet;
  WordGrid? get defaultGrid;
}
