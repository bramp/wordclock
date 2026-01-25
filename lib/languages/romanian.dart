import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/romanian_time_to_words.dart';

final romanianLanguage = WordClockLanguage(
  id: 'RO',
  languageCode: 'ro-RO',
  displayName: 'Română',
  englishName: 'Romanian',
  description: null,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-01-25T09:25:52.460064
    // Algorithm: Trie
    // Seed: 0
    // Iterations: 166517, Duration: 2201ms
    WordClockGrid(
      isDefault: true,
      timeToWords: RomanianTimeToWords(),
      paddingAlphabet: 'ABLMNOPUVZ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ESTEOORAZNZ' // ESTE ORA
            'PDOUĂBCINCI' // DOUĂ CINCI
            'UNUTREIŞASE' // UNU TREI ŞASE
            'PATRUNŞAPTE' // PATRU ŞAPTE
            'OPTNOUĂSPRE' // OPT NOUĂ SPRE
            'BUNSPREZECE' // UNSPREZECE ZECE
            'ŞIFĂRĂBZECE' // ŞI FĂRĂ ZECE
            'UNZDOUĂZECI' // UN DOUĂZECI
            'TREIZECIZŞI' // TREIZECI ŞI
            'CINCIVSFERT', // CINCI SFERT
      ),
    ),
    // @generated end,
    WordClockGrid(
      isTimeCheck: true,
      timeToWords: RomanianTimeToWords(),
      paddingAlphabet: 'ABLMNOPUVZ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ESTEZORAPMO'
            'DOUĂNSPREAM'
            'UNSPREZECEL'
            'NOUĂOPTŞASE'
            'PATRUNUTREI'
            'ŞAPTECINCIA'
            'ŞIBTREIZECI'
            'FĂRĂOZECEUN'
            'DOUĂZECIVŞI'
            'CINCIUSFERT',
      ),
    ),
  ],
  minuteIncrement: 5,
);
