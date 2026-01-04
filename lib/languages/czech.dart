import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/czech_time_to_words.dart';

final czechLanguage = WordClockLanguage(
  id: 'CZ',
  languageCode: 'cs-CZ',
  displayName: 'Čeština',
  description: null,
  timeToWords: CzechTimeToWords(),
  paddingAlphabet: 'ADEN',
  defaultGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        "JENDEVĚTDAN"
        "DDDVANÁCTNE"
        "EDJEDENÁCTD"
        "JEDNANOSMED"
        "ASEDMAŠESTE"
        "JSOUEDVĚTŘI"
        "ČTYŘIAEADAE"
        "EDVACETNULA"
        "EAEPADESÁTN"
        "NTŘICETDEDD"
        "ČTYŘICETDNA"
        "NNPĚTDANDEN"
        "DESETDESETN"
        "DVACETENULA"
        "EPADESÁTAAN"
        "NNPATNÁCTAN"
        "ENNTŘICETNN"
        "ČTYŘICETNED"
        "AEEEENDNPĚT",
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
