import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/languages/conlangs/high_valyrian_time_to_words.dart';

final highValyrianLanguage = WordClockLanguage(
  id: 'HVA',
  englishName: 'High Valyrian',
  displayName: 'Valyrio Udrir', // "Valyrian Language"
  description: "Game of Thrones' High Valyrian",

  languageCode: 'hva', // Unofficial code, widely used in conlang communities

  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-02-19T17:11:41.409327
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 276142, Duration: 66ms
    WordClockGrid(
      isDefault: true,
      timeToWords: HighValyrianTimeToWords(),
      paddingAlphabet: 'VALYRIOUDRIRISSASEABCDEFGHIJKLMNÑOPQRSTUVYZĀĒĪŌŪȲ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ISSAÑSĪKUDA' // ISSA SĪKUDA
            'IZULAĒJĒNQA' // IZULA JĒNQA
            'HĀRETŌMAMPA' // HĀRE TŌMA AMPA
            'IBȲRERVŌRER' // BȲRE VŌRE
            'LANTAĀTMĒRE' // LANTA MĒRE
            'SELLANTEPSA' // SE LANTEPSA
            'IZULEPSAMPA' // IZULEPSA AMPA
            'YYHĀREPSAFK' // HĀREPSA
            'AQTŌMEPSARR' // TŌMEPSA
            'AŌIPUOĒTŌMA', // TŌMA
      ),
    ),
    // @generated end,
  ],
);
