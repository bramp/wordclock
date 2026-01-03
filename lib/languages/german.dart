import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/german_time_to_word.dart';

final berneseGermanLanguage = WordClockLanguage(
  id: 'CH',
  languageCode: 'gsw-CH',
  displayName: 'Bärndütsch',
  description: 'Bernese German',
  timeToWords: BerneseGermanTimeToWords(),
  paddingAlphabet: 'KABFSIOEPMSQTELERBAMUHR',
  timeCheckGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        'ESKISCHAFÜF'
        'VIERTUBFZÄÄ'
        'ZWÄNZGSIVOR'
        'ABOHAUBIEPM'
        'EISZWÖISDRÜ'
        'VIERIFÜFIQT'
        'SÄCHSISIBNI'
        'ACHTINÜNIEL'
        'ZÄNIERBEUFI'
        'ZWÖUFIAMUHR',
  ),
  minuteIncrement: 5,
);

final germanAlternativeLanguage = WordClockLanguage(
  id: 'D2',
  languageCode: 'de-DE-x-alt',
  displayName: 'Deutsch',
  description: 'Alternative',
  timeToWords: GermanAlternativeTimeToWords(),
  paddingAlphabet: 'KAZWANZIGFUNKAXAMPMJNLK',
  timeCheckGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        'ESKISTAFÜNF'
        'ZEHNZWANZIG'
        'DREIVIERTEL'
        'VORFUNKNACH'
        'HALBAELFÜNF'
        'EINSXAMZWEI'
        'DREIPMJVIER'
        'SECHSNLACHT'
        'SIEBENZWÖLF'
        'ZEHNEUNKUHR',
  ),
  minuteIncrement: 5,
);

final swabianGermanLanguage = WordClockLanguage(
  id: 'D3',
  languageCode: 'de-DE-x-swabian',
  displayName: 'Deutsch',
  description: 'Alternative 2',
  timeToWords: SwabianGermanTimeToWords(),
  paddingAlphabet: 'KFUNKABIEGERTXIDUHL',
  timeCheckGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        'ESKISCHAFÜN'
        'KDREIVIERTL'
        'AZEHNBIEFÜN'
        'FNACHGERTVO'
        'RHALBXFÜNFE'
        'IOISECHSELF'
        'EZWOIEACHTE'
        'DDREIEZWÖLF'
        'EZEHNEUNEUH'
        'LSIEBNEVIER',
  ),
  minuteIncrement: 5,
);

final eastGermanLanguage = WordClockLanguage(
  id: 'D4',
  languageCode: 'de-DE-x-east',
  displayName: 'Deutsch',
  description: 'Alternative 3',
  timeToWords: EastGermanTimeToWords(),
  paddingAlphabet: 'KAZWANZIGFUNKAXAMPMJNLK',
  timeCheckGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        'ESKISTAFÜNF'
        'ZEHNZWANZIG'
        'DREIVIERTEL'
        'VORFUNKNACH'
        'HALBAELFÜNF'
        'EINSXAMZWEI'
        'DREIPMJVIER'
        'SECHSNLACHT'
        'SIEBENZWÖLF'
        'ZEHNEUNKUHR',
  ),
  minuteIncrement: 5,
);

final germanLanguage = WordClockLanguage(
  id: 'DE',
  languageCode: 'de-DE',
  displayName: 'Deutsch',
  description: null,
  timeToWords: GermanTimeToWords(),
  paddingAlphabet: 'KADREIFUNKAXAMPMJNLK',
  timeCheckGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        'ESKISTAFÜNF'
        'ZEHNZWANZIG'
        'DREIVIERTEL'
        'VORFUNKNACH'
        'HALBAELFÜNF'
        'EINSXAMZWEI'
        'DREIPMJVIER'
        'SECHSNLACHT'
        'SIEBENZWÖLF'
        'ZEHNEUNKUHR',
  ),
  minuteIncrement: 5,
);
