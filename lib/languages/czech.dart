import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/czech_time_to_words.dart';

final czechLanguage = WordClockLanguage(
  id: 'CZ',
  languageCode: 'cs-CZ',
  displayName: 'Čeština',
  englishName: 'Czech',
  description: null,
  grids: [
    WordClockGrid(
      isDefault: true,
      timeToWords: CzechTimeToWords(),
      paddingAlphabet: 'ADEN',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            "JSOUJEČTYŘI"
            "JEDENÁCTPĚT"
            "DVANÁCTŠEST"
            "JEDNAOSMDVĚ"
            "DEVĚTŘISEDM"
            "DESETNDESET"
            "DANČTYŘICET"
            "PADESÁTNULA"
            "DVACETŘICET"
            "PATNÁCTEPĚT",
      ),
    ),
    WordClockGrid(
      isTimeCheck: true,
      timeToWords: CzechTimeToWords(),
      paddingAlphabet: 'ADEN',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'JEJSOUJEDNA'
            'DEVĚTPĚTDVĚ'
            'SEDMDVANÁCT'
            'DESETŘIŠEST'
            'OSMJEDENÁCT'
            'ČTYŘIADESET'
            'DVACETŘICET'
            'PATNÁCTNULA'
            'NEČTYŘICETE'
            'PADESÁTDPĚT',
      ),
    ),
  ],
  minuteIncrement: 5,
);
