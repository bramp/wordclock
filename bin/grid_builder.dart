import 'package:args/args.dart';
import 'package:wordclock/generator/backtracking/grid_builder.dart';
import 'package:wordclock/generator/greedy/dependency_graph.dart';
import 'package:wordclock/generator/greedy/dot_exporter.dart';
import 'package:wordclock/generator/greedy/grid_builder.dart';
import 'package:wordclock/generator/utils/grid_build_result.dart';
import 'package:wordclock/generator/utils/grid_validator.dart';
import 'package:wordclock/generator/backtracking/graph/graph_builder.dart';
import 'package:wordclock/generator/backtracking/dot_exporter.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/languages/all.dart';
import 'package:wordclock/model/word_grid.dart';

// ignore_for_file: avoid_print

/// Convert StopReason to human-readable string
String _stopReasonToString(StopReason reason) {
  switch (reason) {
    case StopReason.completed:
      return 'Search completed';
    case StopReason.timeout:
      return 'Timeout reached';
    case StopReason.maxIterations:
      return 'Max iterations reached';
    case StopReason.userStopped:
      return 'Stopped by timeout/user';
  }
}

/// ANSI color codes for terminal output
class AnsiColors {
  static const String reset = '\x1B[0m';
  static const String dim = '\x1B[2m';

  // Bright foreground colors for better visibility
  static const List<String> wordColors = [
    '\x1B[91m', // Bright Red
    '\x1B[92m', // Bright Green
    '\x1B[93m', // Bright Yellow
    '\x1B[94m', // Bright Blue
    '\x1B[95m', // Bright Magenta
    '\x1B[96m', // Bright Cyan
    '\x1B[31m', // Red
    '\x1B[32m', // Green
    '\x1B[33m', // Yellow
    '\x1B[34m', // Blue
    '\x1B[35m', // Magenta
    '\x1B[36m', // Cyan
  ];

  static String getColor(int index) => wordColors[index % wordColors.length];
}

/// Builds a color map from word placements: (row, col) -> color code
Map<int, Map<int, String>> _buildColorMap(List<PlacedWordInfo> placements) {
  final colorMap = <int, Map<int, String>>{};
  for (int i = 0; i < placements.length; i++) {
    final p = placements[i];
    final color = AnsiColors.getColor(i);
    colorMap.putIfAbsent(p.row, () => {});
    for (int col = p.startCol; col <= p.endCol; col++) {
      colorMap[p.row]![col] = color;
    }
  }
  return colorMap;
}

/// Formats a single row with colors applied
String _formatColoredRow(
  List<String> cells,
  int width,
  int row,
  Map<int, Map<int, String>> colorMap,
) {
  final buffer = StringBuffer();
  for (int col = 0; col < width; col++) {
    final cell = cells[row * width + col];
    final color = colorMap[row]?[col];
    if (color != null) {
      buffer.write('$color$cell${AnsiColors.reset}');
    } else {
      buffer.write('${AnsiColors.dim}$cell${AnsiColors.reset}');
    }
  }
  return buffer.toString();
}

/// Prints a grid with each word colored differently
void printColoredGrid(
  List<String> cells,
  int width,
  List<PlacedWordInfo> placements, {
  String? header,
}) {
  final height = cells.length ~/ width;
  final colorMap = _buildColorMap(placements);

  if (header != null) print(header);
  for (int row = 0; row < height; row++) {
    print(_formatColoredRow(cells, width, row, colorMap));
  }
}

class Config {
  final int gridWidth;
  final int? seed;
  final WordClockLanguage language;
  final bool outputDot;
  final int targetHeight;
  final bool checkAll;
  final String algorithm;

