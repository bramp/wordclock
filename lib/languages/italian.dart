import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/italian_time_to_words.dart';

final italianLanguage = WordClockLanguage(
  id: 'IT',
  languageCode: 'it-IT',
  displayName: 'Italiano',
  description: null,
  timeToWords: ItalianTimeToWords(),
  paddingAlphabet: 'RBORERAEOEENIA',
  timeCheckGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        'SONORLEBORE'
        'ÈRL’UNASDUE'
        'ZTREOTTONOV'
        'EDIECIUNDIC'
        'IDODICISETT'
        'EQUATTROCSE'
        'ICINQUEAMEN'
        'OEKUNLQUART'
        'OVENTICINQU'
        'EDIECILMEZZ'
        'A',
  ),
  minuteIncrement: 5,
);
