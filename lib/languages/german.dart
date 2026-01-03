import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/german_time_to_word.dart';

const berneseGermanLanguage = WordClockLanguage(
  id: 'CH',
  languageCode: 'gsw-CH',
  displayName: 'Bärndütsch',
  description: 'Bernese German',
  timeToWords: BerneseGermanTimeToWords(),
  paddingAlphabet: 'KABFSIOEPMSQTELERBAMUHR',
  timeCheckGrid: WordGrid(
    width: 11,
    letters:
        'ESKISCHAFÜFVIERTUBFZÄÄZWÄNZGSIVORABOHAUBIEPMEISZWÖISDRÜVIERIFÜFIQTSÄCHSISIBNIACHTINÜNIELZÄNIERBEUFIZWÖUFIAMUHR',
  ),
  minuteIncrement: 5,
);

const germanAlternativeLanguage = WordClockLanguage(
  id: 'D2',
  languageCode: 'de-DE-x-alt',
  displayName: 'Deutsch',
  description: 'Alternative',
  timeToWords: GermanAlternativeTimeToWords(),
  paddingAlphabet: 'KAZWANZIGFUNKAXAMPMJNLK',
  timeCheckGrid: WordGrid(
    width: 11,
    letters:
        'ESKISTAFÜNFZEHNZWANZIGDREIVIERTELVORFUNKNACHHALBAELFÜNFEINSXAMZWEIDREIPMJVIERSECHSNLACHTSIEBENZWÖLFZEHNEUNKUHR',
  ),
  minuteIncrement: 5,
);

const swabianGermanLanguage = WordClockLanguage(
  id: 'D3',
  languageCode: 'de-DE-x-swabian',
  displayName: 'Deutsch',
  description: 'Alternative 2',
  timeToWords: SwabianGermanTimeToWords(),
  paddingAlphabet: 'KFUNKABIEGERTXIDUHL',
  timeCheckGrid: WordGrid(
    width: 11,
    letters:
        'ESKISCHAFÜNKDREIVIERTLAZEHNBIEFÜNFNACHGERTVORHALBXFÜNFEIOISECHSELFEZWOIEACHTEDDREIEZWÖLFEZEHNEUNEUHLSIEBNEVIERE',
  ),
  minuteIncrement: 5,
);

const eastGermanLanguage = WordClockLanguage(
  id: 'D4',
  languageCode: 'de-DE-x-east',
  displayName: 'Deutsch',
  description: 'Alternative 3',
  timeToWords: EastGermanTimeToWords(),
  paddingAlphabet: 'KAZWANZIGFUNKAXAMPMJNLK',
  timeCheckGrid: WordGrid(
    width: 11,
    letters:
        'ESKISTAFÜNFZEHNZWANZIGDREIVIERTELVORFUNKNACHHALBAELFÜNFEINSXAMZWEIDREIPMJVIERSECHSNLACHTSIEBENZWÖLFZEHNEUNKUHR',
  ),
  minuteIncrement: 5,
);

const germanLanguage = WordClockLanguage(
  id: 'DE',
  languageCode: 'de-DE',
  displayName: 'Deutsch',
  description: null,
  timeToWords: GermanTimeToWords(),
  paddingAlphabet: 'KADREIFUNKAXAMPMJNLK',
  timeCheckGrid: WordGrid(
    width: 11,
    letters:
        'ESKISTAFÜNFZEHNZWANZIGDREIVIERTELVORFUNKNACHHALBAELFÜNFEINSXAMZWEIDREIPMJVIERSECHSNLACHTSIEBENZWÖLFZEHNEUNKUHR',
  ),
  minuteIncrement: 5,
);
