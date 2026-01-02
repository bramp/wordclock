import 'dart:convert';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/logic/scriptable_time_to_words.dart';
import 'package:wordclock/logic/time_to_words.dart';
import 'package:wordclock/model/word_grid.dart';

/// A language implementation that loads its data from the ScriptableWordClockWidget dataset.
class ScriptableLanguage implements WordClockLanguage {
  final String code;
  final String name;
  final ScriptableLanguageData data;

  ScriptableLanguage(this.code, this.name, this.data);

  @override
  String get displayName => name;

  @override
  TimeToWords get timeToWords {
    return ScriptableTimeToWords(data);
  }

  // TODO We should derive this from the data
  @override
  String get paddingAlphabet => "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

  @override
  WordGrid get defaultGrid {
    return WordGrid(width: data.width, letters: data.grid);
  }

  @override
  int get minuteIncrement => 5;

  /// Loads all languages from the Scriptable JSON data.
  /// Throws an [ArgumentError] if a language code in the JSON is unknown.
  static Map<String, ScriptableLanguage> loadAll(String jsonStr) {
    final Map<String, dynamic> jsonMap = jsonDecode(jsonStr);
    final Map<String, ScriptableLanguage> languages = {};

    // Map of codes to display names and examples (from Qlocktwo variants)
    final names = {
      'NS':
          'Niedersächsisch', // Low German (Note: Data contains placeholder text)
      'E3': 'English (Digital)', // e.g., 10:15 -> "TEN FIFTEEN"
      'CA': 'Català', // Catalan (Traditional "quarter of the next hour" system)
      'CH': 'Bärndütsch', // Bernese German (e.g., 10:15 -> "VIERTU AB ZÄNI")
      'CS': 'Chinese (Simplified)', // e.g., 10:15 -> "十点十五分"
      'CT': 'Chinese (Traditional)', // e.g., 10:15 -> "十點十五分"
      'CZ': 'Čeština', // Czech (e.g., 10:15 -> "DESET PATNÁCT")
      'D2':
          'Deutsch (Alternative)', // Mixed: "VIERTEL NACH" (:15) but "DREIVIERTEL" (:45)
      'D3':
          'Deutsch (Alternative 2)', // Swabian/Bavarian (e.g., 10:15 -> "VIERTL ELFE")
      'D4':
          'Deutsch (Alternative 3)', // East German/Austrian (e.g., 10:15 -> "VIERTEL ELF")
      'DE': 'Deutsch', // Standard German (e.g., 10:15 -> "VIERTEL NACH ZEHN")
      'DK': 'Dansk', // Danish (e.g., 10:15 -> "KVART OVER TI")
      'E2':
          'English (Alternative)', // Includes "A" (e.g., 10:15 -> "A QUARTER PAST TEN")
      'EN': 'English', // Standard English (e.g., 10:15 -> "QUARTER PAST TEN")
      'ES': 'Español', // Spanish (e.g., 10:15 -> "DIEZ Y CUARTO")
      'FR': 'Français', // French (e.g., 10:15 -> "DIX HEURES ET QUART")
      'GR': 'Ελληνικά', // Greek (e.g., 10:15 -> "ΔEKA KAI TETAPTO")
      'HE': 'עברית', // Hebrew (e.g., 10:15 -> "עשר ורבע")
      'IT': 'Italiano', // Italian (e.g., 10:15 -> "DIECI E UN QUARTO")
      'JP': '日本語', // Japanese (e.g., 10:15 -> "十時十五分です")
      'NL': 'Nederlands', // Dutch (e.g., 10:15 -> "KWART OVER TIEN")
      'NO': 'Norsk', // Norwegian (e.g., 10:15 -> "KVART OVER TI")
      'PE': 'Português', // Portuguese (e.g., 10:15 -> "DEZ HORAS E UM QUARTO")
      'RO': 'Română', // Romanian (e.g., 10:15 -> "ZECE ŞI UN SFERT")
      'RU': 'Русский', // Russian (e.g., 10:15 -> "ДЕСЯТЬ ПЯТНАДЦАТЬ")
      'SE': 'Svenska', // Swedish (e.g., 10:15 -> "KVART ÖVER TIO")
      'TR': 'Türkçe', // Turkish (e.g., 10:15 -> "ONU ÇEYREK GEÇİYOR")
    };

    jsonMap.forEach((code, dataJson) {
      final name = names[code];
      if (name == null) {
        throw ArgumentError(
          'Unknown language code in Scriptable dataset: $code',
        );
      }
      final data = ScriptableLanguageData.fromJson(dataJson);
      languages[code] = ScriptableLanguage(code, name, data);
    });

    return languages;
  }
}