  Config({
    required this.gridWidth,
    this.seed,
    required this.language,
    required this.outputDot,
    required this.targetHeight,
    required this.checkAll,
    required this.algorithm,
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
    ..addOption(
      'algorithm',
      abbr: 'a',
      defaultsTo: 'backtracking',
      allowed: ['greedy', 'backtracking'],
      help:
          'Grid generation algorithm to use (greedy=fast, backtracking=thorough).',
    )
    ..addFlag(
      'dot',
      help:
          'Output the dependency graph in DOT format (character-level for greedy, word-level for backtracking).',
    )
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
    targetHeight: int.parse(results['height'] as String),
    checkAll: results['check-all'] as bool,
    algorithm: results['algorithm'] as String,
  );

  if (config.checkAll) {
    _runCheckAll(config);
    return;
  }

  if (config.outputDot) {
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
  if (config.algorithm == 'backtracking') {
    // Export word-level dependency graph for backtracking algorithm
    final wordGraph = WordDependencyGraphBuilder.build(
      language: config.language,
    );
    print(WordGraphDotExporter.export(wordGraph));
  } else {
    // Export character-level dependency graph for greedy algorithm
    final graph = DependencyGraphBuilder.build(language: config.language);
    print(DotExporter.export(graph));
  }
}

void _generateAndPrintGrid(Config config) {
  try {
    final int finalSeed = config.seed ?? 0;
    final int targetHeight = config.targetHeight > 0 ? config.targetHeight : 10;

    print('Using algorithm: ${config.algorithm}');
    print('Target: ${config.gridWidth}x$targetHeight');
    print('Seed: $finalSeed');
    print('');

    if (config.algorithm == 'backtracking') {
      _generateWithBacktracking(config);
      return;
    }

    // Use GreedyGridBuilder
    _generateWithGreedy(config);
  } catch (e) {
    print('Error generating grid: $e');
  }
}

void _generateWithGreedy(Config config) {
  final int finalSeed = config.seed ?? 0;
  final int targetHeight = config.targetHeight > 0 ? config.targetHeight : 10;

  print('Greedy Grid Builder');
  print('Note: The greedy algorithm does NOT support physical word overlap.');
  print(
    '      TimeCheckGrids may be more compact due to hand-optimized word placement.',
  );
  print('');

  final builder = GreedyGridBuilder(
    width: config.gridWidth,
    height: targetHeight,
    language: config.language,
    seed: finalSeed,
  );

  final result = builder.build();

  if (result.grid == null) {
    print('\nFailed to generate grid with greedy algorithm.');
    if (result.validationIssues.isNotEmpty) {
      print('Reasons:');
      for (final issue in result.validationIssues) {
        print('  - $issue');
      }
    }
    print('\nTry:');
    print('  - Increasing height');
    print('  - Increasing width');
    print('  - Using the backtracking algorithm: --algorithm=backtracking');
    return;
  }

  // Print warnings if not optimal
  if (!result.isOptimal) {
    print('\n⚠️⚠️⚠️ WARNING: Grid is not optimal ⚠️⚠️⚠️');
    if (result.placedWords < result.totalWords) {
      print('  - Only placed ${result.placedWords}/${result.totalWords} words');
    }
    if (result.validationIssues.isNotEmpty) {
      print('  - Validation issues:');
      for (final issue in result.validationIssues) {
        print('    * $issue');
      }
    }
    print('⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️\n');
  } else {
    print('\n✓✓✓ Grid is optimal! ✓✓✓\n');
  }

  // Output the grid
  print('\n/// AUTOMATICALLY GENERATED (Greedy Algorithm)');
  print('/// Seed: $finalSeed');
  print('  defaultGrid: WordGrid.fromLetters(');
  print('    width: ${config.gridWidth},');
  print('    letters:');

  final cells = result.grid!;
  for (int i = 0; i < targetHeight; i++) {
    final line = cells
        .sublist(i * config.gridWidth, (i + 1) * config.gridWidth)
        .join('');
    final escapedLine = line.replaceAll('"', r'\"');
    print('        "$escapedLine"');
  }
  print('  ),');
}

void _generateWithBacktracking(Config config) {
  final int finalSeed = config.seed ?? 0;
  final int targetHeight = config.targetHeight > 0 ? config.targetHeight : 10;
  const int maxSearchTimeSeconds = 60;

  print('Timeout: ${maxSearchTimeSeconds}s');
  print('');

  final deadline = DateTime.now().add(Duration(seconds: maxSearchTimeSeconds));

  final builder = BacktrackingGridBuilder(
    width: config.gridWidth,
    height: targetHeight,
    language: config.language,
    seed: finalSeed,
    onProgress: (progress) {
      final elapsed = DateTime.now().difference(progress.startTime);
      final elapsedSecs = elapsed.inMilliseconds / 1000.0;
      final rate = elapsedSecs > 0 ? progress.iterationCount / elapsedSecs : 0;
      final rateStr = rate.toStringAsFixed(0);
      printColoredGrid(
        progress.cells,
        progress.width,
        progress.wordPlacements,
        header:
            '\n--- Search: ${progress.currentWords}/${progress.totalWords} words (Best: ${progress.bestWords}) | ${progress.iterationCount} iterations ($rateStr/s) ---',
      );

      // Return false to stop if deadline passed
      return DateTime.now().isBefore(deadline);
    },
  );

  final result = builder.build();

  // Print search statistics
  final duration = result.startTime != null
      ? DateTime.now().difference(result.startTime!)
      : Duration.zero;
  final durationSecs = duration.inMilliseconds / 1000.0;
  final rate = durationSecs > 0 ? result.iterationCount / durationSecs : 0;
  print('\n--- Search completed ---');
  print('Duration: ${durationSecs.toStringAsFixed(2)}s');
  print('Iterations: ${result.iterationCount} (${rate.toStringAsFixed(0)}/s)');
  print('Stop reason: ${_stopReasonToString(result.stopReason)}');

  if (result.grid == null) {
    print('\nFailed to generate grid with backtracking algorithm.');
    print('Try:');
    print('  - Increasing height');
    print('  - Using a different seed');
    print('  - Using the greedy algorithm: --algorithm=greedy');
    return;
  }

  // Print warnings if not optimal
  if (!result.isOptimal) {
    print('\n⚠️⚠️⚠️ WARNING: Grid is not optimal ⚠️⚠️⚠️');
    if (result.placedWords < result.totalWords) {
      print('  - Only placed ${result.placedWords}/${result.totalWords} words');
    }
    if (result.validationIssues.isNotEmpty) {
      print('  - Validation issues:');
      for (final issue in result.validationIssues) {
        print('    * $issue');
      }
    }
    print('⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️\n');
  } else {
    print('\n✓✓✓ Grid is optimal! ✓✓✓\n');
  }

  // Print call stats for debugging

  // Print colored grid for visualization
  if (result.wordPlacements.isNotEmpty) {
    printColoredGrid(
      result.grid!,
      config.gridWidth,
      result.wordPlacements,
      header: '\nColored grid (words highlighted):',
    );
  }

  // Output the grid
  print('\n/// AUTOMATICALLY GENERATED (Backtracking Algorithm)');
  print('/// Seed: $finalSeed');
  print('  defaultGrid: WordGrid.fromLetters(');
  print('    width: ${config.gridWidth},');
  print('    letters:');

  final cells = result.grid!;
  for (int i = 0; i < targetHeight; i++) {
    final line = cells
        .sublist(i * config.gridWidth, (i + 1) * config.gridWidth)
        .join('');
    final escapedLine = line.replaceAll('"', r'\"');
    print('        "$escapedLine"');
  }
  print('  ),');
}

List<String> _validateGrid(
  WordGrid grid,
  WordClockLanguage language, {
  int? expectedWidth,
  int? expectedHeight,
}) {
  // Use the shared GridValidator
  return GridValidator.validate(
    grid,
    language,
    expectedWidth: expectedWidth,
    expectedHeight: expectedHeight,
  );
}
