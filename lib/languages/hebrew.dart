import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/hebrew_time_to_words.dart';

final hebrewLanguage = WordClockLanguage(
  id: 'HE',
  languageCode: 'he-IL',
  displayName: 'עברית',
  description: null,
  timeToWords: HebrewTimeToWords(),
  paddingAlphabet: 'ררראמאררששארמאארשותבא',
  timeCheckGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        'רשעתחארהעשה'
        'הרשערםײתשרא'
        'מארעבראש׀לש'
        'הנ׀משעבששmח'
        'השימח׀רעשתש'
        'שארmםירשעוא'
        'הרשעוםישןלש'
        'עबרוםיעבראו'
        'יצحוםישיmחו'
        'אשmחورשותבא',
  ),
  minuteIncrement: 5,
);
