import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/french_time_to_words.dart';

final frenchLanguage = WordClockLanguage(
  id: 'FR',
  languageCode: 'fr-FR',
  displayName: 'Français',
  englishName: 'French',
  description: null,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-01-31T21:51:11.300759
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 3675519, Duration: 920ms
    WordClockGrid(
      isDefault: true,
      timeToWords: FrenchTimeToWords(),
      paddingAlphabet: 'ADEMNOPRSTU',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ILEESTEONZE' // IL EST ONZE
            'QUATRETROIS' // QUATRE TROIS
            'MINUITNDEUX' // MINUIT DEUX
            'HUITMIDISIX' // HUIT MIDI SIX
            'UNEUFRHEURE' // UNE NEUF HEURE
            'SEPTCINQDIX' // SEPT CINQ DIX
            'PHEURESUTET' // HEURES ET
            'MOINSODEMIE' // MOINS DEMIE DEMI
            'MVINGT-CINQ' // VINGT VINGT-CINQ CINQ
            'DIXLEAQUART', // DIX LE QUART
      ),
    ),
    // @generated end,
    WordClockGrid(
      isReference: true,
      timeToWords: ReferenceFrenchTimeToWords(),
      paddingAlphabet: 'ADEMNOPRSTU',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ILNESTODEUX'
            'QUATRETROIS'
            'NEUFUNESEPT'
            'HUITSIXCINQ'
            'MIDIXMINUIT'
            'ONZERHEURES'
            'MOINSOLEDIX'
            'ETRQUARTPMD'
            'VINGT-CINQU'
            'ETSDEMIEPAM',
      ),
    ),
  ],
  minuteIncrement: 5,
);
