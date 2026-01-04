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
        "ESTISCHBSAS"
        "VIERTUFÜFIU"
        "HPZWÄNZGZÄÄ"
        "ABVOROHAUBI"
        "EISPTSÄCHSI"
        "AVIERIACHTI"
        "NÜNIMZÄNIAR"
        "TEUFIRDRÜBE"
        "ZWÖIEQHFÜFI"
        "ZWÖUFISIBNI",
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
        "ESLISTGFÜNF"
        "ZEHNGFMWVOR"
        "DREIVIERTEL"
        "NACHXKGHALB"
        "ELFVIERACHT"
        "ZWEIGGZWÖLF"
        "JDREIUEINSU"
        "SIEBENSECHS"
        "ZEHNZLFÜNFX"
        "LAWNEUNNUHR",
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
        "ESEISCHXGIG"
        "DREIVIERTLÜ"
        "XFÜNFEDZEHN"
        "VORNXFNACHA"
        "HHALBRZWOIE"
        "ACHTEFÜNFEE"
        "ELFELNEUNED"
        "VIEREZWÖLFE"
        "KTZEHNEOISE"
        "DREIESECHSE"
        "GTLNSIEBNEE",
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
  // Seed: 1
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "ESGISTPZEHN"
        "IFÜNFWNNACH"
        "JJNVORJHALB"
        "DREIVIERTEL"
        "ZEHNKISECHS"
        "ELFEINSDREI"
        "SIEBENFÜNFU"
        "WJVIERUACHT"
        "PZWEIWNEUNG"
        "LAZWÖLFAUHR",
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
  // Seed: 8
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "ESFISTMNFJJ"
        "ZWANZIGZEHN"
        "VIERTELFÜNF"
        "XVORPUNACHL"
        "PHALBNDREIM"
        "ZWÖLFSIEBEN"
        "JNFACHTZWEI"
        "ELFNEUNZEHN"
        "FÜNFFSECHSU"
        "EINSUHRVIER",
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
