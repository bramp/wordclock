import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/turkish_time_to_words.dart';

final turkishLanguage = WordClockLanguage(
  id: 'TR',
  languageCode: 'tr-TR',
  displayName: 'Türkçe',
  description: null,
  timeToWords: TurkishTimeToWords(),
  paddingAlphabet: 'RDYARIMAMSKPMM',
  timeCheckGrid: WordGrid.fromLetters(
    width: 11,
    letters:
        'SAATRONUÜÇÜ'
        'BİRİALTIYID'
        'İKİYİDOKUZU'
        'DÖRDÜYEDİYİ'
        'SEKIZİYARIM'
        'DÖRTAMSBEŞİ'
        'KPMOTUZKIRK'
        'ELLİONYİRMİ'
        'BUÇUKÇEYREK'
        'BEŞMGEÇİYOR',
  ),
  minuteIncrement: 5,
);
