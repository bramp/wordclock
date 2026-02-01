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
    // @generated begin - do not edit manually
    // Generated: 2026-01-25T09:46:29.709875
    // Algorithm: Backtracking
    // Seed: 0
    // Iterations: 191404284, Duration: 36349ms
    WordClockGrid(
      isDefault: true,
      timeToWords: ReferenceTurkishTimeToWords(),
      paddingAlphabet: 'ADIKMPRSY',
      grid: WordGrid.fromLetters(
        width: 11,
        letters:
            'SAATKALTIYI' // SAAT ALTIYI ALTI
            'DOKUZUDÖRDÜ' // DOKUZU DOKUZ DÖRDÜ
            'SEKIZİPBEŞİ' // SEKIZİ SEKIZ BEŞİ
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
