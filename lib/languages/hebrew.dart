import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/hebrew_time_to_words.dart';

final hebrewLanguage = WordClockLanguage(
  id: 'HE',
  languageCode: 'he-IL',
  displayName: 'עברית',
  englishName: 'Hebrew',
  description: null,
  grids: [
    WordClockGrid(
      isDefault: true,
      timeToWords: HebrewTimeToWords(),
      paddingAlphabet: 'mאבוחיםמעצרשתحروब',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            "רשעתחאबהעשה"
            "םהנ׀משהרשעm"
            "םײתשעבראעבש"
            "ש׀לשבשמחששر"
            "השימח׀बעשתm"
            "מהרשעויצחור"
            "יםםיעבראबחם"
            "יתםיעבראורو"
            "םירשעםירשעו"
            "עותबצםישימח"
            "תיתצםישימחו"
            "םישןלשרשמחו"
            "בmबאबובעברו",
      ),
    ),
    WordClockGrid(
      isTimeCheck: true,
      timeToWords: HebrewTimeToWords(),
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
