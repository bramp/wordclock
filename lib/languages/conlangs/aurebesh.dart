import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/languages/natural/english_time_to_words.dart';

// Aurebesh is a mapping of English characters to Star Wars glyphs.
// We reuse the English TimeToWords logic but render it with the Aurebesh font.
final aurebeshLanguage = WordClockLanguage(
  id: 'AURE',
  englishName: 'Aurebesh',
  displayName: 'Aurebesh', // The font will render this as Aurebesh glyphs
  description: "Star Wars' Aurebesh",
  languageCode: 'aure', // Unofficial code

  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-02-16T21:35:17.688454
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 23, Duration: 14ms
    WordClockGrid(
      isDefault: true,
      timeToWords: EnglishTimeToWords(),
      paddingAlphabet: 'STARWARSAUREBESHGALACTICEMPIREREBELALLIANCEJEDI',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ITDISEELCLW' // IT IS
            'BAEHALFJSRR' // HALF
            'QUARTERITEN' // QUARTER TEN
            'TWENTYRFIVE' // TWENTY FIVE
            'PASTOSEIGHT' // PAST TO EIGHT
            'TWELVELEVEN' // TWELVE ELEVEN
            'SEVENETHREE' // SEVEN THREE
            'FIVENINETEN' // FIVE NINE TEN
            'EFOURETWONE' // FOUR TWO ONE
            'ESIXRO’CLOCK', // SIX O’CLOCK
      ),
    ),
    // @generated end,
  ],
);
