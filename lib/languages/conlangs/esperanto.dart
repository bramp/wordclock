import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/languages/conlangs/esperanto_time_to_words.dart';

final esperantoLanguage = WordClockLanguage(
  id: 'EO',
  englishName: 'Esperanto',
  displayName: 'Esperanto',

  // Esperanto uses standard Latin with diacritics
  // Characters: Ĉ, Ĝ, Ĥ, Ĵ, Ŝ, Ŭ
  // The 'Noto Sans' font supports these.
  languageCode: 'eo',

  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-02-16T21:35:16.798841
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 22, Duration: 16ms
    WordClockGrid(
      isDefault: true,
      timeToWords: EsperantoTimeToWords(),
      paddingAlphabet: 'ESTASHOROKAJMINUTOABCĈDEĜFGHĤIJĴKLLMNOOPQRSŜTUŬV',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ESTASJLAPNF' // ESTAS LA
            'DEKUNUASEPA' // DEKUNUA UNUA SEPA
            'DEKDUAKVARA' // DEKDUA DUA KVARA
            'FKVINARDEKA' // KVINA DEKA
            'NAŬATRIAOKA' // NAŬA TRIA OKA
            'SESAPLOKAJĜ' // SESA KAJ
            'ANKVINDEKSI' // KVINDEK DEK
            'KIKVARDEKJĴ' // KVARDEK
            'TRIDEKDUDEK' // TRIDEK DUDEK
            'JUNGFTĤKVIN', // KVIN
      ),
    ),
    // @generated end,
  ],
);
