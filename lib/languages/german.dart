import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/german_time_to_word.dart';

final berneseGermanLanguage = WordClockLanguage(
  id: 'CH',
  languageCode: 'gsw-CH',
  displayName: 'Bärndütsch',
  description: 'Bernese German',
  timeToWords: BerneseGermanTimeToWords(),
  paddingAlphabet: 'ABEFHIKLMOPQRSTU',
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "ESUISCHBFÜF"
        "OOOVIERTULE"
        "FZWÄNZGZÄÄM"
        "ABVORTHAUBI"
        "ACHTIDRÜEIS"
        "EUFISFÜFIQU"
        "HPNÜNISIBNI"
        "SÄCHSIVIERI"
        "ZWÖIAZWÖUFI"
        "RPTTATMZÄNI",
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
  description: 'Alternative',
  timeToWords: GermanAlternativeTimeToWords(),
  paddingAlphabet: 'AFGIJKLMNPUWXZ',
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "ESPISTKLWGI"
        "DREIVIERTEL"
        "FÜNFIPZEHNG"
        "MWVORGEINFW"
        "GZAVIERTELK"
        "ANACHGHALBG"
        "ACHTUDREIUL"
        "EINSELFFÜNF"
        "NEUNLSECHSX"
        "LSIEBENVIER"
        "XZEHNZWEIXG"
        "KUZWÖLFAUHR",
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
  description: 'Alternative 2',
  timeToWords: SwabianGermanTimeToWords(),
  paddingAlphabet: 'ABDEFGHIKLNRTUVXÜ',
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "ESÜISCHAAHV"
        "DREIVIERTLD"
        "FÜNFAVIERTL"
        "ZEHNANNACHE"
        "GVOREHHALBX"
        "ACHTEDREIEF"
        "DBELFEFÜNFE"
        "NEUNETNOISE"
        "HKETÜSECHSE"
        "SIEBNEVIERE"
        "ZEHNEZWOIED"
        "XFKTGZWÖLFE",
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
  description: 'Alternative 3',
  timeToWords: EastGermanTimeToWords(),
  paddingAlphabet: 'AFGIJKLMNPUWXZ',
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "ESPISTKLWGI"
        "DREIVIERTEL"
        "EINVIERTELG"
        "FÜNFPUZEHNP"
        "MNACHVORWLG"
        "HALBFACHTLW"
        "DREIEINSELF"
        "AFÜNFGNEUNG"
        "SECHSSIEBEN"
        "JVIERUZEHNU"
        "NZWEIZWÖLFU"
        "ZLXNLAWXUHR",
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
  description: null,
  timeToWords: GermanTimeToWords(),
  paddingAlphabet: 'AFJKLMNPUX',
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "ESMISTXEINL"
        "FÜNFVIERTEL"
        "ZEHNZWANZIG"
        "NACHVORFFXX"
        "JHALBXFACHT"
        "DREIEINSELF"
        "FÜNFUNEUNKK"
        "SECHSSIEBEN"
        "NAVIERPZEHN"
        "JZWEIZWÖLFN"
        "AAUNJUNLUHR",
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
