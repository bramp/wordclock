import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/romanian_time_to_words.dart';

const romanianLanguage = WordClockLanguage(
  id: 'RO',
  languageCode: 'ro-RO',
  displayName: 'Română',
  description: null,
  timeToWords: RomanianTimeToWords(),
  paddingAlphabet: 'ZPMONAMLABOVU',
  timeCheckGrid: WordGrid(
    width: 11,
    letters:
        'ESTEZORAPMODOUĂNSPREAMUNSPREZECELNOUĂOPTŞASEPATRUNUTREIŞAPTECINCIAŞIBTREIZECIFĂRĂOZECEUNDOUĂZECIVŞICINCIUSFERT',
  ),
  minuteIncrement: 5,
);
