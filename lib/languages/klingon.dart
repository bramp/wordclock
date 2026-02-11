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
  requiresPadding: true,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-02-10T21:04:37.743019
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
            'wazmahacorg' // wazmah waz corg
            'rhutrwtweja' // hut wej
            'eeIloSocvmo' // loS Soc
            'vagxjavIcaz' // vag jav caz
            'rrepgwazmah' // rep wazmah
            'jkcazmahnab' // cazmah
            'eavagmahySv' // vagmah
            'hcwejmahcqn' // wejmah
            'aloSmahavag' // loSmah vag
            'tSffjckctup', // tup
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
    // Generated: 2026-02-10T21:05:01.001970
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 19, Duration: 15ms
    WordClockGrid(
      isDefault: true,
      timeToWords: KlingonTimeToWords(),
      paddingAlphabet: '',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            '' //   
            '' //  
            '' //  
            '' //   
            '' //  
            '' // 
            '' // 
            '' // 
            '' //  
            '', // 
      ),
    ),
    // @generated end,
  ],
  minuteIncrement: 5,
);
