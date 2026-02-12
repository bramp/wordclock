import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/languages/conlangs/black_speech_time_to_words.dart';

final blackSpeechLanguage = WordClockLanguage(
  id: 'BS',
  languageCode: 'mis-mrd',
  displayName: 'Black Speech',
  englishName: 'Black Speech',
  description: "Mordor's Black Speech",
  isAlternative: false,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-02-09T18:14:43.448398
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 20, Duration: 13ms
    WordClockGrid(
      isDefault: true,
      timeToWords: BlackSpeechTimeToWords(),
      paddingAlphabet: 'ASHNAZGKRATU',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'KRITHZGAKHN' // KRITH GAKH
            'TGOTHRRAUKA' // GOTH RAUK
            'NHSZUSHRSUK' // USH
            'GSKAIAAHASH' // SKAI ASH
            'SAAGDUBTGRT' // DUB
            'RTORRRAZAGA' // TOR ZAG
            'ZRTAKRAGRZG' // KRA
            'UDUTGONTDUB' // UDU GON DUB
            'GAKHZAGKRAA' // GAKH ZAG KRA
            'TUAKTORKKRA', // TOR KRA
      ),
    ),
    // @generated end,
  ],
  minuteIncrement: 5,
);
