import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/german_time_to_word.dart';

final berneseGermanLanguage = WordClockLanguage(
  id: 'CH',
  languageCode: 'gsw-CH',
  displayName: 'Bärndütsch',
  englishName: 'Bernese German',
  description: 'Bernese German',
  timeToWords: BerneseGermanTimeToWords(),
  paddingAlphabet: 'ABEFHIKLMOPQRSTU',
  // Seed: 0
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "ESUISCHBFÜF"
        "RVIERTUFZÄÄ"
        "TZWÄNZGLVOR"
        "TOABOOHAUBI"
        "SÄCHSIVIERI"
        "ZWÖUFIACHTI"
        "LSIBNIEFÜFI"
        "EUFIZÄNIDRÜ"
        "ZWÖINÜNIEIS"
        "MMFTBSASQUT",
  ),
  timeCheckGrid: WordGrid.fromLetters(
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
  minuteIncrement: 5,
);

final germanAlternativeLanguage = WordClockLanguage(
  id: 'D2',
  languageCode: 'de-DE-x-alt',
  displayName: 'Deutsch',
  englishName: 'German',
  description: 'Alternative',
  timeToWords: GermanAlternativeTimeToWords(),
  paddingAlphabet: 'AFGIJKLMNPUWXZ',
  // Seed: 0
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "ESPISTKEINL"
        "DREIVIERTEL"
        "WZEHNGIFÜNF"
        "GPNACHFIVOR"
        "HALBPSIEBEN"
        "ZWÖLFUSECHS"
        "ZEHNFÜNFELF"
        "ACHTLDREINS"
        "GZWEIMNNEUN"
        "MWGVIERFUHR",
  ),
  timeCheckGrid: WordGrid.fromLetters(
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
  minuteIncrement: 5,
);

final swabianGermanLanguage = WordClockLanguage(
  id: 'D3',
  languageCode: 'de-DE-x-swabian',
  displayName: 'Deutsch',
  englishName: 'German',
  description: 'Alternative 2',
  timeToWords: SwabianGermanTimeToWords(),
  paddingAlphabet: 'ABDEFGHIKLNRTUVXÜ',
  // Seed: 0
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "ESÜISCHAAHV"
        "UDREIVIERTL"
        "DFÜNFÜAZEHN"
        "AVNACHINVOR"
        "HALBEZWÖLFE"
        "SIEBNEDREIE"
        "SECHSEVIERE"
        "ZEHNEUNELFE"
        "ZWOIEEFÜNFE"
        "XOISEGACHTE",
  ),
  timeCheckGrid: WordGrid.fromLetters(
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
  minuteIncrement: 5,
);

final eastGermanLanguage = WordClockLanguage(
  id: 'D4',
  languageCode: 'de-DE-x-east',
  displayName: 'Deutsch',
  englishName: 'German',
  description: 'Alternative 3',
  timeToWords: EastGermanTimeToWords(),
  paddingAlphabet: 'AFGIJKLMNPUWXZ',
  // Seed: 0
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "ESPISTKEINL"
        "DREIVIERTEL"
        "WZEHNGIFÜNF"
        "GPNACHFIVOR"
        "HALBPSIEBEN"
        "ZWÖLFUSECHS"
        "ZEHNFÜNFELF"
        "NEUNLZWEINS"
        "GACHTMNDREI"
        "MWGVIERFUHR",
  ),
  timeCheckGrid: WordGrid.fromLetters(
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
  minuteIncrement: 5,
);

final germanLanguage = WordClockLanguage(
  id: 'DE',
  languageCode: 'de-DE',
  displayName: 'Deutsch',
  englishName: 'German',
  description: null,
  timeToWords: GermanTimeToWords(),
  paddingAlphabet: 'AFJKLMNPUX',
  // Seed: 0
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "ESMISTXHALB"
        "VIERTELLEIN"
        "ZWANZIGZEHN"
        "XFÜNFNFNACH"
        "LFVORFXHALB"
        "SIEBENSECHS"
        "XZWÖLFUZEHN"
        "NEUNACHTELF"
        "ZWEIJDREINS"
        "VIERFÜNFUHR",
  ),
  timeCheckGrid: WordGrid.fromLetters(
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
  minuteIncrement: 5,
);
