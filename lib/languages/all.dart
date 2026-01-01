import 'package:wordclock/languages/language.dart';
import 'package:wordclock/languages/english.dart';
import 'package:wordclock/languages/spanish.dart';
import 'package:wordclock/languages/german.dart';
import 'package:wordclock/languages/french.dart';
import 'package:wordclock/languages/portuguese.dart';
import 'package:wordclock/languages/italian.dart';
import 'package:wordclock/languages/dutch.dart';
import 'package:wordclock/languages/russian.dart';
import 'package:wordclock/languages/polish.dart';
import 'package:wordclock/languages/japanese.dart';

class WordClockLanguages {
  /// Mapping of language identifiers to their implementations.
  static final Map<String, WordClockLanguage> byId = {
    'en': EnglishLanguage(),
    'es': SpanishLanguage(),
    'de': GermanLanguage(),
    'fr': FrenchLanguage(),
    'pt': PortugueseLanguage(),
    'it': ItalianLanguage(),
    'nl': DutchLanguage(),
    'ru': RussianLanguage(),
    'pl': PolishLanguage(),
    'ja': JapaneseLanguage(),
  };

  static List<WordClockLanguage> get all => byId.values.toList();
}
