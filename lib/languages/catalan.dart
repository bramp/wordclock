import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/catalan_time_to_words.dart';

final catalanLanguage = WordClockLanguage(
  id: 'CA',
  languageCode: 'ca-ES',
  displayName: 'Català',
  englishName: 'Catalan',
  description: null,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-01-25T09:42:49.110142
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 29, Duration: 4ms
    WordClockGrid(
      isDefault: true,
      timeToWords: CatalanTimeToWords(),
      paddingAlphabet: 'ADEMNOPRUZ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'SÓNÉSDOSLES' // SÓN ÉS DOS LES
            'UNOLAZQUART' // UN LA QUART
            'TRESNQUARTS' // TRES QUARTS
            'MENYSIZCINC' // MENYS I CINC
            'DED\'QUATRESP' // DE D' QUATRE TRES
            'DDOTZENVUIT' // DOTZE VUIT
            'DUESONZENOU' // DUES ONZE NOU
            'UNADSETDSIS' // UNA SET SIS
            'DEUZMENYSZI' // DEU MENYS I
            'UEEDNROCINC', // CINC
      ),
    ),
    // @generated end,
    WordClockGrid(
      isTimeCheck: true,
      timeToWords: CatalanTimeToWords(),
      paddingAlphabet: 'ADEMNOPRUZ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ÉSÓNRLAMUNA'
            'DOSLESNTRES'
            'CINCQUARTSU'
            'MENYSIECINC'
            'DED\'RUNAONZE'
            'DUESTRESETD'
            'QUATREDOTZE'
            'VUITNOUONZE'
            'SISAMDEUNPM'
            'MENYSIACINC',
      ),
    ),
  ],
  minuteIncrement: 5,
);
