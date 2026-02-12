import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/languages/natural/hebrew_time_to_words.dart';

final hebrewLanguage = WordClockLanguage(
  id: 'HE',
  languageCode: 'he-IL',
  displayName: 'עברית',
  englishName: 'Hebrew',
  description: null,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-02-02T21:48:14.688834
    // Algorithm: Trie
    // Seed: 0
    // Iterations: 26, Duration: 16ms
    WordClockGrid(
      isDefault: true,
      timeToWords: ReferenceHebrewTimeToWords(),
      paddingAlphabet: 'mאבוחיםמעצרשתحروब',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'תחארשעबהעשה' // תחא רשע העשה
            'הרשעmש׀לשמח' // הרשע ש׀לש שמח
            'עבראmששםעבש' // עברא שש עבש
            'رהנ׀משحםײתש' // הנ׀מש םײתש
            'בהשימח׀बעשת' // השימח׀ עשת
            'mהרשעוmעברו' // הרשעו עברו
            'םירשעוرיצחו' // םירשעו םירשע יצחו
            'מרווوםישןלש' // םישןלש
            'ימיםםיעבראו' // םיעבראו םיעברא
            'םישימחושמחו', // םישימח םישימחו שמחו
      ),
    ),
    // @generated end,
    WordClockGrid(
      isReference: true,
      timeToWords: ReferenceHebrewTimeToWords(),
      paddingAlphabet: 'mאבוחיםמעצרשתحروब',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'רשעתחארהעשה'
            'הרשערםײתשרא'
            'מארעבראש׀לש'
            'הנ׀משעבששמח'
            'השימח׀רעשתש'
            'שארמםירשעוא'
            'הרשעוםישןלש'
            'עברוםיעבראו'
            'יצחוםישימחו'
            'אשמחורשותבא',
      ),
    ),
  ],
  minuteIncrement: 5,
);
