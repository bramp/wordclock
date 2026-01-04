import 'package:wordclock/generator/dependency_graph.dart';
import 'package:wordclock/generator/dot_exporter.dart';
import 'package:wordclock/generator/grid_generator.dart';
import 'package:wordclock/generator/mermaid_exporter.dart';
import 'package:wordclock/generator/utils/word_clock_utils.dart';
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
    if (arg.startsWith('--lang=')) {
      final inputId = arg.substring(7);
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
      // Search for a seed that hits targetHeight
      bool found = false;
      final startSeed = seed ?? 0;
      for (int s = startSeed; s < startSeed + 100; s++) {
        cells = GridGenerator.generate(
          width: gridWidth,
          seed: s,
          language: language,
          targetHeight: targetHeight,
        );
        if (cells.length ~/ gridWidth == targetHeight) {
          finalSeed = s;
          found = true;
          break;
        }
      }
      if (!found) {
        print(
          'Warning: Could not find grid with height $targetHeight within 100 seeds starting from $startSeed.',
        );
      }
    } else {
      cells = GridGenerator.generate(
        width: gridWidth,
        seed: finalSeed,
        language: language,
      );
    }

    // Check if merging produces a different length
    final mergedCells = WordGrid.splitIntoCells(
      cells.join(''),
      mergeApostrophes: true,
    );

    final currentHeight = mergedCells.length ~/ gridWidth;

    print('\n/// AUTOMATICALLY GENERATED PREVIEW');
    print('/// Seed: $finalSeed');
    print('  defaultGrid: WordGrid.fromLetters(');
    print('    width: $gridWidth,');
    print('    letters:');
    for (int i = 0; i < currentHeight; i++) {
      // Manual escaping logic if needed, but here simple quote escaping
      // Note: we assume no newlines in cells
      final line = mergedCells
          .sublist(i * gridWidth, (i + 1) * gridWidth)
          .join('');
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
    issues.add('Height $height != expected $expectedHeight.');
  }

  // We use Sets to avoid reporting the same issue multiple times
  final reportedMissingAtoms = <String>{};
  final reportedPaddingIssues = <String>{};

  WordClockUtils.forEachTime(language, (time, phrase) {
    final atoms = phrase.split(' ').where((w) => w.isNotEmpty).toList();
    int lastEndIndex = -1;

    for (int i = 0; i < atoms.length; i++) {
      final atom = atoms[i];

      // Find atom strictly after lastEndIndex (mimics WordGrid.getIndices)
      var atomIndices = grid.findWordIndices(atom, lastEndIndex + 1);
      atomIndices ??= grid.findWordIndices(atom, 0, reverse: true);

      if (atomIndices == null) {
        if (reportedMissingAtoms.add(atom)) {
          issues.add('Missing atom "$atom" (in phrase "$phrase")');
        }
        // Cannot continue checking sequence for this phrase
        break;
      }

      // Check Padding (Check 4)
      if (language.requiresPadding && i > 0) {
        final matchIndex = atomIndices.first;
        // Previous atom ended at lastEndIndex. Current atom starts at matchIndex.
        if (matchIndex == lastEndIndex + 1) {
          // Check if they are on the same row
          final prevRow = lastEndIndex ~/ width;
          final currRow = matchIndex ~/ width;
          if (prevRow == currRow) {
            final pairKey = '${atoms[i - 1]}->$atom';
            if (reportedPaddingIssues.add(pairKey)) {
              issues.add(
                'No padding/newline between "${atoms[i - 1]}" and "$atom" in grid.',
              );
            }
          }
        }
      }

      lastEndIndex = atomIndices.last;
    }
  });

  return issues.toList();
}
