import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/romanian_time_to_words.dart';

final romanianLanguage = WordClockLanguage(
  id: 'RO',
  languageCode: 'ro-RO',
  displayName: 'Română',
  englishName: 'Romanian',
  description: null,
  grids: [
    WordClockGrid(
      isDefault: true,
      timeToWords: RomanianTimeToWords(),
      paddingAlphabet: 'ABLMNOPUVZ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            "ESTEOORAZNZ"
            "PŞAPTEBDOUĂ"
            "NUNSPREZECE"
            "PATRUNUNOUĂ"
            "TREIŞASEOPT"
            "FĂRĂŞIBZECE"
            "ŞIBCINCIZŞI"
            "FĂRĂZZECEUN"
            "VLLTREIZECI"
            "DOUĂZECIBŞI"
            "SFERTNCINCI",
      ),
    ),
    WordClockGrid(
      isTimeCheck: true,
      timeToWords: RomanianTimeToWords(),
      paddingAlphabet: 'ABLMNOPUVZ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ESTEZORAPMO'
            'DOUĂNSPREAM'
            'UNSPREZECEL'
            'NOUĂOPTŞASE'
            'PATRUNUTREI'
            'ŞAPTECINCIA'
            'ŞIBTREIZECI'
            'FĂRĂOZECEUN'
            'DOUĂZECIVŞI'
            'CINCIUSFERT',
      ),
    ),
  ],
  minuteIncrement: 5,
);
