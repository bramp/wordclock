// ignore_for_file: avoid_print
import 'package:args/command_runner.dart';
import 'package:wordclock/generator/greedy/grid_builder.dart';
import 'package:wordclock/generator/backtracking/grid_builder.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/generator/model/grid_build_result.dart';
import '../utils/config.dart';
import '../utils/utils.dart';

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

class SolveCommand extends Command<void> {
  @override
  final String name = 'solve';
  @override
  final String description =
      'Generate a new grid layout (default algorithm: backtracking).';

  SolveCommand() {
    argParser
      ..addOption(
        'lang',
        abbr: 'l',
        mandatory: true,
        help: 'Language ID to use.',
      )
      ..addOption('width', abbr: 'w', defaultsTo: '11', help: 'Grid width.')
      ..addOption('height', defaultsTo: '10', help: 'Target grid height.')
      ..addOption('seed', help: 'Random seed.')
      ..addOption(
        'algorithm',
        abbr: 'a',
        defaultsTo: 'backtracking',
        allowed: ['greedy', 'backtracking'],
        help: 'Generation algorithm.',
      )
      ..addOption(
        'timeout',
        abbr: 't',
        defaultsTo: '60',
        help: 'Max search time in seconds.',
      )
      ..addFlag(
        'use-ranks',
        help: 'Use rank-based solving (backtracking only).',
      );
  }

  @override
  void run() {
    final lang = getLanguage(argResults!);
    final config = Config(
      gridWidth: int.parse(argResults!['width']),
      targetHeight: int.parse(argResults!['height']),
      seed: int.tryParse(argResults!['seed'] ?? ''),
      language: lang,
      algorithm: argResults!['algorithm'],
      timeout: int.parse(argResults!['timeout']),
      useRanks: argResults!['use-ranks'],
    );
    _generateAndPrintGrid(config);
  }

  void _generateAndPrintGrid(Config config) {
    try {
      final int finalSeed = config.seed ?? 0;
      final int targetHeight = config.targetHeight > 0
          ? config.targetHeight
          : 10;

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

    if (result.placedWords == 0) {
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
        print(
          '  - Only placed ${result.placedWords}/${result.totalWords} words',
        );
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

    final grid = result.grid;
    for (int i = 0; i < grid.height; i++) {
      final line = grid.cells
          .sublist(i * grid.width, (i + 1) * grid.width)
          .join('');
      final escapedLine = line.replaceAll('"', r'\"');
      print('        "$escapedLine"');
    }
    print('  ),');

    if (result.wordPlacements.isNotEmpty) {
      printColoredGrid(
        result.grid,
        result.wordPlacements,
        header: '\nColored grid (words highlighted):',
      );
    }
  }

  void _generateWithBacktracking(Config config) {
    final int finalSeed = config.seed ?? 0;
    final int targetHeight = config.targetHeight > 0 ? config.targetHeight : 10;
    final int maxSearchTimeSeconds = config.timeout;

    print('Timeout: ${maxSearchTimeSeconds}s');
    print('');

    final deadline = DateTime.now().add(
      Duration(seconds: maxSearchTimeSeconds),
    );

    final builder = BacktrackingGridBuilder(
      width: config.gridWidth,
      height: targetHeight,
      language: config.language,
      seed: finalSeed,
      useFrontier: !config.useRanks,
      onProgress: (progress) {
        final elapsed = DateTime.now().difference(progress.startTime);
        final elapsedSecs = elapsed.inMilliseconds / 1000.0;
        final rate = elapsedSecs > 0
            ? progress.iterationCount / elapsedSecs
            : 0;
        final rateStr = rate.toStringAsFixed(0);
        printColoredGrid(
          WordGrid(
            width: progress.width,
            cells: progress.cells.map((c) => c ?? '·').toList(),
          ),
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
    print(
      'Iterations: ${result.iterationCount} (${rate.toStringAsFixed(0)}/s)',
    );
    print('Stop reason: ${_stopReasonToString(result.stopReason)}');

    if (result.placedWords == 0) {
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
        print(
          '  - Only placed ${result.placedWords}/${result.totalWords} words',
        );
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

    // Print colored grid for visualization
    if (result.wordPlacements.isNotEmpty) {
      printColoredGrid(
        result.grid,
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

    final grid = result.grid;
    for (int i = 0; i < grid.height; i++) {
      final line = grid.cells
          .sublist(i * grid.width, (i + 1) * grid.width)
          .join('');
      final escapedLine = line.replaceAll('"', r'\"');
      print('        "$escapedLine"');
    }
    print('  ),');
  }
}
