import 'package:args/args.dart';
import 'package:wordclock/generator/dependency_graph.dart';
import 'package:wordclock/generator/dot_exporter.dart';
import 'package:wordclock/generator/grid_generator.dart';
import 'package:wordclock/generator/mermaid_exporter.dart';
import 'package:wordclock/generator/topological_sort.dart';
import 'package:wordclock/generator/utils/word_clock_utils.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/languages/all.dart';
import 'package:wordclock/model/word_grid.dart';

// ignore_for_file: avoid_print

class Config {
  final int gridWidth;
  final int? seed;
  final WordClockLanguage language;
  final bool outputDot;
  final bool outputMermaid;
  final int targetHeight;
  final bool checkAll;

  Config({
    required this.gridWidth,
    this.seed,
    required this.language,
    required this.outputDot,
    required this.outputMermaid,
    required this.targetHeight,
    required this.checkAll,
  });
}

void main(List<String> args) {
  final parser = ArgParser()
    ..addFlag('check-all', help: 'Check all languages for grid issues.')
    ..addOption('seed', help: 'Seed for the random number generator.')
    ..addOption(
      'width',
      abbr: 'w',
      defaultsTo: '11',
      help: 'Width of the grid.',
    )
    ..addOption(
      'height',
      abbr: 'h',
      defaultsTo: '10',
      help: 'Target height of the grid.',
    )
    ..addOption(
      'lang',
      abbr: 'l',
      defaultsTo: 'EN',
      help: 'Language ID to use.',
    )
    ..addFlag('dot', help: 'Output the dependency graph in DOT format.')
    ..addFlag('mermaid', help: 'Output the dependency graph in Mermaid format.')
    ..addFlag(
      'help',
      abbr: '?',
      negatable: false,
      help: 'Show this help message.',
    );

  final ArgResults results;
  try {
    results = parser.parse(args);
  } catch (e) {
    print(e);
    print(parser.usage);
    return;
  }

  if (results['help'] as bool) {
    print(parser.usage);
    return;
  }

  final inputId = results['lang'] as String;
  final match = WordClockLanguages.all
      .where((l) => l.id.toLowerCase() == inputId.toLowerCase())
      .toList();

  if (match.isEmpty) {
    print('Error: Unknown language ID "$inputId".');
    print('Available IDs: ${WordClockLanguages.byId.keys.join(', ')}');
    return;
  }

  final config = Config(
    gridWidth: int.parse(results['width'] as String),
    seed: int.tryParse(results['seed'] ?? ''),
    language: match.first,
    outputDot: results['dot'] as bool,
    outputMermaid: results['mermaid'] as bool,
    targetHeight: int.parse(results['height'] as String),
    checkAll: results['check-all'] as bool,
  );

  if (config.checkAll) {
    _runCheckAll(config);
    return;
  }

  if (config.outputDot || config.outputMermaid) {
    _exportGraph(config);
    return;
  }

  _generateAndPrintGrid(config);
}

