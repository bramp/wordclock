// ignore_for_file: avoid_print
import 'dart:io';

import 'package:wordclock/model/word_grid.dart';

void main(List<String> args) {
  // 1. Determine Time
  DateTime now = DateTime.now();
  if (args.isNotEmpty) {
    try {
      final parts = args[0].split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        now = DateTime(now.year, now.month, now.day, hour, minute);
      } else {
        print('Invalid format. Use HH:mm');
        exit(1);
      }
    } catch (e) {
      print('Error parsing time: $e');
      exit(1);
    }
  }

  print(
    'Time: ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
  );

  // 2. Logic: Time to Indices
  final grid = WordGrid.english11x10;
  final activeIndices = grid.getIndices(now);

  final phrase = grid.timeConverter.convert(now);
  print('Phrase: "$phrase"');

  // 4. Render
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

  buffer.writeln('+${'-' * (grid.width * 2 + 1)}+');

  int index = 0;
  for (int y = 0; y < grid.height; y++) {
    buffer.write('| ');
    for (int x = 0; x < grid.width; x++) {
      if (index >= grid.letters.length) break;
      final char = grid.letters[index];
      final isActive = activeIndices.contains(index);

      if (isActive) {
        buffer.write('$bold$activeColor$char$reset ');
      } else {
        buffer.write('$dim$inactiveColor$char$reset ');
      }
      index++;
    }
    buffer.writeln('|');
  }

  buffer.writeln('+${'-' * (grid.width * 2 + 1)}+');
  print(buffer.toString());
}
