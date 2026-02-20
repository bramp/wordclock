import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/languages/natural/english_time_to_words.dart';

// Mando'a (Mandalorian) is effectively a cipher for English in this context
final mandoLanguage = WordClockLanguage(
  id: 'MANDO',
  englishName: 'Mandalorian',
  displayName: 'Mando\'a',
  description: "Star Wars' Mandalorian",

  languageCode: 'mando', // Unofficial code

  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-02-16T21:36:15.524766
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 23, Duration: 14ms
    WordClockGrid(
      isDefault: true,
      timeToWords: EnglishTimeToWords(),
      paddingAlphabet: 'MANDALORIANBESKARWAYTHISISTHE',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ITDISKIIALS' // IT IS
            'KYMHALFWAOA' // HALF
            'QUARTERETEN' // QUARTER TEN
            'TWENTYSFIVE' // TWENTY FIVE
            'PASTOMEIGHT' // PAST TO EIGHT
            'TWELVELEVEN' // TWELVE ELEVEN
            'SEVENATHREE' // SEVEN THREE
            'FIVENINETEN' // FIVE NINE TEN
            'BFOURSTWONE' // FOUR TWO ONE
            'LSIXEO’CLOCK', // SIX O’CLOCK
      ),
    ),
    // @generated end,
  ],
);
