import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/italian_time_to_words.dart';

final italianLanguage = WordClockLanguage(
  id: 'IT',
  languageCode: 'it-IT',
  displayName: 'Italiano',
  englishName: 'Italian',
  description: null,
  timeToWords: ItalianTimeToWords(),
  paddingAlphabet: 'ABCEKLORSZ',
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "SONOLLEZKZO"
        "BDODICIDUEB"
        "CNOVECOTTOB"
        "QUATTROSEIR"
        "SETTEETRELA"
        "OUNDICIKÈCB"
        "L’UNAAEMENOA"
        "OKCINQUESCE"
        "MENOZDIECIS"
        "EOMEZZAMENO"
        "CINQUEDIECI"
        "EUNOSQUARTO"
        "RRZZEVENTIE"
        "VENTICINQUE",
  ),
  timeCheckGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        'SONORLEBORE'
        'ÈRL’UNASDUEZ'
        'TREOTTONOVE'
        'DIECIUNDICI'
        'DODICISETTE'
        'QUATTROCSEI'
        'CINQUEAMENO'
        'EKUNLQUARTO'
        'VENTICINQUE'
        'DIECILMEZZA',
  ),
  minuteIncrement: 5,
);
