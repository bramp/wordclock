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
    // Generated: 2026-01-31T21:51:09.170847
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
            'HETGISKHOMG' // HET IS
            'ECCKGTPTIEN' // TIEN
            'AKWARTGVIJF' // KWART VIJF
            'EOVERCKVOOR' // OVER VOOR
            'HALFPTWAALF' // HALF TWAALF
            'CZZEVENEGEN' // ZEVEN NEGEN
            'TIENVIJFELF' // TIEN VIJF ELF
            'VIERACHTWEE' // VIER ACHT TWEE
            'DRIEÉÉNZESO' // DRIE ÉÉN ZES
            'MSAECHHMUUR', // UUR
      ),
    ),
    // @generated end,
    WordClockGrid(
      isReference: true,
      timeToWords: ReferenceDutchTimeToWords(),
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
