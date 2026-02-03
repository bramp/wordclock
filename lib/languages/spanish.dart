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
    // @generated begin - do not edit manually
    // Generated: 2026-01-31T21:52:13.781637
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 25, Duration: 4ms
    WordClockGrid(
      isDefault: true,
      timeToWords: SpanishTimeToWords(),
      paddingAlphabet: 'AEILMNOPS',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'SONESLASLAL' // SON ES LAS LA
            'CUATROCINCO' // CUATRO CINCO
            'NUEVENSIETE' // NUEVE SIETE
            'DOCEONCEDOS' // DOCE ONCE DOS
            'DIEZOCHOUNA' // DIEZ OCHO UNA
            'ETRESEISPOY' // TRES SEIS Y
            'MENOSOCINCO' // MENOS CINCO
            'VEINTICINCO' // VEINTICINCO
            'VEINTEMEDIA' // VEINTE MEDIA
            'CUARTONDIEZ', // CUARTO DIEZ
      ),
    ),
    // @generated end,
    WordClockGrid(
      isReference: true,
      timeToWords: ReferenceSpanishTimeToWords(),
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
