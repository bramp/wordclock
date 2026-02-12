import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/languages/natural/czech_time_to_words.dart';

final czechLanguage = WordClockLanguage(
  id: 'CZ',
  languageCode: 'cs-CZ',
  displayName: 'Čeština',
  englishName: 'Czech',
  description: null,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-01-31T21:51:08.561748
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 4462, Duration: 15ms
    WordClockGrid(
      isDefault: true,
      timeToWords: CzechTimeToWords(),
      paddingAlphabet: 'ADEN',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'JENJEDENÁCT' // JE JEDENÁCT
            'DVANÁCTŠEST' // DVANÁCT ŠEST
            'JEDNADČTYŘI' // JEDNA ČTYŘI
            'DEVĚTDVĚTŘI' // DEVĚT DVĚ TŘI
            'SEDMOSMAPĚT' // SEDM OSM PĚT
            'DESETNDESET' // DESET DESET
            'ENEČTYŘICET' // ČTYŘICET
            'DDDNPATNÁCT' // PATNÁCT
            'DVACETŘICET' // DVACET TŘICET
            'PADESÁTEPĚT', // PADESÁT PĚT
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
