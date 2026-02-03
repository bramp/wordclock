import 'package:wordclock/languages/language.dart';
import 'package:wordclock/logic/tamil_time_to_words.dart';
import 'package:wordclock/model/word_grid.dart';

final tamilLanguage = WordClockLanguage(
  id: 'TA',
  languageCode: 'ta',
  displayName: 'தமிழ்',
  englishName: 'Tamil',
  description: null,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-02-02T22:40:21.463506
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
            'வஇரண்டுகஒன்பதுட' // இரண்டு ஒன்பது
            'சபபயஎட்டுழயலழ' // எட்டு
            'லலமூன்றுலபபநான்கு' // மூன்று நான்கு
            'றஒருலழகயஆறுலற' // ஒரு ஆறு
            'யழஏழுழபபத்துழள' // ஏழு பத்து
            'ஐந்துகரரமணிசளர' // ஐந்து மணி
            'வபதினைந்துழஇருபது' // பதினைந்து இருபது
            'ஐம்பதுநாற்பதுபத்து' // ஐம்பது நாற்பது பத்து
            'சறகமுப்பதுசஐந்து', // முப்பது ஐந்து
      ),
    ),
    // @generated end,
  ],
  minuteIncrement: 5,
);
