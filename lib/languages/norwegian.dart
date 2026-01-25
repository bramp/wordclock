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
    // @generated begin - do not edit manually
    // Generated: 2026-01-25T09:42:53.210299
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 21, Duration: 2ms
    WordClockGrid(
      isDefault: true,
      timeToWords: NorwegianTimeToWords(),
      paddingAlphabet: 'ABDEFGHILMNOPSUVXZl',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'KLOKKENEERZ' // KLOKKEN ER
            'KVARTFEMTlU' // KVART FEM Tl
            'OVERPÅUHALV' // OVER PÅ HALV
            'ELLEVEBTOLV' // ELLEVE TOLV TO
            'FlRESEKSFEM' // FlRE SEKS FEM
            'ÅTTETTRESYV' // ÅTTE ETT TRE SYV
            'VZLFllTlVNI' // Tl NI
            'VMVNUMAIFGZ'
            'HHFGAPNFIGS'
            'lNBLMAEOAMN',
      ),
    ),
    // @generated end,
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
