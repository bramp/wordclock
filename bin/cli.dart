// ignore_for_file: avoid_print
import 'dart:io';

import 'package:wordclock/generator/grid_generator.dart';
import 'package:wordclock/languages/all.dart';
import 'package:wordclock/model/word_grid.dart';

void main(List<String> args) {
  // Defaults
  int width = 11;
  int? seed;
  List<String> languages = ['en'];
  DateTime now = DateTime.now();

  final availableIds = WordClockLanguages.byId.keys.toList();

  // Simple Argument Parsing
  for (var arg in args) {
    if (arg.startsWith('--lang=')) {
      final raw = arg.substring(7);
      if (raw == 'all') {
        languages = availableIds;
      } else {
        languages = raw.split(',');
      }
    } else if (arg.startsWith('--width=')) {
      width = int.parse(arg.substring(8));
    } else if (arg.startsWith('--seed=')) {
      seed = int.tryParse(arg.substring(7));
    } else if (!arg.startsWith('--')) {
      // Assume time in HH:mm
      try {
        final parts = arg.split(':');
        if (parts.length == 2) {
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          now = DateTime(now.year, now.month, now.day, hour, minute);
        }
      } catch (e) {
        print('Error parsing time: $e');
        exit(1);
      }
    }
  }

  print(
    'Time: ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
  );

  for (final lang in languages) {
    _processLanguage(lang, width, seed, now);
  }
}

void _processLanguage(String lang, int width, int? seed, DateTime now) {
  print('\n=== Language: $lang ===');

  // Select Language
  final language = WordClockLanguages.byId[lang];
  if (language == null) {
    print('Unsupported language: $lang');
    print('Supported languages: ${WordClockLanguages.byId.keys.join(', ')}');
    return;
  }

  print('Generating grid for lang="$lang", width=$width, seed=$seed...');
  final letters = GridGenerator.generate(
    width: width,
    seed: seed,
    language: language,
  );

  final grid = WordGrid(width: width, letters: letters);

  final phrase = language.timeToWords.convert(now);
  print('Phrase: "$phrase"');

  final activeIndices = grid.getIndices(phrase);
  _printGrid(grid, activeIndices);
}

void _printGrid(WordGrid grid, Set<int> activeIndices) {
  // ANSI Colors
  const String reset = '\x1B[0m';
  const String bold = '\x1B[1m';
  const String dim = '\x1B[2m';
  const String activeColor = '\x1B[38;5;87m'; // Cyan-ish
  const String inactiveColor = '\x1B[38;5;240m'; // Dark Grey

  final buffer = StringBuffer();

  // Determine if we need wide mode (for CJK)
  // Check if any character in the grid is wide (> 255)
  final bool useWideMode = grid.letters.runes.any((c) => c > 255);

  // Border width calculation:
  // Compact (ASCII): | C C | -> 2 + w*2 + 1 = 2w+3. Dashes = 2w+1.
  // Wide (CJK): | C  C  | -> 2 + w*3 + 1 = 3w+3. Dashes = 3w+1.
  final int dashCount = useWideMode
      ? (grid.width * 3 + 1)
      : (grid.width * 2 + 1);

  buffer.writeln('+${'-' * dashCount}+');

  int index = 0;
  for (int y = 0; y < grid.height; y++) {
    buffer.write('| ');
    for (int x = 0; x < grid.width; x++) {
      if (index >= grid.letters.length) break;
      final char = grid.letters[index];
      final isActive = activeIndices.contains(index);

      String padding;
      if (useWideMode) {
        // Enforce 3-cell alignment
        final isCharWide = char.runes.first > 255;
        padding = isCharWide ? ' ' : '  ';
      } else {
        // Standard compact 2-cell alignment
        padding = ' ';
      }

      if (isActive) {
        buffer.write('$bold$activeColor$char$reset$padding');
      } else {
        buffer.write('$dim$inactiveColor$char$reset$padding');
      }
      index++;
    }
    buffer.writeln('|');
  }

  buffer.writeln('+${'-' * dashCount}+');

  print(buffer.toString());
}
