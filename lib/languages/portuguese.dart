import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/portuguese_time_to_words.dart';

final portugueseLanguage = WordClockLanguage(
  id: 'PE',
  languageCode: 'pt-PT',
  displayName: 'Português',
  englishName: 'Portuguese',
  description: null,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-01-31T21:51:13.456252
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 26, Duration: 6ms
    WordClockGrid(
      isDefault: true,
      timeToWords: PortugueseTimeToWords(),
      paddingAlphabet: 'ACEHLMOPVYZ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'SÃOÉQUATROE' // SÃO É QUATRO
            'EMEIA-NOITE' // MEIA-NOITE
            'MEIO-DIAUMA' // MEIO-DIA UMA
            'LCINCOPDUAS' // CINCO DUAS
            'OTRÊSEISETE' // TRÊS SEIS SETE
            'OITONOVEDEZ' // OITO NOVE DEZ
            'ZONZEYMENOS' // ONZE MENOS E
            'HORASQUARTO' // HORAS HORA QUARTO
            'MVINTEHMEIA' // VINTE MEIA E
            'AHDEZHCINCO', // DEZ CINCO
      ),
    ),
    // @generated end,
    WordClockGrid(
      isReference: true,
      timeToWords: ReferencePortugueseTimeToWords(),
      paddingAlphabet: 'ACEHLMOPVYZ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'ÉSÃOUMATRÊS'
            'MEIOLDIADEZ'
            'DUASEISETEY'
            'QUATROHNOVE'
            'CINCOITONZE'
            'ZMEIALNOITE'
            'HORASYMENOS'
            'VINTECAMEIA'
            'UMVQUARTOPM'
            'DEZOEYCINCO',
      ),
    ),
  ],
  minuteIncrement: 5,
);
