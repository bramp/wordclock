import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/languages/conlangs/sindarin_time_to_words.dart';

final sindarinLanguage = WordClockLanguage(
  id: 'SI',
  languageCode: 'sjn',
  displayName: '',
  englishName: 'Sindarin Elvish',
  description: "Tolkien's Sindarin language",
  isAlternative: false,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-02-15T11:59:49.926738
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 21, Duration: 13ms
    WordClockGrid(
      isDefault: true,
      timeToWords: SindarinTimeToWords(),
      paddingAlphabet: '',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            '' //  
            '' //  
            '' //   
            '' //  
            '' //  
            '' //  
            '' //   
            '' //  
            '' // 
            '', // 
      ),
    ),
    // @generated end,
  ],
  minuteIncrement: 5,
);
