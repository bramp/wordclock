// ignore_for_file: avoid_print
import 'dart:io';
import 'package:wordclock/languages/all.dart';

import 'package:wordclock/utils/font_helper.dart';
import 'package:wordclock/utils/string_utils.dart';
import 'package:wordclock/generator/utils/word_clock_utils.dart';

// Helper to scan a directory for text files (e.g. .arb, .dart) and extract content
Future<Set<String>> scanDirectory(
  Directory dir,
  List<String> extensions,
) async {
  final chars = <String>{};
  if (!await dir.exists()) return chars;

  await for (final entity in dir.list(recursive: true)) {
    if (entity is File) {
      final path = entity.path;
      if (extensions.any((ext) => path.endsWith(ext))) {
        try {
          final content = await entity.readAsString();
          for (final char in content.glyphs) {
            final s = char;
            // Basic check to avoid control chars, etc.
            if (s.trim().isNotEmpty) {
              chars.add(s);
            }
          }
        } catch (e) {
          print('Error reading $path: $e');
        }
      }
    }
  }
  return chars;
}

void main() async {
  // Map of Font Family -> Set of characters
  final Map<String, Set<String>> fontChars = {
    'Noto Sans': {},
    'Noto Sans Tamil': {},
    'Noto Sans JP': {},
    'Noto Sans SC': {},
    'Noto Sans TC': {},
    'KlingonHaSta': {},
    'AlcarinTengwar': {},
  };

  // Iterate over all supported languages
  for (final language in WordClockLanguages.all) {
    final fontFamily = FontHelper.getFontFamilyFromTag(language.languageCode);
    final chars = fontChars[fontFamily]!;

    // Iterate over all grids for the language to get all possible words
    for (final grid in language.grids) {
      final timeToWords = grid.timeToWords;

      WordClockUtils.forEachTime(language, (time, phrase) {
        final words = language.tokenize(phrase);
        for (final word in words) {
          chars.addAll(word.glyphs);
        }
      }, timeToWords: timeToWords);

      // Add characters from paddingAlphabet
      chars.addAll(grid.paddingAlphabet.glyphs);
    }

    // Also add characters from the language name/native name if displayed
    chars.addAll(language.displayName.glyphs);
  }

  // Future-proofing: Scan lib/l10n or similar if it exists
  // For now, we assume l10n strings use the default font (Noto Sans)
  // or we need a way to detect their language.
  // Since we don't have l10n setup yet, we skip or add to Noto Sans.
  final extraChars = await scanDirectory(Directory('lib/l10n'), ['.arb']);
  fontChars['Noto Sans']!.addAll(extraChars);

  // Write files
  for (final entry in fontChars.entries) {
    var family = entry.key.replaceAll(' ', '');
    // Handle NotoSans variants
    final chars = entry.value.toList()..sort();

    if (chars.isEmpty && family != 'NotoSans') {
      print('Warning: No characters found for $family');
      continue;
    }

    print('$family: ${chars.length} unique characters');

    final filename = 'characters_$family.txt';
    final file = File(filename);
    await file.writeAsString(chars.join());
    print('Saved to $filename');
  }
}
