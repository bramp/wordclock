import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/czech_time_to_words.dart';

final czechLanguage = WordClockLanguage(
  id: 'CZ',
  languageCode: 'cs-CZ',
  displayName: 'Čeština',
  englishName: 'Czech',
  description: null,
  timeToWords: CzechTimeToWords(),
  paddingAlphabet: 'ADEN',
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "JENDEVĚTNED"
        "JEDNADENÁCT"
        "AAJEDENÁCTE"
        "AOSMAAŠESTA"
        "SEDMDVANÁCT"
        "AJSOUEAADVĚ"
        "ENANTŘICETN"
        "ČTYŘIDNULAN"
        "DNDVACETDND"
        "NNNTŘICETND"
        "PADESÁTCETN"
        "NČTYŘICETEE"
        "DPĚTEDDESET"
        "EDČTYŘICETA"
        "NPADESÁTNAA"
        "NNPATNÁCTNN"
        "EEDVACETEEN"
        "NTŘICETNULA"
        "AENPĚTDESET",
  ),
  timeCheckGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        'JEJSOUJEDNA'
        'DEVĚTPĚTDVĚ'
        'SEDMDVANÁCT'
        'DESETŘIŠEST'
        'OSMJEDENÁCT'
        'ČTYŘIADESET'
        'DVACETŘICET'
        'PATNÁCTNULA'
        'NEČTYŘICETE'
        'PADESÁTDPĚT',
  ),
  minuteIncrement: 5,
);
