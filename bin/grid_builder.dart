import 'package:wordclock/generator/dependency_graph.dart';
import 'package:wordclock/generator/dot_exporter.dart';
import 'package:wordclock/generator/grid_generator.dart';
import 'package:wordclock/generator/mermaid_exporter.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/languages/all.dart';
import 'package:wordclock/model/word_grid.dart';

// ignore_for_file: avoid_print

void main(List<String> args) {
  int gridWidth = 11; // Default
  int? seed;
  WordClockLanguage language = WordClockLanguages.byId['EN']!;
  bool outputDot = false;
  bool outputMermaid = false;

  int targetHeight = 0;

  bool checkAll = false;

  for (final arg in args) {
    if (arg == '--check-all') {
      checkAll = true;
    }
    if (arg.startsWith('--seed=')) {
      seed = int.tryParse(arg.substring(7));
    }
    if (arg.startsWith('--width=')) {
      final w = int.tryParse(arg.substring(8));
      if (w != null) gridWidth = w;
    }
    if (arg.startsWith('--height=')) {
      final h = int.tryParse(arg.substring(9));
      if (h != null) targetHeight = h;
    }
    if (arg.startsWith('--language=')) {
      final inputId = arg.substring(11);
      final match = WordClockLanguages.all
          .where((l) => l.id.toLowerCase() == inputId.toLowerCase())
          .toList();
      if (match.isNotEmpty) {
        language = match.first;
      } else {
        print('Error: Unknown language ID "$inputId".');
        print('Available IDs: ${WordClockLanguages.byId.keys.join(', ')}');
        return;
      }
    }
    if (arg == '--dot') {
      outputDot = true;
    }
    if (arg == '--mermaid') {
      outputMermaid = true;
    }
  }

  if (checkAll) {
    if (targetHeight == 0) targetHeight = 10;
    print('# Grid Status Report (Target Width: $gridWidth)\n');

    for (final lang in WordClockLanguages.all) {
      final issues = <String>[];

      // Check Default Grid
      if (lang.defaultGrid == null) {
        issues.add('Missing defaultGrid.');
      } else {
        final g = lang.defaultGrid!;
        final gridIssues = _validateGrid(
          g,
          lang,
          expectedWidth: gridWidth,
          expectedHeight: targetHeight > 0 ? targetHeight : null,
        );
        for (final issue in gridIssues) {
          issues.add('DefaultGrid: $issue');
        }
      }

      // Check TimeCheck Grid
      if (lang.timeCheckGrid != null) {
        final g = lang.timeCheckGrid!;
        final gridIssues = _validateGrid(
          g,
          lang,
          expectedWidth: gridWidth,
          expectedHeight: targetHeight > 0 ? targetHeight : null,
        );
        for (final issue in gridIssues) {
          issues.add('TimeCheckGrid: $issue');
        }
      }

      const String reset = '\x1B[0m';
      const String red = '\x1B[31m';
      const String green = '\x1B[32m';

      if (issues.isEmpty) {
        print('$green- [x] **${lang.id}** (${lang.englishName}): OK.$reset');
      } else {
        print('$red- [ ] **${lang.id}** (${lang.englishName}):$reset');
        for (final issue in issues) {
          print('$red    - $issue$reset');
        }
      }
    }
    return;
  }

  if (outputDot || outputMermaid) {
    final graph = DependencyGraphBuilder.build(language: language);
    if (outputDot) {
      print(DotExporter.export(graph));
    } else if (outputMermaid) {
      print(MermaidExporter.export(graph));
    }
    return;
  }

  try {
    List<String> cells = [];
    int finalSeed = seed ?? 0;

    if (targetHeight > 0) {
      // Search for a seed that matches targetHeight
      bool found = false;
      final startSeed = seed ?? 0;
      // Limit iterations to prevent infinite loop
      for (int s = startSeed; s < startSeed + 10000; s++) {
        cells = GridGenerator.generate(
          width: gridWidth,
          seed: s,
          language: language,
        );
        final h = cells.length ~/ gridWidth;
        if (h == targetHeight) {
          finalSeed = s;
          found = true;
          break;
        }
      }
      if (!found) {
        print(
          'Warning: Could not find grid with height $targetHeight within 10000 seeds starting from $startSeed.',
        );
        // Fallback to initial generation
        cells = GridGenerator.generate(
          width: gridWidth,
          seed: startSeed,
          language: language,
        );
      }
    } else {
      cells = GridGenerator.generate(
        width: gridWidth,
        seed: finalSeed,
        language: language,
      );
    }

    final height = cells.length ~/ gridWidth;

    print('\n/// AUTOMATICALLY GENERATED PREVIEW');
    print('/// Seed: $finalSeed');
    print('  defaultGrid: WordGrid.fromLetters(');
    print('    width: $gridWidth,');

    // Check if merging produces a different length
    final mergedCells = WordGrid.splitIntoCells(
      cells.join(''),
      mergeApostrophes: true,
    );
    if (mergedCells.length != cells.length) {
      print('    mergeApostrophes: false,');
    }

    print('    letters:');
    for (int i = 0; i < height; i++) {
      // Manual escaping logic if needed, but here simple quote escaping
      // Note: we assume no newlines in cells
      final line = cells.sublist(i * gridWidth, (i + 1) * gridWidth).join('');
      final escapedLine = line.replaceAll('"', r'\"');
      print('        "$escapedLine"');
    }
    print('  ),');
  } catch (e) {
    print('Error generating grid: $e');
  }
}

