// ignore_for_file: avoid_print
import 'package:args/command_runner.dart';
import 'package:wordclock/model/word_grid.dart';
import '../utils/config.dart';
import '../utils/utils.dart';

class ViewCommand extends Command<void> {
  @override
  final String name = 'view';
  @override
  final String description = 'View an existing grid (color-coded).';

  ViewCommand() {
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
        defaultsTo: 'default',
        allowed: ['default', 'timecheck'],
        help: 'Which grid to view.',
      )
      ..addOption(
        'width',
        abbr: 'w',
        defaultsTo: '11',
        help: 'Grid width for visualization.',
      );
  }

  @override
  void run() {
    final lang = getLanguage(argResults!);
    final gridName = argResults!['grid'];
    final width = int.parse(argResults!['width']);

    final config = Config(
      gridWidth: width,
      language: lang,
      // Dummies
      targetHeight: 0,
      algorithm: '',
      timeout: 0,
      useRanks: false,
    );

    if (gridName == 'timecheck') {
      _printExistingGrid(config, lang.timeCheckGridRef?.grid, 'timeCheckGrid');
    } else {
      _printExistingGrid(config, lang.defaultGridRef?.grid, 'defaultGrid');
    }
  }

  void _printExistingGrid(Config config, WordGrid? grid, String name) {
    final lang = config.language;
    if (grid == null) {
      print('Error: Language ${lang.id} does not have a $name.');
      return;
    }

    // Reconstruct graph from grid to show true instance data
    final result = reconstructGraphFromGrid(grid, lang);

    printColoredGrid(
      grid,
      result.placements,
      header: 'Color-coded $name for ${lang.id} (${lang.englishName}):',
    );
  }
}
