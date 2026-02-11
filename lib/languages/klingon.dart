import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/klingon_time_to_words.dart';

final klingonLanguage = WordClockLanguage(
  id: 'KL',
  languageCode: 'tlh',
  displayName: 'tlhIngan Hol',
  englishName: 'Klingon',
  description: "Star Trek's Klingon language",
  isAlternative: true,
  isHidden: true,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-02-10T22:45:00.006163
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 19, Duration: 14ms
    WordClockGrid(
      isDefault: true,
      timeToWords: KlingonTimeToWords(),
      paddingAlphabet: 'abcdeghIjklmnofpqrStxuvwyz',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'wazmahkcorg' // wazmah corg
            'hutwejloSoc' // hut wej loS Soc
            'vagajavrwaz' // vag jav waz
            'rcazwtarepe' // caz rep
            'eIwazmahvmo' // wazmah
            'xIcazmahrgj' // cazmah
            'knvagmahabe' // vagmah
            'aywejmahSvh' // wejmah
            'cloSmahcvag' // loSmah vag
            'qnaatSfftup', // tup
      ),
    ),
    // @generated end,
  ],
  minuteIncrement: 5,
);

final klingonPiqadLanguage = WordClockLanguage(
  id: 'KP',
  languageCode: 'tlh-Piqd',
  // TODO Change the display name to pIqaD script
  displayName: 'tlhIngan Hol',
  englishName: 'Klingon',
  description: "Star Trek's Klingon language in pIqaD script",
  requiresPadding: true,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-02-10T22:45:39.462101
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 19, Duration: 14ms
    WordClockGrid(
      isDefault: true,
      timeToWords: KlingonTimeToWords(),
      paddingAlphabet: '',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'wazmahcorg' // wazmah corg
            'hutwejloSoc' // hut wej loS Soc
            'vagjavwaz' // vag jav waz
            'cazrep' // caz rep
            'wazmah' // wazmah
            'cazmah' // cazmah
            'vagmah' // vagmah
            'wejmah' // wejmah
            'loSmahvag' // loSmah vag
            'tup', // tup
      ),
    ),
    // @generated end,
  ],
  minuteIncrement: 5,
);
