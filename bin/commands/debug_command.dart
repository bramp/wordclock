// ignore_for_file: avoid_print
import 'package:args/command_runner.dart';
import 'package:wordclock/generator/backtracking/graph/word_node.dart';
import 'package:wordclock/generator/backtracking/grid_builder.dart';
import '../utils/config.dart';
import '../utils/utils.dart';

class DebugCommand extends Command<void> {
  @override
  final String name = 'debug';
  @override
  final String description = 'Run backtracking debugger on timeCheckGrid.';

  DebugCommand() {
    argParser
      ..addOption(
        'lang',
        abbr: 'l',
        mandatory: true,
        help: 'Language ID to use.',
      )
      ..addOption('width', abbr: 'w', defaultsTo: '11', help: 'Grid width.')
      ..addOption('height', defaultsTo: '10', help: 'Grid height.')
      ..addOption('timeout', defaultsTo: '60')
      ..addOption('seed', defaultsTo: '0');
  }

  @override
  void run() {
    final lang = getLanguage(argResults!);
    final config = Config(
      gridWidth: int.parse(argResults!['width']),
      targetHeight: int.parse(argResults!['height']),
      language: lang,
      seed: int.tryParse(argResults!['seed']),
      timeout: int.parse(argResults!['timeout']),
      algorithm: 'backtracking',
      // Dummies
      useRanks: false,
    );
    _debugBacktrackingFailure(config);
  }

  void _debugBacktrackingFailure(Config config) {
    final lang = config.language;
    final grid = lang.referenceGridRef?.grid;

    if (grid == null) {
      print('Error: No timeCheckGrid available for ${lang.id}');
      return;
    }

    print('Debugging ${lang.id} using timeCheckGrid...');

    // 1. Reconstruct the TRUE graph from the grid (handling multiple instances correctly)
    final result = reconstructGraphFromGrid(grid, lang);
    final wordGraph = result.graph;
    final placements = result.placements; // Sorted by offset

    print(
      '\nReconstructed ${wordGraph.nodes.length} unique words from timeCheckGrid.',
    );

    // Extract the nodes in order of their appearance in the grid
    final targets = <WordNode>[];
    for (final p in placements) {
      // Parse p.word to find the node.
      final match = RegExp(r'^(.*?) \(#(\d+)\)$').firstMatch(p.word);
      if (match != null) {
        final word = match.group(1)!;
        final instance = int.parse(match.group(2)!);
        final nodes = wordGraph.nodes[word];
        if (nodes != null && instance < nodes.length) {
          targets.add(nodes[instance]);
        }
      } else {
        // Fallback if no instance suffix (shouldn't happen with our new code)
        final nodes = wordGraph.nodes[p.word];
        if (nodes != null && nodes.isNotEmpty) targets.add(nodes[0]);
      }
    }

    if (targets.isEmpty) {
      print('Error: Could not extract any placements from timeCheckGrid.');
      return;
    }

    // 2. Run Debugger
    final builder = BacktrackingGridBuilder(
      width: config.gridWidth,
      height: config.targetHeight > 0 ? config.targetHeight : grid.height,
      language: lang,
      seed: config.seed ?? 0,
      prebuiltGraph:
          wordGraph, // CRITICAL: Use the graph that understands the instances!
    );

    builder.debugValidatePlacements(targets);
  }
}
