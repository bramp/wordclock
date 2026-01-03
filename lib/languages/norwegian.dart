import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/norwegian_time_to_words.dart';

const norwegianLanguage = WordClockLanguage(
  id: 'NO',
  languageCode: 'nb-NO',
  displayName: 'Norsk',
  description: null,
  timeToWords: NorwegianTimeToWords(),
  paddingAlphabet: 'VMHPÅSUFISLPÅSIDOSNNSTOXAMBPMZBlEGENZNAXS',
  timeCheckGrid: WordGrid(
    width: 11,
    letters:
        'KLOKKENVERMFEMHPÅSUFISTlLPÅSIDOSNKVARTNPÅSTOOVERXAMBPMZHALVBlEGENZETTNTOATREXFlREFEMSEKSSYVÅTTENITlELLEVESTOLV',
  ),
  minuteIncrement: 5,
);
