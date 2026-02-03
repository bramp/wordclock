import 'package:wordclock/languages/language.dart';
import 'package:wordclock/logic/tamil_time_to_words.dart';
import 'package:wordclock/model/word_grid.dart';

final tamilLanguage = WordClockLanguage(
  id: 'TA',
  languageCode: 'ta',
  displayName: 'Tamil',
  englishName: 'Tamil',
  description: null,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-02-02T22:15:32.114615
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 21, Duration: 18ms
    WordClockGrid(
      isDefault: true,
      timeToWords: TamilTimeToWords(),
      paddingAlphabet: 'கசடதபறயரலவழள',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'பன்னிரண்டுபதினொன்று' // பன்னிரண்டு பதினொன்று
            'தஇரண்டுறபஒன்பது' // இரண்டு ஒன்பது
            'ரயதடசசறதஎட்டு' // எட்டு
            'ழலமூன்றுகதடநான்கு' // மூன்று நான்கு
            'சறலஒருசளரயஆறு' // ஒரு ஆறு
            'வகடஏழுசபபபத்து' // ஏழு பத்து
            'யழயஐந்துலழலமணி' // ஐந்து மணி
            'லபதினைந்துலஇருபது' // பதினைந்து இருபது
            'ஐம்பதுநாற்பதுபத்து' // ஐம்பது நாற்பது பத்து
            'பபறமுப்பதுலஐந்து', // முப்பது ஐந்து
      ),
    ),
    // @generated end,
  ],
  minuteIncrement: 5,
);
