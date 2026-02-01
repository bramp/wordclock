import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/german_time_to_word.dart';

final berneseGermanLanguage = WordClockLanguage(
  id: 'CH',
  languageCode: 'gsw-CH',
  displayName: 'Bärndütsch',
  englishName: 'Bernese German',
  description: 'Bernese German',
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-01-31T17:11:19.192610
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 23, Duration: 14ms
    WordClockGrid(
      isDefault: true,
      timeToWords: BerneseGermanTimeToWords(),
      paddingAlphabet: 'ABEFHIKLMOPQRSTU',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ESUISCHBRFT' // ES ISCH
            'LTOOOLEMFÜF' // FÜF
            'VIERTUHAUBI' // VIERTU HAUBI
            'MZWÄNZGFZÄÄ' // ZWÄNZG ZÄÄ
            'VORABTHAUBI' // VOR AB HAUBI
            'ZWÖUFISIBNI' // ZWÖUFI SIBNI
            'SÄCHSIACHTI' // SÄCHSI ACHTI
            'ZWÖIVIERZÄÄ' // ZWÖI VIER ZÄÄ
            'FÜFINÜNIEIS' // FÜFI NÜNI EIS
            'BSAEUFISDRÜ', // EUFI DRÜ
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
  languageCode: 'de-DE-x-alt',
  displayName: 'Deutsch',
  englishName: 'German',
  description: 'Alternative',
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-01-25T09:42:53.137221
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 248, Duration: 4ms
    WordClockGrid(
      isDefault: true,
      timeToWords: ReferenceGermanAlternativeTimeToWords(),
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
            'ACHTLDREINS' // ACHT DREI EINS
            'GZWEIMNNEUN' // ZWEI NEUN
            'MWGVIERFUHR', // VIER UHR
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
  description: 'Alternative 2',
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-01-25T09:45:53.302029
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 5377, Duration: 6ms
    WordClockGrid(
      isDefault: true,
      timeToWords: ReferenceSwabianGermanTimeToWords(),
      paddingAlphabet: 'ABDEFGHIKLNRTUVXÜ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ESÜISCHAAHV' // ES ISCH
            'UDREIVIERTL' // DREIVIERTL VIERTL
            'DFÜNFÜAZEHN' // FÜNF ZEHN
            'AVNACHINVOR' // NACH VOR
            'HALBEZWÖLFE' // HALB ZWÖLFE
            'SIEBNEDREIE' // SIEBNE DREIE
            'SECHSEVIERE' // SECHSE VIERE
            'ZEHNEUNELFE' // ZEHNE NEUNE ELFE
            'ZWOIEEFÜNFE' // ZWOIE FÜNFE
            'XOISEGACHTE', // OISE ACHTE
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
  description: 'Alternative 3',
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-01-25T09:42:52.213769
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 248, Duration: 4ms
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
    // Generated: 2026-01-25T09:42:53.157910
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 27, Duration: 4ms
    WordClockGrid(
      isDefault: true,
      timeToWords: ReferenceGermanTimeToWords(),
      paddingAlphabet: 'AFJKLMNPUX',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ESMISTXHALB' // ES IST HALB
            'VIERTELLEIN' // VIERTEL EIN
            'ZWANZIGZEHN' // ZWANZIG ZEHN
            'XFÜNFNFNACH' // FÜNF NACH
            'LFVORFXHALB' // VOR HALB
            'SIEBENSECHS' // SIEBEN SECHS
            'XZWÖLFUZEHN' // ZWÖLF ZEHN
            'NEUNACHTELF' // NEUN ACHT ELF
            'ZWEIJDREINS' // ZWEI DREI EINS
            'VIERFÜNFUHR', // VIER FÜNF UHR
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
