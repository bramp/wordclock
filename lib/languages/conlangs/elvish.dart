import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/languages/conlangs/elvish_time_to_words.dart';

final elvishLanguage = WordClockLanguage(
  id: 'EL',
  languageCode: 'sjn',
  displayName: 'Sindarin (Elvish)',
  englishName: 'Elvish',
  description: "Tolkien's Sindarin language",
  isAlternative: false,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-02-09T18:13:04.607490
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 107, Duration: 13ms
    WordClockGrid(
      isDefault: true,
      timeToWords: ElvishTimeToWords(),
      paddingAlphabet: '',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            '' //  
            '' //   
            '' //  
            '' //  
            '' // 
            '' //   
            '' //  
            '' // 
            '' //  
            '', //  
      ),
    ),
    // @generated end,
  ],
  minuteIncrement: 5,
);
