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
    // Generated: 2026-01-16T16:57:01.712616
    // Algorithm: Trie
    // Seed: 0
    // Iterations: 685, Duration: 5ms
    WordClockGrid(
      isDefault: true,
      timeToWords: SpanishTimeToWords(),
      paddingAlphabet: 'AEILMNOPS',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'SONESLASLAL' // SON ES LAS LA
            'NDOCEECINCO' // DOCE CINCO
            'DIEZUNADOSP' // DIEZ UNA DOS
            'TRESOCUATRO' // TRES CUATRO
            'ONMSEISIETE' // SEIS SIETE
            'MOCHOSNUEVE' // OCHO NUEVE
            'ONCEOYMENOS' // ONCE Y MENOS
            'DIEZMCUARTO' // DIEZ CUARTO
            'VEINTEMEDIA' // VEINTE MEDIA
            'VEINTICINCO', // VEINTICINCO CINCO
      ),
    ),
    // @generated end,
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
