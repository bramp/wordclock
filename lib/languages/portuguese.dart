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
    // Generated: 2026-01-25T09:43:53.245965
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 29, Duration: 5ms
    WordClockGrid(
      isDefault: true,
      timeToWords: ReferencePortugueseTimeToWords(),
      paddingAlphabet: 'ACEHLMOPVYZ',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'SÃOÉQUATROE' // SÃO É QUATRO
            'ECINCOLMEIA' // CINCO MEIA
            'MEIODUASEIS' // MEIO DUAS SEIS
            'TRÊSETEOITO' // TRÊS SETE OITO
            'NOVEONZEUMA' // NOVE ONZE UMA
            'DEZNOITEDIA' // DEZ NOITE DIA
            'HORASPMENOS' // HORAS HORA MENOS E
            'VINTEMEIAUM' // VINTE MEIA E UM
            'ODEZZQUARTO' // DEZ QUARTO
            'YMHAHHCINCO', // CINCO
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
