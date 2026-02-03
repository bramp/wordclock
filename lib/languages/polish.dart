import 'package:wordclock/languages/language.dart';
import 'package:wordclock/logic/polish_time_to_words.dart';
import 'package:wordclock/model/word_grid.dart';

final polishLanguage = WordClockLanguage(
  id: 'PL',
  languageCode: 'pl-PL',
  displayName: 'Polski',
  englishName: 'Polish',
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-02-02T21:47:47.809949
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 46750, Duration: 101ms
    WordClockGrid(
      isDefault: true,
      timeToWords: PolishTimeToWords(),
      paddingAlphabet: 'ÓĄĆĘŃŚŻ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'JEDENASTAĆŚ' // JEDENASTA
            'ŻŃDZIEWIĄTA' // DZIEWIĄTA
            'ĆĘĆĆĄĘĆĘŻĆÓ'
            'ĄÓŃĆCZWARTA' // CZWARTA
            'ĄŃŚŻŃŚĆÓSMA' // ÓSMA
            'ŻÓĆĆŃÓŃŃĘĘĘ'
            'ŻĄŻŻŚSIÓDMA' // SIÓDMA
            'ĄŻÓŃŚŚDRUGA' // DRUGA
            'ŚĆÓŚĘĆŻŻŚŚĄ'
            'ŃŃŚŻŚSZÓSTA' // SZÓSTA
            'ĄŻĘĆŻŚPIĄTA' // PIĄTA
            'ŚŻŃŚŃÓĄĘĆĘĘ'
            'ŃŻŚPIERWSZA', // PIERWSZA
      ),
    ),
    // @generated end,
  ],
  minuteIncrement: 5,
);
