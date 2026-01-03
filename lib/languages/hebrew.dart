import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/hebrew_time_to_words.dart';

const hebrewLanguage = WordClockLanguage(
  id: 'HE',
  languageCode: 'he-IL',
  displayName: 'עברית',
  description: null,
  timeToWords: HebrewTimeToWords(),
  paddingAlphabet: 'ררראמאררששארמאארשותבא',
  timeCheckGrid: WordGrid(
    width: 11,
    letters:
        'רשעתחארהעשההרשערםײתשראמארעבראש׀לשהנ׀משעבששmחהשימח׀רעשתששארmםירשעואהרשעוםישןלשעबרוםיעבראויצحוםישיmחואשmחورשותבא',
  ),
  minuteIncrement: 5,
);
