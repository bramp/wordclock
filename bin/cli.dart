// ignore_for_file: avoid_print
import 'dart:io';

import 'package:wordclock/languages/all.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';

/// Returns true if a character should be treated as a double-width character.
bool isWide(int charCode) => charCode >= 0x2000;

/// Returns true if any character in the text requires wide-mode alignment.
bool needsWideMode(List<String> cells) => cells.any((c) => c.runes.any(isWide));

void main(List<String> args) {
  // Defaults
  List<String> languages = ['EN'];
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
    _processLanguage(lang, now);
  }
}

void _processLanguage(String lang, DateTime now) {
  print('\n=== Language: $lang ===');

  // Select Language
  final language = WordClockLanguages.all.firstWhere(
    (l) => l.id.toLowerCase() == lang.toLowerCase(),
    orElse: () => throw ArgumentError('Unsupported language: $lang'),
  );

  final grid = _getGrid(language);

  final phrase = language.timeToWords.convert(now);
  print('Phrase: "$phrase"');

  final units = language.tokenize(phrase);
  final activeIndices = grid.getIndices(
    units,
    requiresPadding: language.requiresPadding,
  );
  _printGrid(grid, activeIndices);
}

WordGrid _getGrid(WordClockLanguage language) {
  if (language.defaultGrid == null) {
    throw ArgumentError('Language "${language.id}" has no default grid.');
  }

  return language.defaultGrid!;
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
  final bool useWideMode = needsWideMode(grid.cells);

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
      if (index >= grid.cells.length) break;
      final char = grid.cells[index];
      final isActive = activeIndices.contains(index);

      String padding;
      if (useWideMode) {
        // Enforce 3-cell alignment
        final isCharWide = isWide(char.runes.first);
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
