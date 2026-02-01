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
    // Generated: 2026-01-31T21:41:21.847684
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 25, Duration: 5ms
    WordClockGrid(
      isDefault: true,
      timeToWords: ReferenceItalianTimeToWords(),
      paddingAlphabet: 'ABCEKLORSZ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'SONOLÈZL’UNA' // SONO È L’UNA
            'KLEZQUATTRO' // LE QUATTRO
            'ODODICINQUE' // DODICI CINQUE
            'UNDICISETTE' // UNDICI SETTE
            'BDIECIKNOVE' // DIECI NOVE
            'OTTOSEIDUEB' // OTTO SEI DUE
            'TREBMENOZUN' // TRE MENO E UN
            'VENTICINQUE' // VENTICINQUE VENTI CINQUE
            'DIECIZMEZZA' // DIECI MEZZA
            'SCCBKQUARTO', // QUARTO
      ),
    ),
    // @generated end,
    WordClockGrid(
      isReference: true,
      timeToWords: ReferenceItalianTimeToWords(),
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
