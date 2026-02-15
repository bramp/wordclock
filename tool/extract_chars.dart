// ignore_for_file: avoid_print
import 'dart:io';
import 'package:characters/characters.dart';
import 'package:wordclock/languages/all.dart';

import 'package:wordclock/utils/font_helper.dart';
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
          // Extract string literals or just all chars?
          // For safety, let's extract all non-ASCII chars found in the file,
          // assuming ASCII is covered by default subset.
          // This is a naive heuristic but effective for catching hardcoded specific glyphs.
          // Use characters package to correctly handle grapheme clusters
          for (final char in content.characters) {
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
    'NotoSans': {},
    'NotoSansTamil': {},
    'NotoSansJP': {},
    'NotoSansSC': {},
    'NotoSansTC': {},
    'KlingonPiqad': {},
  };

  // Iterate over all supported languages
  for (final language in WordClockLanguages.all) {
    final fontFamily = FontHelper.getFontFamilyFromTag(language.languageCode);
    final chars = fontChars[fontFamily]!;

    // Iterate over all grids for the language to get all possible words
    for (final grid in language.grids) {
      final timeToWords = grid.timeToWords;

      WordClockUtils.forEachTime(language, (time, phrase) {
        // Add characters from the phrase directly (no need to tokenize first, unless tokenization removes chars?)
        // Tokenization usually just splits by space.
        // We essentially want all characters used in the phrase.
        // If tokenize removes punctuation that we WANT (unlikely for word clock), we should be careful.
        // But usually we only display tokenized words in the grid.
        // So let's use tokenize to be safe and consistent with what ends up in the grid.
        final words = language.tokenize(phrase);
        for (final word in words) {
          chars.addAll(word.characters);
        }
      }, timeToWords: timeToWords);

      // Add characters from paddingAlphabet
      chars.addAll(grid.paddingAlphabet.characters);
    }

    // Also add characters from the language name/native name if displayed
    chars.addAll(language.displayName.characters);
  }

  // Future-proofing: Scan lib/l10n or similar if it exists
  // For now, we assume l10n strings use the default font (NotoSans)
  // or we need a way to detect their language.
  // Since we don't have l10n setup yet, we skip or add to NotoSans.
  final extraChars = await scanDirectory(Directory('lib/l10n'), ['.arb']);
  fontChars['NotoSans']!.addAll(extraChars);

  // Write files
  for (final entry in fontChars.entries) {
    final family = entry.key;
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
