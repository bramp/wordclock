import 'package:wordclock/languages/language.dart';
import 'package:wordclock/logic/russian_time_to_words.dart';
import 'package:wordclock/logic/time_to_words.dart';
import 'package:wordclock/model/word_grid.dart';

class RussianLanguage implements WordClockLanguage {
  @override
  String get displayName => 'Русский';

  @override
  final TimeToWords timeToWords = RussianTimeToWords();

  @override
  final String paddingAlphabet = 'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ';

  @override
  final int minuteIncrement = 5;

  @override
  WordGrid? get defaultGrid => null;
}
