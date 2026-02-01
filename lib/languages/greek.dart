import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/greek_time_to_words.dart';

final greekLanguage = WordClockLanguage(
  id: 'GR',
  languageCode: 'el-GR',
  displayName: 'Ελληνικά',
  englishName: 'Greek',
  description: null,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-01-31T21:51:12.244701
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 23, Duration: 5ms
    WordClockGrid(
      isDefault: true,
      timeToWords: ReferenceGreekTimeToWords(),
      paddingAlphabet: 'AEHKPTXΔΧ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'HKΩPATEINAI' // H ΩPA EINAI
            'TEΣΣEPIΣMIA' // TEΣΣEPIΣ MIA
            'ΔΩΔEKATPEIΣ' // ΔΩΔEKA ΔEKA TPEIΣ
            'ENTEKAΠENTE' // ENTEKA ΠENTE
            'EENNIAΔEΦTA' // ENNIA EΦTA
            'OΧTΩΔYOEΞIX' // OΧTΩ ΔYO EΞI
            'XTΠAPAPPKAI' // ΠAPA KAI
            'TETAPTOΔEKA' // TETAPTO ΔEKA
            'EIKOΣIΧMIΣH' // EIKOΣI MIΣH
            'XPHXKHΠENTE', // ΠENTE
      ),
    ),
    // @generated end,
    WordClockGrid(
      isReference: true,
      timeToWords: ReferenceGreekTimeToWords(),
      paddingAlphabet: 'AEHKPTXΔΧ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'HΧΩPATEINAI'
            'MIAΔYOTPEIΣ'
            'TEΣΣEPIΣEΞI'
            'ΠENTEPOΧTΩH'
            'EΦTAEENTEKA'
            'ΔΩΔEKAENNIA'
            'ΔEKAXΠAPAEP'
            'KAIETETAPTO'
            'EIKOΣIHΔEKA'
            'MIΣHEΠENTEP',
      ),
    ),
  ],
  minuteIncrement: 5,
);