List<String> _validateGrid(
  WordGrid grid,
  WordClockLanguage language, {
  int? expectedWidth,
  int? expectedHeight,
}) {
  final issues = <String>{};
  final cells = grid.cells;
  final width = grid.width;

  if (cells.length % width != 0) {
    issues.add(
      'Grid cells length ${cells.length} is not a multiple of width $width.',
    );
  }

  if (expectedWidth != null && width != expectedWidth) {
    issues.add('Width $width != expected $expectedWidth.');
  }

  final height = cells.length ~/ width;
  if (expectedHeight != null && height != expectedHeight) {
    // Only report height mismatch if grid is not jagged,
    // or if it is jagged, report based on integer division but it might be misleading.
    // The jagged error usually takes precedence in user's mind.
    issues.add('Height $height != expected $expectedHeight.');
  }

  final timeConverter = language.timeToWords;
  final increment = language.minuteIncrement;

  // We use Sets to avoid reporting the same issue multiple times
  final reportedMissingWords = <String>{};
  final reportedPaddingIssues = <String>{};

  for (int h = 0; h < 24; h++) {
    for (int m = 0; m < 60; m += increment) {
      final time = DateTime(2025, 1, 1, h, m);
      String phrase;
      try {
        phrase = timeConverter.convert(time);
      } catch (e) {
        issues.add('Error converting time $time: $e');
        continue;
      }

      final words = phrase.split(' ').where((w) => w.isNotEmpty).toList();
      int lastEndIndex = -1;

      for (int i = 0; i < words.length; i++) {
        final word = words[i];

        // Find word strictly after lastEndIndex (mimics WordGrid.getIndices)
        int matchIndex = _findWordInGrid(cells, word, lastEndIndex + 1);
        if (matchIndex == -1) {
          // Fallback: search from start (reverse)
          matchIndex = _findWordInGrid(cells, word, 0, reverse: true);
        }

        if (matchIndex == -1) {
          if (reportedMissingWords.add(word)) {
            issues.add('Missing word "$word" (in phrase "$phrase")');
          }
          // Cannot continue checking sequence for this phrase
          break;
        }

        // Calculate how many cells this word actually consumes
        int cellLength = 0;
        String builtWord = "";
        while (builtWord.length < word.length &&
            matchIndex + cellLength < cells.length) {
          builtWord += cells[matchIndex + cellLength];
          cellLength++;
        }

        // Check Padding (Check 4)
        if (i > 0) {
          // Previous word ended at lastEndIndex.
          // Current word starts at matchIndex.
          // If they are physically adjacent:
          if (matchIndex == lastEndIndex + 1) {
            // Check if they are on the same row
            final prevRow = lastEndIndex ~/ width;
            final currRow = matchIndex ~/ width;
            if (prevRow == currRow) {
              final pairKey = '${words[i - 1]}->$word';
              if (reportedPaddingIssues.add(pairKey)) {
                issues.add(
                  'No padding/newline between "${words[i - 1]}" and "$word" in grid.',
                );
              }
            }
          }
        }

        lastEndIndex = matchIndex + cellLength - 1;
      }
    }
  }

  return issues.toList();
}

int _findWordInGrid(
  List<String> cells,
  String word,
  int start, {
  bool reverse = false,
}) {
  if (reverse) {
    for (int i = cells.length - 1; i >= 0; i--) {
      if (_matchAt(cells, word, i)) return i;
    }
  } else {
    for (int i = start; i < cells.length; i++) {
      if (_matchAt(cells, word, i)) return i;
    }
  }
  return -1;
}

bool _matchAt(List<String> cells, String word, int index) {
  String found = "";
  int i = index;
  while (found.length < word.length && i < cells.length) {
    found += cells[i];
    i++;
  }
  return found == word;
}
