// ignore_for_file: avoid_print
import 'dart:io';

import 'package:wordclock/generator/grid_generator.dart';
import 'package:wordclock/logic/time_to_words.dart';
import 'package:wordclock/model/word_grid.dart';

void main(List<String> args) {
  // Defaults
  int width = 11;
  int? seed;
  String lang = 'en';
  DateTime now = DateTime.now();

  // Simple Argument Parsing
  for (var arg in args) {
    if (arg.startsWith('--lang=')) {
      lang = arg.substring(7);
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

  // Select Language
  TimeToWords converter;
  switch (lang) {
    case 'en':
      converter = EnglishTimeToWords();
      break;
    default:
      print('Unsupported language: $lang');
      print('Supported languages: en');
      exit(1);
  }

  print('Generating grid for lang="$lang", width=$width, seed=$seed...');
  final letters = GridGenerator.generate(
    width: width,
    seed: seed,
    language: converter,
  );

  final grid = WordGrid(
    width: width,
    letters: letters,
    timeConverter: converter,
  );

  print(
    'Time: ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
  );
  final phrase = converter.convert(now);
  print('Phrase: "$phrase"');

  final activeIndices = grid.getIndices(now);
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
