import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/turkish_time_to_words.dart';

const turkishLanguage = WordClockLanguage(
  id: 'TR',
  languageCode: 'tr-TR',
  displayName: 'Türkçe',
  description: null,
  timeToWords: TurkishTimeToWords(),
  paddingAlphabet: 'RDYARIMAMSKPMM',
  timeCheckGrid: WordGrid(
    width: 11,
    letters:
        'SAATRONUÜÇÜBİRİALTIYIDİKİYİDOKUZUDÖRDÜYEDİYİSEKIZİYARIMDÖRTAMSBEŞİKPMOTUZKIRKELLİONYİRMİBUÇUKÇEYREKBEŞMGEÇİYOR',
  ),
  minuteIncrement: 5,
);
