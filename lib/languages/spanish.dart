import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/spanish_time_to_words.dart';

final spanishLanguage = WordClockLanguage(
  id: 'ES',
  languageCode: 'es-ES',
  displayName: 'Español',
  englishName: 'Spanish',
  description: null,
  grids: [
    WordClockGrid(
      isDefault: true,
      timeToWords: SpanishTimeToWords(),
      paddingAlphabet: 'AEILMNOPS',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            "SONESLASLAL"
            "CUATROCINCO"
            "NUEVENSIETE"
            "DOCEONCEDOS"
            "DIEZOCHOUNA"
            "ETRESEISPOY"
            "MENOSOCINCO"
            "VEINTICINCO"
            "VEINTEMEDIA"
            "CUARTONDIEZ",
      ),
    ),
    WordClockGrid(
      isTimeCheck: true,
      timeToWords: SpanishTimeToWords(),
      paddingAlphabet: 'AEILMNOPS',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ESONELASUNA'
            'DOSITRESOAM'
            'CUATROCINCO'
            'SEISASIETEN'
            'OCHONUEVEPM'
            'LADIEZSONCE'
            'DOCELYMENOS'
            'OVEINTEDIEZ'
            'VEINTICINCO'
            'MEDIACUARTO',
      ),
    ),
  ],
  minuteIncrement: 5,
);
