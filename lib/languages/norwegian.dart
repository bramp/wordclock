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
    // Generated: 2026-01-16T16:56:41.866930
    // Algorithm: Trie
    // Seed: 0
    // Iterations: 25, Duration: 3ms
    WordClockGrid(
      isDefault: true,
      timeToWords: NorwegianTimeToWords(),
      paddingAlphabet: 'ABDEFGHILMNOPSUVXZl',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'KLOKKENEERZ' // KLOKKEN ER
            'FEMTlKVARTU' // FEM Tl KVART
            'OVERUFEMBTl' // OVER FEM Tl
            'VPÅZLFEMFTl' // PÅ FEM Tl
            'HALVlFEMlTl' // HALV FEM Tl
            'TOLVETTRENI' // TOLV TO ETT TRE NI
            'FlREVSEKSYV' // FlRE SEKS SYV
            'VMÅTTELLEVE' // ÅTTE ELLEVE
            'VNUMAIFGZHH'
            'FGAPNFIGSlN',
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
