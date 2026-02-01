import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/swedish_time_to_words.dart';

final swedishLanguage = WordClockLanguage(
  id: 'SE',
  languageCode: 'sv-SE',
  displayName: 'Svenska',
  englishName: 'Swedish',
  description: null,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-01-31T21:42:23.651125
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 23, Duration: 3ms
    WordClockGrid(
      isDefault: true,
      timeToWords: ReferenceSwedishTimeToWords(),
      paddingAlphabet: 'AEFIKLMNOPQRSTUVXYZ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'KLOCKANIÄRY' // KLOCKAN ÄR
            'UUKVARTJUGO' // KVART TJUGO
            'EVHALVYOFEM' // HALV FEM
            'KZZVVPVQTIO' // TIO
            'UPAÖVERNKLI' // ÖVER I
            'YMMKLASHALV' // HALV
            'TOLVFYRAFEM' // TOLV FYRA FEM
            'ÄTTAELVATIO' // ÄTTA ELVA TIO
            'ETTVÅTRESEX' // ETT TVÅ TRE SEX
            'QKNLSJUTNIO', // SJU NIO
      ),
    ),
    // @generated end,
    WordClockGrid(
      isReference: true,
      timeToWords: ReferenceSwedishTimeToWords(),
      paddingAlphabet: 'AEFIKLMNOPQRSTUVXYZ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'KLOCKANTÄRK'
            'FEMYISTIONI'
            'KVARTQIENZO'
            'TJUGOLIVIPM'
            'ÖVERKAMHALV'
            'ETTUSVLXTVÅ'
            'TREMYKYFYRA'
            'FEMSFLORSEX'
            'SJUÄTTAINIO'
            'TIOELVATOLV',
      ),
    ),
  ],
  minuteIncrement: 5,
);
