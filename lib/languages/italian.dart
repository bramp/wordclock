import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/italian_time_to_words.dart';

final italianLanguage = WordClockLanguage(
  id: 'IT',
  languageCode: 'it-IT',
  displayName: 'Italiano',
  englishName: 'Italian',
  description: null,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-01-16T16:56:41.846954
    // Algorithm: Trie
    // Seed: 0
    // Iterations: 938, Duration: 6ms
    WordClockGrid(
      isDefault: true,
      timeToWords: ItalianTimeToWords(),
      paddingAlphabet: 'ABCEKLORSZ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'SONOÈLEL’UNA' // SONO È LE L’UNA
            'LDODICINQUE' // DODICI CINQUE
            'DIECIDUETRE' // DIECI DUE TRE
            'QUATTROZSEI' // QUATTRO SEI
            'KSETTEZOTTO' // SETTE OTTO
            'NOVEOUNDICI' // NOVE UNDICI
            'BKEBBCINQUE' // E CINQUE
            'MENOMEZZAUN' // MENO MEZZA UN
            'DIECIQUARTO' // DIECI QUARTO
            'VENTICINQUE', // VENTI VENTICINQUE CINQUE
      ),
    ),
    // @generated end,
    WordClockGrid(
      isTimeCheck: true,
      timeToWords: ItalianTimeToWords(),
      paddingAlphabet: 'ABCEKLORSZ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'SONORLEBORE'
            'ÈRL’UNASDUEZ'
            'TREOTTONOVE'
            'DIECIUNDICI'
            'DODICISETTE'
            'QUATTROCSEI'
            'CINQUEAMENO'
            'EKUNLQUARTO'
            'VENTICINQUE'
            'DIECILMEZZA',
      ),
    ),
  ],
  minuteIncrement: 5,
);
