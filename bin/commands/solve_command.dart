// ignore_for_file: avoid_print
import 'package:args/command_runner.dart';
import 'package:wordclock/generator/greedy/grid_builder.dart';
import 'package:wordclock/generator/backtracking/grid_builder.dart';
import 'package:wordclock/generator/backtracking/trie_grid_builder.dart';
import 'package:wordclock/languages/all.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/generator/model/grid_build_result.dart';
import '../utils/config.dart';
import '../utils/language_file_updater.dart';
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

/// Result status for a language solve operation
enum SolveStatus {
  optimal,
  solved, // solved but not optimal
  timeout,
  failed,
  error,
}

/// Tracks the result of solving a single language
class LanguageSolveResult {
  final String langId;
  final SolveStatus status;
  final Duration duration;
  final int iterations;
  final int placedWords;
  final int totalWords;
  final String? errorMessage;

  LanguageSolveResult({
    required this.langId,
    required this.status,
    this.duration = Duration.zero,
    this.iterations = 0,
    this.placedWords = 0,
    this.totalWords = 0,
    this.errorMessage,
  });

  String get statusEmoji {
    switch (status) {
      case SolveStatus.optimal:
        return '✓';
      case SolveStatus.solved:
        return '⚠';
      case SolveStatus.timeout:
        return '⏱';
      case SolveStatus.failed:
        return '✗';
      case SolveStatus.error:
        return '❌';
    }
  }

