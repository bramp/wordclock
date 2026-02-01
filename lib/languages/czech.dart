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
    // @generated begin - do not edit manually
    // Generated: 2026-01-25T09:42:52.156275
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 13375078, Duration: 3006ms
    WordClockGrid(
      isDefault: true,
      timeToWords: ReferenceCzechTimeToWords(),
      paddingAlphabet: 'ADEN',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'JSOUJEČTYŘI' // JSOU JE ČTYŘI
            'JEDENÁCTPĚT' // JEDENÁCT PĚT
            'DVANÁCTŠEST' // DVANÁCT ŠEST
            'JEDNAOSMDVĚ' // JEDNA OSM DVĚ
            'DEVĚTŘISEDM' // DEVĚT TŘI SEDM
            'DESETNDESET' // DESET DESET
            'DANČTYŘICET' // ČTYŘICET
            'PADESÁTNULA' // PADESÁT NULA
            'DVACETŘICET' // DVACET TŘICET
            'PATNÁCTEPĚT', // PATNÁCT PĚT
      ),
    ),
    // @generated end,
    WordClockGrid(
      isReference: true,
      timeToWords: ReferenceCzechTimeToWords(),
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
