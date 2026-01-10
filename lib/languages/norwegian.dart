import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/norwegian_time_to_words.dart';

final norwegianLanguage = WordClockLanguage(
  id: 'NO',
  languageCode: 'nb-NO',
  displayName: 'Norsk',
  englishName: 'Norwegian',
  description: null,
  timeToWords: NorwegianTimeToWords(),
  paddingAlphabet: 'ABDEFGHILMNOPSUVXZl',
  // Seed: 0
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "KLOKKENEERZ"
        "KVARTFEMTlU"
        "OVERPÅUHALV"
        "ELLEVEBTOLV"
        "FlRESEKSFEM"
        "ÅTTETTRESYV"
        "VZLFllTlVNI"
        "VMVNUMAIFGZ"
        "HHFGAPNFIGS"
        "lNBLMAEOAMN",
  ),
  timeCheckGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        'KLOKKENVERM'
        'FEMHPÅSUFIS'
        'TlLPÅSIDOSN'
        'KVARTNPÅSTO'
        'OVERXAMBPMZ'
        'HALVBlEGENZ'
        'ETTNTOATREX'
        'FlREFEMSEKS'
        'SYVÅTTENITl'
        'ELLEVESTOLV',
  ),
  minuteIncrement: 5,
);
