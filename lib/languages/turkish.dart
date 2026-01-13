import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/logic/turkish_time_to_words.dart';

final turkishLanguage = WordClockLanguage(
  id: 'TR',
  languageCode: 'tr-TR',
  displayName: 'Türkçe',
  englishName: 'Turkish',
  description: null,
  grids: [
    WordClockGrid(
      isDefault: true,
      timeToWords: TurkishTimeToWords(),
      paddingAlphabet: 'ADIKMPRSY',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            "SAATKALTIYI"
            "DOKUZUDÖRDÜ"
            "SEKIZİPBEŞİ"
            "DYEDİYİSÜÇÜ"
            "ONURONRBİRİ"
            "İKİYİPYİRMİ"
            "ÇEYREKMOTUZ"
            "KIRKELLİONM"
            "BEŞYGEÇİYOR"
            "RDÖRTMBUÇUK",
      ),
    ),
    WordClockGrid(
      isTimeCheck: true,
      timeToWords: TurkishTimeToWords(),
      paddingAlphabet: 'ADIKMPRSY',
      grid: WordGrid.fromLetters(
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
    ),
  ],
  minuteIncrement: 5,
);
