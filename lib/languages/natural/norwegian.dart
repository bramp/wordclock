import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/languages/natural/norwegian_time_to_words.dart';

final norwegianLanguage = WordClockLanguage(
  id: 'NO',
  languageCode: 'nb-NO',
  displayName: 'Norsk',
  englishName: 'Norwegian',
  description: null,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-01-31T21:51:13.154501
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 21, Duration: 3ms
    WordClockGrid(
      isDefault: true,
      timeToWords: NorwegianTimeToWords(),
      paddingAlphabet: 'ABDEFGHILMNOPSUVXZl',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'KLOKKENEERZ' // KLOKKEN ER
            'UKVARTUBFEM' // KVART FEM
            'VZLFllVVMTI' // TI
            'VNOVERUMAPÅ' // OVER PÅ
            'IFGZHHFHALV' // HALV
            'ELLEVEGTOLV' // ELLEVE TOLV TO
            'AFIREPNSEKS' // FIRE SEKS
            'FIGSlNBLFEM' // FEM
            'ÅTTETTRESYV' // ÅTTE ETT TRE SYV
            'MAEOAMTINNI', // TI NI
      ),
    ),
    // @generated end,
    WordClockGrid(
      isReference: true,
      timeToWords: ReferenceNorwegianTimeToWords(),
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
