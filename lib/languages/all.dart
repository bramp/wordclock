import 'package:wordclock/languages/language.dart';

import 'package:wordclock/languages/conlangs/aurebesh.dart';
import 'package:wordclock/languages/conlangs/esperanto.dart';
import 'package:wordclock/languages/conlangs/high_valyrian.dart';
import 'package:wordclock/languages/conlangs/klingon.dart';
import 'package:wordclock/languages/conlangs/mando.dart';
import 'package:wordclock/languages/conlangs/quenya.dart';
import 'package:wordclock/languages/conlangs/sindarin.dart';
import 'package:wordclock/languages/natural/catalan.dart';
import 'package:wordclock/languages/natural/chinese.dart';
import 'package:wordclock/languages/natural/czech.dart';
import 'package:wordclock/languages/natural/danish.dart';
import 'package:wordclock/languages/natural/dutch.dart';
import 'package:wordclock/languages/natural/english.dart';
import 'package:wordclock/languages/natural/french.dart';
import 'package:wordclock/languages/natural/german.dart';
import 'package:wordclock/languages/natural/greek.dart';
// import 'package:wordclock/languages/natural/hebrew.dart';
import 'package:wordclock/languages/natural/italian.dart';
import 'package:wordclock/languages/natural/japanese.dart';
import 'package:wordclock/languages/natural/norwegian.dart';
// import 'package:wordclock/languages/natural/polish.dart';
import 'package:wordclock/languages/natural/portuguese.dart';
// import 'package:wordclock/languages/natural/romanian.dart';
// import 'package:wordclock/languages/natural/russian.dart';
import 'package:wordclock/languages/natural/spanish.dart';
import 'package:wordclock/languages/natural/swedish.dart';
import 'package:wordclock/languages/natural/tamil.dart';
import 'package:wordclock/languages/natural/turkish.dart';

class WordClockLanguages {
  static final List<WordClockLanguage> all = [
    // keep-sorted start
    aurebeshLanguage,
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
    esperantoLanguage,
    frenchLanguage,
    germanAlternativeLanguage,
    germanLanguage,
    greekLanguage,
    // hebrewLanguage,
    highValyrianLanguage,
    italianLanguage,
    japaneseLanguage,
    klingonLanguage,
    klingonPiqadLanguage,
    mandoLanguage,
    norwegianLanguage,
    // polishLanguage,
    portugueseLanguage,
    quenyaLanguage,
    sindarinLanguage,
    // romanianLanguage,
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

  static WordClockLanguage? findByCode(String code) {
    try {
      return all.firstWhere(
        (l) => l.languageCode.toLowerCase() == code.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}