void _runCheckAll(Config config) {
  int targetHeight = config.targetHeight == 0 ? 10 : config.targetHeight;
  print('# Grid Status Report (Target Width: ${config.gridWidth})\n');

  final languages = WordClockLanguages.all.toList()
    ..sort((a, b) => a.id.toLowerCase().compareTo(b.id.toLowerCase()));

  for (final lang in languages) {
    final issues = <String>[];
    final int? cliHeight = targetHeight > 0 ? targetHeight : null;

    // Check Default Grid
    if (lang.defaultGrid == null) {
      issues.add('Missing defaultGrid.');
    } else {
      final g = lang.defaultGrid!;
      final gridIssues = _validateGrid(
        g,
        lang,
        expectedWidth: config.gridWidth,
        expectedHeight: cliHeight ?? g.height,
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
        expectedWidth: config.gridWidth,
        expectedHeight: cliHeight ?? g.height,
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
}

void _exportGraph(Config config) {
  final graph = DependencyGraphBuilder.build(language: config.language);
  if (config.outputDot) {
    print(DotExporter.export(graph));
  } else if (config.outputMermaid) {
    print(MermaidExporter.export(graph));
  }
}

void _generateAndPrintGrid(Config config) {
  try {
    List<String> cells = [];
    int finalSeed = config.seed ?? 0;

    if (config.targetHeight > 0) {
      // 1. Build graph once to check feasibility
      final graph = DependencyGraphBuilder.build(language: config.language);
      final sortedNodes = TopologicalSorter.sort(graph);

      // Calculate effective cell count (nodes might represent multi-character cells like "D'")
      final uniquePositions = <String>{};
      for (final node in sortedNodes) {
        uniquePositions.add('${node.word}_${node.charIndex}');
      }
      final totalCells = uniquePositions.length;
      final capacity = config.gridWidth * config.targetHeight;

      print(
        'Target: ${config.gridWidth}x${config.targetHeight} ($capacity cells)',
      );
      print(
        'Required: $totalCells unique positions (${sortedNodes.length} nodes)',
      );
      print('');
      print('Note: The grid builder does NOT support physical word overlap.');
      print(
        '      TimeCheckGrids may be more compact due to hand-optimized word placement.',
      );
      print('      If target height cannot be achieved, consider:');
      print('      1. Using the closest height the builder can achieve');
      print('      2. Increasing grid width');
      print('      3. Hand-crafting the grid with overlapping words');
      print('');

      if (totalCells > capacity) {
        print(
          'Warning: Target height ${config.targetHeight} may be impossible.',
        );
        print(
          '         Need at least $totalCells cells, but grid only has $capacity.',
        );
      }

      // Search for a seed that hits targetHeight or gets close
      bool foundExact = false;
      int bestSeed = config.seed ?? 0;
      int bestHeight = 9999;
      int bestHeightDiff = 9999;

      final startSeed = config.seed ?? 0;
      final maxSearches = 5000; // Search more thoroughly

      for (int s = startSeed; s < startSeed + maxSearches; s++) {
        cells = GridGenerator.generate(
          width: config.gridWidth,
          seed: s,
          language: config.language,
          targetHeight: config.targetHeight,
        );
        final currentHeight = cells.length ~/ config.gridWidth;
        final heightDiff = (currentHeight - config.targetHeight).abs();

        if (s % 10 == 0 || heightDiff < bestHeightDiff) {
          print('Searching for grid... (Seed: $s, Height: $currentHeight)');
        }

        if (currentHeight == config.targetHeight) {
          finalSeed = s;
          bestHeight = currentHeight;
          foundExact = true;
          break;
        }

        // Track best alternative
        if (heightDiff < bestHeightDiff) {
          bestSeed = s;
          bestHeight = currentHeight;
          bestHeightDiff = heightDiff;
        }
      }

      if (!foundExact) {
        finalSeed = bestSeed;
        // Regenerate with best seed
        cells = GridGenerator.generate(
          width: config.gridWidth,
          seed: bestSeed,
          language: config.language,
          targetHeight: config.targetHeight,
        );
        bestHeight = cells.length ~/ config.gridWidth;
        print(
          'Warning: Could not find exact height ${config.targetHeight} within $maxSearches seeds.',
        );
        print('Best result: Height $bestHeight (seed $bestSeed)');
      } else {
        print('Found exact match at seed $finalSeed');
      }
    } else {
      cells = GridGenerator.generate(
        width: config.gridWidth,
        seed: finalSeed,
        language: config.language,
      );
    }

    // Check if merging produces a different length
    final mergedCells = WordGrid.splitIntoCells(
      cells.join(''),
      mergeApostrophes: true,
    );

    final currentHeight = mergedCells.length ~/ config.gridWidth;

    print('\n/// AUTOMATICALLY GENERATED PREVIEW');
    print('/// Seed: $finalSeed');
    print('  defaultGrid: WordGrid.fromLetters(');
    print('    width: ${config.gridWidth},');
    print('    letters:');
    for (int i = 0; i < currentHeight; i++) {
      final line = mergedCells
          .sublist(i * config.gridWidth, (i + 1) * config.gridWidth)
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
    final units = language.tokenize(phrase);
    int lastEndIndex = -1;

    for (int i = 0; i < units.length; i++) {
      final unit = units[i];

      // Find unit strictly after lastEndIndex (mimics WordGrid.getIndices)
      var unitIndices = grid.findWordIndices(unit, lastEndIndex + 1);
      if (unitIndices == null && lastEndIndex != -1) {
        unitIndices = grid.findWordIndices(unit, 0, reverse: true);
      }

      if (unitIndices == null) {
        if (reportedMissingAtoms.add(unit)) {
          issues.add('Missing atom "$unit" (in phrase "$phrase")');
        }
        // Cannot continue checking sequence for this phrase
        break;
      }

      // Check Padding (Check 4)
      if (language.requiresPadding && i > 0) {
        final matchIndex = unitIndices.first;
        // Previous unit ended at lastEndIndex. Current unit starts at matchIndex.
        if (matchIndex == lastEndIndex + 1) {
          // Check if they are on the same row
          final prevRow = lastEndIndex ~/ width;
          final currRow = matchIndex ~/ width;
          if (prevRow == currRow) {
            final pairKey = '${units[i - 1]}->$unit';
            if (reportedPaddingIssues.add(pairKey)) {
              issues.add(
                'No padding/newline between "${units[i - 1]}" and "$unit" in grid.',
              );
            }
          }
        }
      }

      lastEndIndex = unitIndices.last;
    }
  });

  return issues.toList();
}
