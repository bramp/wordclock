import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/norwegian_time_to_words.dart';

final norwegianLanguage = WordClockLanguage(
  id: 'NO',
  languageCode: 'nb-NO',
  displayName: 'Norsk',
  englishName: 'Norwegian',
  description: null,
  grids: [
    WordClockGrid(
      isDefault: true,
      timeToWords: NorwegianTimeToWords(),
      paddingAlphabet: 'ABDEFGHILMNOPSUVXZl',
      grid: WordGrid.fromLetters(
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
    ),
    WordClockGrid(
      isTimeCheck: true,
      timeToWords: NorwegianTimeToWords(),
      paddingAlphabet: 'ABDEFGHILMNOPSUVXZ',
      grid: WordGrid.fromLetters(
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
    ),
  ],
  minuteIncrement: 5,
);
