import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/czech_time_to_words.dart';

const czechLanguage = WordClockLanguage(
  id: 'CZ',
  languageCode: 'cs-CZ',
  displayName: 'Čeština',
  description: null,
  timeToWords: CzechTimeToWords(),
  paddingAlphabet: 'ANEED',
  timeCheckGrid: WordGrid(
    width: 11,
    letters:
        'JEJSOUJEDNADEVĚTPĚTDVĚSEDMDVANÁCTDESETŘIŠESTOSMJEDENÁCTČTYŘIADESETDVACETŘICETPATNÁCTNULANEČTYŘICETEPADESÁTDPĚT',
  ),
  minuteIncrement: 5,
);
