import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/dutch_time_to_words.dart';

final dutchLanguage = WordClockLanguage(
  id: 'NL',
  languageCode: 'nl-NL',
  displayName: 'Nederlands',
  englishName: 'Dutch',
  description: null,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-01-25T09:42:52.195704
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 22, Duration: 4ms
    WordClockGrid(
      isDefault: true,
      timeToWords: DutchTimeToWords(),
      paddingAlphabet: 'ACEGHKMOPSTZ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'HETGISKTIEN' // HET IS TIEN
            'HKWARTOVIJF' // KWART VIJF
            'MOVERGEVOOR' // OVER VOOR
            'HALFCTWAALF' // HALF TWAALF
            'CKZEVENEGEN' // ZEVEN NEGEN
            'TIENVIJFELF' // TIEN VIJF ELF
            'VIERACHTWEE' // VIER ACHT TWEE
            'DRIEÉÉNZESG' // DRIE ÉÉN ZES
            'TPAGECKPUUR' // UUR
            'CZOMSAECHHM',
      ),
    ),
    // @generated end,
    WordClockGrid(
      isTimeCheck: true,
      timeToWords: DutchTimeToWords(),
      paddingAlphabet: 'ACEGHKMOPSTZ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'HETKISAVIJF'
            'TIENATZVOOR'
            'OVERMEKWART'
            'HALFSPMOVER'
            'VOORTHGÉÉNS'
            'TWEEAMCDRIE'
            'VIERVIJFZES'
            'ZEVENONEGEN'
            'ACHTTIENELF'
            'TWAALFPMUUR',
      ),
    ),
  ],
  minuteIncrement: 5,
);
