import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/portuguese_time_to_words.dart';

final portugueseLanguage = WordClockLanguage(
  id: 'PE',
  languageCode: 'pt-PT',
  displayName: 'Português',
  englishName: 'Portuguese',
  description: null,
  timeToWords: PortugueseTimeToWords(),
  paddingAlphabet: 'ACEHLMOPVYZ',
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "SÃOITONOITE"
        "EMENOSHORAS"
        "CINCONZEEEL"
        "VINTEUMAPOZ"
        "DEZNOVEMEIO"
        "QUARTOYDIAM"
        "UMEIAHAHHEA"
        "ÉQUATROPMCC"
        "DUASEISAYAL"
        "TRÊSETEOPMY",
  ),
  timeCheckGrid: WordGrid.fromLetters(
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
  minuteIncrement: 5,
);
