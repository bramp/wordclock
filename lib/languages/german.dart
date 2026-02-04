import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/german_time_to_words.dart';

final berneseGermanLanguage = WordClockLanguage(
  id: 'CH',
  languageCode: 'gsw-CH',
  displayName: 'Bärndütsch',
  englishName: 'Bernese German',
  description: 'Bernese German',
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-01-31T21:51:07.271042
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 22, Duration: 14ms
    WordClockGrid(
      isDefault: true,
      timeToWords: BerneseGermanTimeToWords(),
      paddingAlphabet: 'ABEFHIKLMOPQRSTU',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ESUISCHBRFT' // ES ISCH
            'LTOOOLEMFÜF' // FÜF
            'MVIERTUFZÄÄ' // VIERTU ZÄÄ
            'TZWÄNZGBVOR' // ZWÄNZG VOR
            'SAABSQHAUBI' // AB HAUBI
            'SÄCHSIVIERI' // SÄCHSI VIERI
            'ZWÖUFIACHTI' // ZWÖUFI ACHTI
            'USIBNITFÜFI' // SIBNI FÜFI
            'EUFIZÄNIDRÜ' // EUFI ZÄNI DRÜ
            'ZWÖINÜNIEIS', // ZWÖI NÜNI EIS
      ),
    ),
    // @generated end,
    WordClockGrid(
      isReference: true,
      timeToWords: ReferenceBerneseGermanTimeToWords(),
      paddingAlphabet: 'ABEFHIKLMOPQRSTU',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ESKISCHAFÜF'
            'VIERTUBFZÄÄ'
            'ZWÄNZGSIVOR'
            'ABOHAUBIEPM'
            'EISZWÖISDRÜ'
            'VIERIFÜFIQT'
            'SÄCHSISIBNI'
            'ACHTINÜNIEL'
            'ZÄNIERBEUFI'
            'ZWÖUFIAMUHR',
      ),
    ),
  ],
  minuteIncrement: 5,
);

final germanAlternativeLanguage = WordClockLanguage(
  id: 'D2',
  languageCode: 'de-DE-x-alternative',
  displayName: 'Deutsch',
  englishName: 'German',
  description: 'Alternative',
  isAlternative: true,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-01-31T21:51:11.605973
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 23, Duration: 4ms
    WordClockGrid(
      isDefault: true,
      timeToWords: GermanAlternativeTimeToWords(),
      paddingAlphabet: 'AFGIJKLMNPUWXZ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ESPISTKZEHN' // ES IST ZEHN
            'VIERTELFÜNF' // VIERTEL FÜNF
            'LEINACHWVOR' // EIN NACH VOR
            'HALBGSIEBEN' // HALB SIEBEN
            'ZWÖLFISECHS' // ZWÖLF SECHS
            'ZEHNFÜNFELF' // ZEHN FÜNF ELF
            'GACHTPFEINS' // ACHT EINS
            'IDREIPUZWEI' // DREI ZWEI
            'LNEUNGMVIER' // NEUN VIER
            'NMWGFWKLUHR', // UHR
      ),
    ),
    // @generated end,
    WordClockGrid(
      isReference: true,
      timeToWords: ReferenceGermanAlternativeTimeToWords(),
      paddingAlphabet: 'AFGIJKLMNPUWXZ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ESKISTAFÜNF'
            'ZEHNZWANZIG'
            'DREIVIERTEL'
            'VORFUNKNACH'
            'HALBAELFÜNF'
            'EINSXAMZWEI'
            'DREIPMJVIER'
            'SECHSNLACHT'
            'SIEBENZWÖLF'
            'ZEHNEUNKUHR',
      ),
    ),
  ],
  minuteIncrement: 5,
);

