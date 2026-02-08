// ignore_for_file: avoid_print
import 'dart:io';
import 'package:characters/characters.dart';
import 'package:wordclock/languages/all.dart';
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
  final Set<String> allChars = {};

  // Iterate over all supported languages
  for (final language in WordClockLanguages.all) {
    // Get all words for the language
    final words = WordClockUtils.getAllWords(language);

    // Add characters from each word
    for (final word in words) {
      allChars.addAll(word.characters);
    }

    // Also add characters from the language name/native name if displayed
    allChars.addAll(language.displayName.characters);

    // Add characters from paddingAlphabet of all grids
    for (final grid in language.grids) {
      allChars.addAll(grid.paddingAlphabet.characters);
    }
  }

  // Future-proofing: Scan lib/l10n or similar if it exists
  final extraChars = await scanDirectory(Directory('lib/l10n'), ['.arb']);
  allChars.addAll(extraChars);

  // Manual addition for specific UI elements if needed
  // allChars.addAll("SomeSpecificString".split(''));
  // Sort and print
  final sortedChars = allChars.toList()..sort();
  print('Total unique characters: ${sortedChars.length}');
  print('Characters: ${sortedChars.join()}');

  // Save to file for subsetting
  final file = File('characters.txt');
  await file.writeAsString(sortedChars.join());
  print('Saved to characters.txt');
}
