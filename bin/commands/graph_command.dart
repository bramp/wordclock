// ignore_for_file: avoid_print
import 'package:args/command_runner.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/generator/backtracking/graph/graph_builder.dart';
import 'package:wordclock/generator/backtracking/dot_exporter.dart';
import '../utils/config.dart';
import '../utils/utils.dart';

class GraphCommand extends Command<void> {
  @override
  final String name = 'graph';
  @override
  final String description = 'Generate dependency graph in DOT format.';

  GraphCommand() {
    argParser
      ..addOption(
        'lang',
        abbr: 'l',
        mandatory: true,
        help: 'Language ID to use.',
      )
      ..addOption(
        'grid',
        abbr: 'g',
        defaultsTo: 'language',
        allowed: ['language', 'default', 'timecheck'],
        help: 'Source of the graph.',
      )
      ..addOption(
        'algorithm',
        abbr: 'a',
        defaultsTo: 'backtracking',
        allowed: ['backtracking'],
        help: 'Graph type (backtracking=word-level).',
      );
  }

  @override
  void run() {
    final lang = getLanguage(argResults!);
    print('// Language: ${lang.englishName} (${lang.id})');
    final algorithm = argResults!['algorithm'];
    final gridSource = argResults!['grid'];

    if (gridSource == 'language') {
      // Original logic: Build fresh from language definition
      final config = Config(
        language: lang,
        algorithm: algorithm,
        // Dummies
        gridWidth: 0,
        targetHeight: 0,
        timeout: 0,
        useRanks: false,
      );
      _exportGraph(config);
      return;
    }

    // Handle extracting graph from existing grids
    WordGrid? sourceGrid;
    if (gridSource == 'timecheck') {
      sourceGrid = lang.timeCheckGridRef?.grid;
    } else if (gridSource == 'default') {
      sourceGrid = lang.defaultGridRef?.grid;
    }

    if (sourceGrid == null) {
      print('Error: Language ${lang.id} does not have a $gridSource grid.');
      return;
    }

    final result = reconstructGraphFromGrid(sourceGrid, lang);
    print(WordGraphDotExporter.export(result.graph));
  }

  void _exportGraph(Config config) {
    final wordGraph = WordDependencyGraphBuilder.build(
      language: config.language,
    );
    print(WordGraphDotExporter.export(wordGraph));
  }
}
