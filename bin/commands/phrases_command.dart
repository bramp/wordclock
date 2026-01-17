// ignore_for_file: avoid_print
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:wordclock/generator/backtracking/graph/graph_builder.dart';
import 'package:wordclock/generator/utils/word_clock_utils.dart';
import 'package:wordclock/languages/all.dart';
import 'package:wordclock/languages/language.dart';
import '../utils/utils.dart';

class PhrasesCommand extends Command<void> {
  @override
  final String name = 'phrases';
  @override
  final String description =
      'Print out the phrase for every time in a language.';

  PhrasesCommand() {
    argParser
      ..addOption(
        'lang',
        abbr: 'l',
        help: 'Language ID to use (required unless --all is specified).',
      )
      ..addFlag(
        'unique',
        abbr: 'u',
        defaultsTo: false,
        help: 'Only print unique phrases.',
      )
      ..addFlag(
        'debug',
        abbr: 'd',
        defaultsTo: true,
        help: 'Print debug information to stderr.',
      )
      ..addFlag('all', help: 'Print for all languages.');
  }

  @override
  void run() {
    final showAll = argResults!['all'] as bool;
    final unique = argResults!['unique'] as bool;
    final debug = argResults!['debug'] as bool;

    if (showAll) {
      for (final lang in WordClockLanguages.all) {
        try {
          _printForLanguage(lang, unique: unique, debug: debug);
        } catch (e) {
          print('Error processing ${lang.id}: $e');
        }
        print('\n${'=' * 40}\n');
      }
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
    _printForLanguage(lang, unique: unique, debug: debug);
  }

  void _printForLanguage(
    WordClockLanguage lang, {
    required bool unique,
    required bool debug,
  }) {
    final seen = <String>{};

    print('Phrases for ${lang.id} (${lang.englishName}):');
    WordClockUtils.forEachTime(lang, (time, phrase) {
      if (unique && seen.contains(phrase)) return;
      seen.add(phrase);

      final hh = time.hour.toString().padLeft(2, '0');
      final mm = time.minute.toString().padLeft(2, '0');
      print('$hh:$mm: $phrase');
    });

    if (debug) {
      final uniqueWords = WordClockUtils.getAllWords(lang);
      final phrases = WordClockUtils.getAllPhrases(lang).toList();
      final graph = WordDependencyGraphBuilder.buildBest(language: lang);
      final ranks = graph.computeRanks();
      final maxRank = ranks.values.isEmpty
          ? 0
          : ranks.values.reduce((a, b) => a > b ? a : b);

      // Unique word occurrences required by language
      final maxOccurrences = WordClockUtils.calculateMaxWordOccurrences(
        phrases,
        lang,
      );

      int optimalNodeCount = 0;
      maxOccurrences.forEach((word, count) => optimalNodeCount += count);

      final optimalCellCount = WordClockUtils.estimateMinimumCells(
        maxOccurrences,
      );

      // Actual occurrences in the generated graph
      final actualOccurrences = <String, int>{};
      for (final node in graph.allNodes) {
        actualOccurrences[node.word] = (actualOccurrences[node.word] ?? 0) + 1;
      }
      final actualCellCount = WordClockUtils.estimateMinimumCells(
        actualOccurrences,
      );

      stderr.writeln('\nDebug Information (stderr):');
      stderr.writeln('  Language ID:      ${lang.id}');
      stderr.writeln('  Unique Phrases:   ${phrases.length}');
      stderr.writeln('  Unique Words:     ${uniqueWords.length}');
      stderr.writeln(
        '  Graph Nodes:      ${graph.allNodes.length} (optimal: $optimalNodeCount)',
      );
      stderr.writeln(
        '  Grid Cells:       $actualCellCount (estimated min: $optimalCellCount)',
      );
      stderr.writeln(
        '  Graph Edges:      ${graph.edges.values.expand((e) => e).length}',
      );
      stderr.writeln('  Max Rank depth:   $maxRank');
    }
  }
}
