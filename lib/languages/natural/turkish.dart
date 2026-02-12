import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/languages/natural/turkish_time_to_words.dart';

final turkishLanguage = WordClockLanguage(
  id: 'TR',
  languageCode: 'tr-TR',
  displayName: 'Türkçe',
  englishName: 'Turkish',
  description: null,
  grids: [
    // @generated begin - do not edit manually
    // Generated: 2026-02-02T20:30:08.074202
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 191404284, Duration: 38053ms
    WordClockGrid(
      isDefault: true,
      timeToWords: TurkishTimeToWords(),
      paddingAlphabet: 'ADIKMPRSY',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'SAATKALTIYI' // SAAT ALTIYI ALTI
            'DOKUZUDÖRDÜ' // DOKUZU DOKUZ DÖRDÜ
            'SEKİZİPBEŞİ' // SEKİZİ SEKİZ BEŞİ
            'DYEDİYİSÜÇÜ' // YEDİYİ YEDİ ÜÇÜ ÜÇ
            'ONURONRBİRİ' // ONU ON BİRİ BİR
            'İKİYİPYİRMİ' // İKİYİ İKİ YİRMİ
            'ÇEYREKMOTUZ' // ÇEYREK OTUZ
            'KIRKELLİONM' // KIRK ELLİ ON
            'BEŞYGEÇİYOR' // BEŞ GEÇİYOR
            'RDÖRTMBUÇUK', // DÖRT BUÇUK
      ),
    ),
    // @generated end,
    WordClockGrid(
      isReference: true,
      timeToWords: ReferenceTurkishTimeToWords(),
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
