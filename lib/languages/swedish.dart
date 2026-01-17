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
    // Generated: 2026-01-16T16:57:06.728788
    // Algorithm: Trie
    // Seed: 0
    // Iterations: 26, Duration: 3ms
    WordClockGrid(
      isDefault: true,
      timeToWords: SwedishTimeToWords(),
      paddingAlphabet: 'AEFIKLMNOPQRSTUVXYZ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'KLOCKANIÄRY' // KLOCKAN ÄR
            'UUKVARTJUGO' // KVART TJUGO
            'HALVEFEMTIO' // HALV FEM TIO
            'ÖVERVIYHALV' // ÖVER I HALV
            'FEMTIOHALVO' // FEM TIO HALV
            'FEMTIOTOLVK' // FEM TIO TOLV
            'ETTVÅTRESEX' // ETT TVÅ TRE SEX
            'FYRASJUÄTTA' // FYRA SJU ÄTTA
            'ZZVNIOVELVA' // NIO ELVA
            'PVQUPANKLYM',
      ),
    ),
    // @generated end,
    WordClockGrid(
      isTimeCheck: true,
      timeToWords: SwedishTimeToWords(),
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
