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
    // Generated: 2026-01-16T16:56:41.835282
    // Algorithm: Trie
    // Seed: 0
    // Iterations: 550, Duration: 5ms
    WordClockGrid(
      isDefault: true,
      timeToWords: GreekTimeToWords(),
      paddingAlphabet: 'AEHKPTXΔΧ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'HKΩPATEINAI' // H ΩPA EINAI
            'ΔΩΔEKAΠENTE' // ΔΩΔEKA ΔEKA ΠENTE
            'MIAΔYOTPEIΣ' // MIA ΔYO TPEIΣ
            'TEΣΣEPIΣEΞI' // TEΣΣEPIΣ EΞI
            'EEΦTAΔXOΧTΩ' // EΦTA OΧTΩ
            'ENNIAENTEKA' // ENNIA ENTEKA
            'XKAITPΠENTE' // KAI ΠENTE
            'PΠAPAΧXΔEKA' // ΠAPA ΔEKA
            'EIKOΣIPMIΣH' // EIKOΣI MIΣH
            'HΠENTETAPTO', // ΠENTE TETAPTO
      ),
    ),
    // @generated end,
    WordClockGrid(
      isTimeCheck: true,
      timeToWords: GreekTimeToWords(),
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
