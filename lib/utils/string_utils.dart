import 'package:characters/characters.dart';

extension WordClockStringExtension on String {
  /// Splits the string into "glyphs" suitable for Word Clock processing.
  ///
  /// This handles script-specific merging (like Tengwar Tehtar) that would
  /// ideally be part of Unicode grapheme clusters if the script were standardized.
  ///
  /// This does NOT handle grid-specific aesthetic merging like apostrophes.
  Iterable<String> get glyphs {
    final List<String> result = [];
    for (final char in characters) {
      if (char.isTengwarTehta() && result.isNotEmpty) {
        result[result.length - 1] = result.last + char;
      } else {
        result.add(char);
      }
    }
    return result;
  }

  /// Returns true if this character (or grapheme cluster) is a Tengwar Tehta
  /// (vowel mark) that should be merged with the preceding character.
  bool isTengwarTehta() {
    // Alcarin Tengwar / Dan Smith mapping uses E040-E05F for these.
    if (length == 1) {
      final codeUnit = codeUnitAt(0);
      return codeUnit >= 0xE040 && codeUnit <= 0xE05F;
    }
    return false;
  }

  /// Returns true if this character is a standard or typographic apostrophe.
  bool isApostrophe() {
    return this == "'" || this == "’";
  }
}
