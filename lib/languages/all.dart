import 'package:wordclock/languages/language.dart';
// import 'package:wordclock/languages/polish.dart';
import 'package:wordclock/languages/catalan.dart';
import 'package:wordclock/languages/chinese.dart';
import 'package:wordclock/languages/czech.dart';
import 'package:wordclock/languages/danish.dart';
import 'package:wordclock/languages/dutch.dart';
import 'package:wordclock/languages/english.dart';
import 'package:wordclock/languages/french.dart';
import 'package:wordclock/languages/german.dart';
import 'package:wordclock/languages/greek.dart';
// import 'package:wordclock/languages/hebrew.dart';
import 'package:wordclock/languages/italian.dart';
import 'package:wordclock/languages/japanese.dart';
import 'package:wordclock/languages/norwegian.dart';
import 'package:wordclock/languages/portuguese.dart';
import 'package:wordclock/languages/romanian.dart';
// import 'package:wordclock/languages/russian.dart';
import 'package:wordclock/languages/spanish.dart';
import 'package:wordclock/languages/swedish.dart';
import 'package:wordclock/languages/tamil.dart';
import 'package:wordclock/languages/turkish.dart';

class WordClockLanguages {
  static final List<WordClockLanguage> all = [
    // keep-sorted start
    berneseGermanLanguage,
    catalanLanguage,
    chineseSimplifiedLanguage,
    chineseTraditionalLanguage,
    czechLanguage,
    danishLanguage,
    dutchLanguage,
    eastGermanLanguage,
    englishAlternativeLanguage,
    englishLanguage,
    frenchLanguage,
    germanAlternativeLanguage,
    germanLanguage,
    greekLanguage,
    // hebrewLanguage,
    italianLanguage,
    japaneseLanguage,
    norwegianLanguage,
    // polishLanguage,
    portugueseLanguage,
    romanianLanguage,
    // russianLanguage,
    spanishLanguage,
    swabianGermanLanguage,
    swedishLanguage,
    tamilLanguage,
    turkishLanguage,
    // keep-sorted end
  ];

  static final Map<String, WordClockLanguage> byId = {
    for (final lang in all) lang.id: lang,
  };
}