final swabianGermanLanguage = WordClockLanguage(
  id: 'D3',
  languageCode: 'de-DE-x-swabian',
  displayName: 'Deutsch',
  englishName: 'German',
  description: 'Swabian',
  isAlternative: true,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-01-31T21:52:14.085825
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 22, Duration: 4ms
    WordClockGrid(
      isDefault: true,
      timeToWords: SwabianGermanTimeToWords(),
      paddingAlphabet: 'ABDEFGHIKLNRTUVXÜ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ESÜISCHAAHV' // ES ISCH
            'UDREIVIERTL' // DREIVIERTL VIERTL
            'DZEHNÜAFÜNF' // ZEHN FÜNF
            'AVNACHINVOR' // NACH VOR
            'EHALBEZWÖLF' // HALB ZWÖLF
            'XSECHSGZEHN' // SECHS ZEHN
            'FÜNFNEUNOIS' // FÜNF NEUN OIS
            'ZWOIDREIELF' // ZWOI DREI ELF
            'IVIERGHSIBE' // VIER SIBE
            'ÜFHXDBAACHT', // ACHT
      ),
    ),
    // @generated end,
    WordClockGrid(
      isReference: true,
      timeToWords: ReferenceSwabianGermanTimeToWords(),
      paddingAlphabet: 'ABDEFGHIKLNRTUVXÜ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ESKISCHFUNK'
            'DREIVIERTLA'
            'ZEHNBIEFÜNF'
            'NACHGERTVOR'
            'HALBXFÜNFEI'
            'OISECHSELFE'
            'ZWOIEACHTED'
            'DREIEZWÖLFE'
            'ZEHNEUNEUHL'
            'SIEBNEVIERE',
      ),
    ),
  ],
  minuteIncrement: 5,
);

final eastGermanLanguage = WordClockLanguage(
  id: 'D4',
  languageCode: 'de-DE-x-east',
  displayName: 'Deutsch',
  englishName: 'German',
  description: 'East',
  isAlternative: true,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-01-31T21:51:09.474692
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 248, Duration: 5ms
    WordClockGrid(
      isDefault: true,
      timeToWords: ReferenceEastGermanTimeToWords(),
      paddingAlphabet: 'AFGIJKLMNPUWXZ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ESPISTKEINL' // ES IST EIN
            'DREIVIERTEL' // DREIVIERTEL VIERTEL
            'WZEHNGIFÜNF' // ZEHN FÜNF
            'GPNACHFIVOR' // NACH VOR
            'HALBPSIEBEN' // HALB SIEBEN
            'ZWÖLFUSECHS' // ZWÖLF SECHS
            'ZEHNFÜNFELF' // ZEHN FÜNF ELF
            'NEUNLZWEINS' // NEUN ZWEI EINS
            'GACHTMNDREI' // ACHT DREI
            'MWGVIERFUHR', // VIER UHR
      ),
    ),
    // @generated end,
    WordClockGrid(
      isReference: true,
      timeToWords: ReferenceEastGermanTimeToWords(),
      paddingAlphabet: 'AFGIJKLMNPUWXZ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ESKISTAFÜNF'
            'ZEHNZWANZIG'
            'DREIVIERTEL'
            'VORFUNKNACH'
            'HALBAELFÜNF'
            'EINSXAMZWEI'
            'DREIPMJVIER'
            'SECHSNLACHT'
            'SIEBENZWÖLF'
            'ZEHNEUNKUHR',
      ),
    ),
  ],
  minuteIncrement: 5,
);

final germanLanguage = WordClockLanguage(
  id: 'DE',
  languageCode: 'de-DE',
  displayName: 'Deutsch',
  englishName: 'German',
  description: null,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-01-31T21:51:11.910679
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 23, Duration: 5ms
    WordClockGrid(
      isDefault: true,
      timeToWords: GermanTimeToWords(),
      paddingAlphabet: 'AFJKLMNPUX',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ESMISTXHALB' // ES IST HALB
            'VIERTELZEHN' // VIERTEL ZEHN
            'ZWANZIGFÜNF' // ZWANZIG FÜNF
            'LXNACHNFVOR' // NACH VOR
            'HALBLSIEBEN' // HALB SIEBEN
            'SECHSFZWÖLF' // SECHS ZWÖLF
            'ZEHNEINSELF' // ZEHN EINS ELF
            'FNEUNXXACHT' // NEUN ACHT
            'UZWEIJJFÜNF' // ZWEI FÜNF
            'FLDREIPVIER', // DREI VIER
      ),
    ),
    // @generated end,
    WordClockGrid(
      isReference: true,
      timeToWords: ReferenceGermanTimeToWords(),
      paddingAlphabet: 'AFJKLMNPUX',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ESKISTAFÜNF'
            'ZEHNZWANZIG'
            'DREIVIERTEL'
            'VORFUNKNACH'
            'HALBAELFÜNF'
            'EINSXAMZWEI'
            'DREIPMJVIER'
            'SECHSNLACHT'
            'SIEBENZWÖLF'
            'ZEHNEUNKUHR',
      ),
    ),
  ],
  minuteIncrement: 5,
);
