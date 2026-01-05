import 'package:args/args.dart';
import 'package:wordclock/generator/backtracking/grid_builder.dart';
import 'package:wordclock/generator/greedy/dependency_graph.dart';
import 'package:wordclock/generator/greedy/dot_exporter.dart';
import 'package:wordclock/generator/greedy/grid_builder.dart';
import 'package:wordclock/generator/utils/grid_validator.dart';
import 'package:wordclock/generator/backtracking/dependency_graph.dart';
import 'package:wordclock/generator/backtracking/dot_exporter.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/languages/all.dart';
import 'package:wordclock/model/word_grid.dart';

// ignore_for_file: avoid_print

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

  print('Backtracking Grid Builder');
  print('Target: ${config.gridWidth}x$targetHeight');
  print('Seed: $finalSeed');
  print('');

  final builder = BacktrackingGridBuilder(
    width: config.gridWidth,
    height: targetHeight,
    language: config.language,
    seed: finalSeed,
    maxSearchTimeSeconds: 60,
    maxNodesExplored: 500000,
  );

  final result = builder.build();

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
