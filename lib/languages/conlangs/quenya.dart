import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/languages/conlangs/quenya_time_to_words.dart';

final quenyaLanguage = WordClockLanguage(
  id: 'QY',
  languageCode: 'qya',
  displayName: '',
  englishName: 'Quenya (Elvish)',
  description: "Tolkien's Quenya language",
  isAlternative: false,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-02-16T10:49:28.096889
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 23, Duration: 13ms
    WordClockGrid(
      isDefault: true,
      timeToWords: QuenyaTimeToWords(),
      paddingAlphabet: '',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            '' //   
            '' //  
            '' //  
            '' //  
            '' //  
            '' // 
            '' //   
            '' //  
            '' //   
            '', //  
      ),
    ),
    // @generated end,
  ],
  minuteIncrement: 5,
);
