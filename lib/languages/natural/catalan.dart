import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/languages/natural/catalan_time_to_words.dart';

final catalanLanguage = WordClockLanguage(
  id: 'CA',
  languageCode: 'ca-ES',
  displayName: 'Català',
  englishName: 'Catalan',
  description: null,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-01-31T21:51:07.610928
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 83, Duration: 7ms
    WordClockGrid(
      isDefault: true,
      timeToWords: CatalanTimeToWords(),
      paddingAlphabet: 'ADEMNOPRUZ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'SÓNÉSDOSLES' // SÓN ÉS DOS LES
            'UNOLAZQUART' // UN LA QUART
            'TRESONZEUNA' // TRES ONZE UNA
            'NZQUARTSPDI' // QUARTS I
            'NMENYSDCINC' // MENYS CINC
            'D\'ONZED\'UNADE' // D'ONZE D'UNA DE
            'QUATREDOTZE' // QUATRE DOTZE
            'TRESVUITDEU' // TRES VUIT DEU
            'DUESISETNOU' // DUES SIS SET NOU
            'MENYSIDCINC', // MENYS I CINC
      ),
    ),
    // @generated end,
    WordClockGrid(
      isReference: true,
      timeToWords: ReferenceCatalanTimeToWords(),
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