  String get statusText {
    switch (status) {
      case SolveStatus.optimal:
        return 'Optimal';
      case SolveStatus.solved:
        return 'Solved (not optimal)';
      case SolveStatus.timeout:
        return 'Timeout';
      case SolveStatus.failed:
        return 'Failed';
      case SolveStatus.error:
        return 'Error';
    }
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
        help: 'Language ID to use (required unless --all is specified).',
      )
      ..addOption('width', abbr: 'w', defaultsTo: '11', help: 'Grid width.')
      ..addOption('height', defaultsTo: '10', help: 'Target grid height.')
      ..addOption('seed', help: 'Random seed.')
      ..addOption(
        'algorithm',
        abbr: 'a',
        defaultsTo: 'backtracking',
        allowed: ['greedy', 'backtracking', 'trie'],
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
      )
      ..addFlag(
        'update',
        abbr: 'u',
        help: 'Update the language file with the generated grid.',
      )
      ..addFlag(
        'all',
        help: 'Solve all languages and update their files (implies --update).',
      );
  }

  @override
  void run() {
    final solveAll = argResults!['all'] as bool;
    final update = argResults!['update'] as bool || solveAll;

    if (solveAll) {
      _solveAllLanguages(update);
      return;
    }

    final langId = argResults!['lang'] as String?;
    if (langId == null) {
      throw UsageException(
        '--lang is required unless --all is specified.',
        usage,
      );
    }

    final lang = getLanguage(argResults!);
    final config = Config(
      gridWidth: int.parse(argResults!['width']),
      targetHeight: int.parse(argResults!['height']),
      seed: int.tryParse(argResults!['seed'] ?? ''),
      language: lang,
      algorithm: argResults!['algorithm'],
      timeout: int.parse(argResults!['timeout']),
      useRanks: argResults!['use-ranks'],
      update: update,
    );
    _generateAndPrintGrid(config);
  }

  void _solveAllLanguages(bool update) {
    final allIds = getAllLanguageIds();
    print('Solving ${allIds.length} languages...\n');

    final results = <LanguageSolveResult>[];

    for (final langId in allIds) {
      print('=' * 60);
      print('Solving: $langId');
      print('=' * 60);

      try {
        final lang = WordClockLanguages.byId[langId]!;
        final config = Config(
          gridWidth: int.parse(argResults!['width']),
          targetHeight: int.parse(argResults!['height']),
          seed: int.tryParse(argResults!['seed'] ?? ''),
          language: lang,
          algorithm: argResults!['algorithm'],
          timeout: int.parse(argResults!['timeout']),
          useRanks: argResults!['use-ranks'],
          update: update,
        );
        final result = _generateAndPrintGrid(config);
        results.add(result);
      } catch (e) {
        print('Error solving $langId: $e');
        results.add(
          LanguageSolveResult(
            langId: langId,
            status: SolveStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
      print('');
    }

    // Print summary table
    _printSummary(results);
  }

  void _printSummary(List<LanguageSolveResult> results) {
    print('=' * 60);
    print('SUMMARY');
    print('=' * 60);
    print('');

    // Count by status
    final byStatus = <SolveStatus, List<LanguageSolveResult>>{};
    for (final result in results) {
      byStatus.putIfAbsent(result.status, () => []).add(result);
    }

    // Print counts
    final optimal = byStatus[SolveStatus.optimal]?.length ?? 0;
    final solved = byStatus[SolveStatus.solved]?.length ?? 0;
    final timeout = byStatus[SolveStatus.timeout]?.length ?? 0;
    final failed = byStatus[SolveStatus.failed]?.length ?? 0;
    final error = byStatus[SolveStatus.error]?.length ?? 0;

    print('Results: ${results.length} languages');
    print('  ✓ Optimal:    $optimal');
    print('  ⚠ Solved:     $solved (not optimal)');
    print('  ⏱ Timeout:    $timeout');
    print('  ✗ Failed:     $failed');
    print('  ❌ Error:      $error');
    print('');

    // Print table of all results
    print('Language  Status              Words     Time       Iterations');
    print('-' * 60);

    for (final result in results) {
      final lang = result.langId.padRight(8);
      final status = '${result.statusEmoji} ${result.statusText}'.padRight(18);
      final words = result.totalWords > 0
          ? '${result.placedWords}/${result.totalWords}'.padRight(8)
          : '-'.padRight(8);
      final time = result.duration.inMilliseconds > 0
          ? '${(result.duration.inMilliseconds / 1000).toStringAsFixed(2)}s'
                .padRight(10)
          : '-'.padRight(10);
      final iters = result.iterations > 0 ? result.iterations.toString() : '-';
      print('$lang  $status  $words  $time  $iters');
    }

    // Print lists of non-optimal results for easy reference
    if (timeout > 0) {
      print('');
      print(
        'Timeout: ${byStatus[SolveStatus.timeout]!.map((r) => r.langId).join(', ')}',
      );
    }
    if (solved > 0) {
      print('');
      print(
        'Not optimal: ${byStatus[SolveStatus.solved]!.map((r) => r.langId).join(', ')}',
      );
    }
    if (failed > 0) {
      print('');
      print(
        'Failed: ${byStatus[SolveStatus.failed]!.map((r) => r.langId).join(', ')}',
      );
    }
    if (error > 0) {
      print('');
      print(
        'Errors: ${byStatus[SolveStatus.error]!.map((r) => r.langId).join(', ')}',
      );
    }
  }

  LanguageSolveResult _generateAndPrintGrid(Config config) {
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
        return _generateWithBacktracking(config);
      }

      if (config.algorithm == 'trie') {
        return _generateWithTrie(config);
      }

      // Use GreedyGridBuilder
      return _generateWithGreedy(config);
    } catch (e) {
      print('Error generating grid: $e');
      return LanguageSolveResult(
        langId: config.language.id,
        status: SolveStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Output the grid and optionally update the language file.
  void _outputResult(
    Config config,
    GridBuildResult result,
    String algorithmName,
    int seed,
    Duration duration,
  ) {
    // Print colored grid for visualization
    if (result.wordPlacements.isNotEmpty) {
      printColoredGrid(
        result.grid,
        result.wordPlacements,
        header: '\nColored grid (words highlighted):',
      );
    }

    if (result.stopReason != StopReason.completed) {
      return;
    }

    // Create metadata for generated section
    final metadata = GridGenerationMetadata(
      algorithm: algorithmName,
      seed: seed,
      timestamp: DateTime.now(),
      iterationCount: result.iterationCount,
      duration: duration,
    );

    if (config.update) {
      // Update the language file
      print('\nUpdating language file...');
      final success = updateLanguageFile(
        config.language.id,
        result.grid,
        metadata,
        result.wordPlacements,
      );
      if (success) {
        print('✓ Language file updated successfully.');
      } else {
        print('✗ Failed to update language file.');
      }
    } else {
      // Just print the grid code
      print('\n// Copy the following to your language file:');
      print(
        generateGridCode(
          config.language,
          result.grid,
          metadata,
          wordPlacements: result.wordPlacements,
        ),
      );
    }
  }

  LanguageSolveResult _generateWithGreedy(Config config) {
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
      return LanguageSolveResult(
        langId: config.language.id,
        status: SolveStatus.failed,
        placedWords: result.placedWords,
        totalWords: result.totalWords,
      );
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

    // Output the result
    _outputResult(config, result, 'Greedy', finalSeed, Duration.zero);

    return LanguageSolveResult(
      langId: config.language.id,
      status: result.isOptimal ? SolveStatus.optimal : SolveStatus.solved,
      duration: Duration.zero,
      iterations: result.iterationCount,
      placedWords: result.placedWords,
      totalWords: result.totalWords,
    );
  }

  LanguageSolveResult _generateWithTrie(Config config) {
    final int finalSeed = config.seed ?? 0;
    final int targetHeight = config.targetHeight > 0 ? config.targetHeight : 10;
    final int maxSearchTimeSeconds = config.timeout;

    print('Trie-based Grid Builder (experimental)');
    print('Timeout: ${maxSearchTimeSeconds}s');
    print('');

    final deadline = DateTime.now().add(
      Duration(seconds: maxSearchTimeSeconds),
    );

    final builder = TrieGridBuilder(
      width: config.gridWidth,
      height: targetHeight,
      language: config.language,
      seed: finalSeed,
      onProgress: (progress) {
        final elapsed = DateTime.now().difference(progress.startTime);
        final elapsedSecs = elapsed.inMilliseconds / 1000.0;
        final rate = elapsedSecs > 0
            ? progress.iterationCount / elapsedSecs
            : 0;
        final rateStr = rate.toStringAsFixed(0);
        final phraseStr = progress.totalPhrases > 0
            ? '${progress.phrasesCompleted}/${progress.totalPhrases} phrases (Best: ${progress.bestPhrases})'
            : '${progress.uniqueCurrentWords}/${progress.totalWords} words';
        printColoredGrid(
          WordGrid(
            width: progress.width,
            cells: progress.cells.map((c) => c ?? '·').toList(),
          ),
          progress.wordPlacements,
          header:
              '\n--- Search: $phraseStr | ${progress.iterationCount} iterations ($rateStr/s) ---',
        );

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
      print('\nFailed to generate grid with trie algorithm.');
      final isTimeout =
          result.stopReason == StopReason.timeout ||
          result.stopReason == StopReason.userStopped;
      return LanguageSolveResult(
        langId: config.language.id,
        status: isTimeout ? SolveStatus.timeout : SolveStatus.failed,
        duration: duration,
        iterations: result.iterationCount,
        placedWords: result.placedWords,
        totalWords: result.totalWords,
      );
    }

    // Determine status based on result
    final isTimeout =
        result.stopReason == StopReason.timeout ||
        result.stopReason == StopReason.userStopped;
    SolveStatus status;
    if (result.isOptimal) {
      status = SolveStatus.optimal;
    } else if (isTimeout) {
      status = SolveStatus.timeout;
    } else {
      status = SolveStatus.solved;
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

    // Output the result
    _outputResult(config, result, 'Trie', finalSeed, duration);

    return LanguageSolveResult(
      langId: config.language.id,
      status: status,
      duration: duration,
      iterations: result.iterationCount,
      placedWords: result.placedWords,
      totalWords: result.totalWords,
    );
  }

  LanguageSolveResult _generateWithBacktracking(Config config) {
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
        final phraseStr = progress.totalPhrases > 0
            ? '${progress.phrasesCompleted}/${progress.totalPhrases} phrases (Best: ${progress.bestPhrases})'
            : '${progress.uniqueCurrentWords}/${progress.totalWords} words';
        printColoredGrid(
          WordGrid(
            width: progress.width,
            cells: progress.cells.map((c) => c ?? '·').toList(),
          ),
          progress.wordPlacements,
          header:
              '\n--- Search: $phraseStr | ${progress.iterationCount} iterations ($rateStr/s) ---',
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
      final isTimeout =
          result.stopReason == StopReason.timeout ||
          result.stopReason == StopReason.userStopped;
      return LanguageSolveResult(
        langId: config.language.id,
        status: isTimeout ? SolveStatus.timeout : SolveStatus.failed,
        duration: duration,
        iterations: result.iterationCount,
        placedWords: result.placedWords,
        totalWords: result.totalWords,
      );
    }

    // Determine status based on result
    final isTimeout =
        result.stopReason == StopReason.timeout ||
        result.stopReason == StopReason.userStopped;
    SolveStatus status;
    if (result.isOptimal) {
      status = SolveStatus.optimal;
    } else if (isTimeout) {
      status = SolveStatus.timeout;
    } else {
      status = SolveStatus.solved;
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

    // Output the result
    _outputResult(config, result, 'Backtracking', finalSeed, duration);

    return LanguageSolveResult(
      langId: config.language.id,
      status: status,
      duration: duration,
      iterations: result.iterationCount,
      placedWords: result.placedWords,
      totalWords: result.totalWords,
    );
  }
}
