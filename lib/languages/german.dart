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
    WordClockGrid(
      isDefault: true,
      timeToWords: BerneseGermanTimeToWords(),
      paddingAlphabet: 'ABEFHIKLMOPQRSTU',
      grid: WordGrid.fromLetters(
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
    ),
    WordClockGrid(
      isTimeCheck: true,
      timeToWords: BerneseGermanTimeToWords(),
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
    WordClockGrid(
      isDefault: true,
      timeToWords: GermanAlternativeTimeToWords(),
      paddingAlphabet: 'AFGIJKLMNPUWXZ',
      grid: WordGrid.fromLetters(
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
    ),
    WordClockGrid(
      isTimeCheck: true,
      timeToWords: GermanAlternativeTimeToWords(),
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
    WordClockGrid(
      isDefault: true,
      timeToWords: SwabianGermanTimeToWords(),
      paddingAlphabet: 'ABDEFGHIKLNRTUVXÜ',
      grid: WordGrid.fromLetters(
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
    ),
    WordClockGrid(
      isTimeCheck: true,
      timeToWords: SwabianGermanTimeToWords(),
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
    WordClockGrid(
      isDefault: true,
      timeToWords: EastGermanTimeToWords(),
      paddingAlphabet: 'AFGIJKLMNPUWXZ',
      grid: WordGrid.fromLetters(
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
    ),
    WordClockGrid(
      isTimeCheck: true,
      timeToWords: EastGermanTimeToWords(),
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
    WordClockGrid(
      isDefault: true,
      timeToWords: GermanTimeToWords(),
      paddingAlphabet: 'AFJKLMNPUX',
      grid: WordGrid.fromLetters(
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
    ),
    WordClockGrid(
      isTimeCheck: true,
      timeToWords: GermanTimeToWords(),
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
