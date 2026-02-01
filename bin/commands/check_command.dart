// ignore_for_file: avoid_print
import 'package:args/command_runner.dart';
import 'package:wordclock/languages/all.dart';
import 'package:wordclock/generator/utils/grid_validator.dart';
import '../utils/config.dart';

class CheckCommand extends Command<void> {
  @override
  final String name = 'check';
  @override
  final String description = 'Validate grids for consistency.';

  CheckCommand() {
    // Optional lang. If not present, checks all.
    argParser
      ..addOption('lang', abbr: 'l', help: 'Specific language to check.')
      ..addOption('width', abbr: 'w', defaultsTo: '11', help: 'Grid width.')
      ..addOption('height', defaultsTo: '10', help: 'Grid height.');
  }

  @override
  void run() {
    final width = int.parse(argResults!['width']);
    final height = int.parse(argResults!['height']);

    // Config needed for runCheckAll
    final config = Config(
      gridWidth: width,
      targetHeight: height,
      // Dummies
      language: WordClockLanguages.all.first, // Dummy
      algorithm: '',
      timeout: 0,
      useRanks: false,
    );

    if (argResults!['lang'] != null) {
      // TODO: Filter logic would go here, currently runCheckAll runs all.
      // We can just print a warning or implement filter.
      print(
        'Note: Checking ALL languages (single language filtering not yet implemented).',
      );
    }

    _runCheckAll(config);
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
      final defaultGrid = lang.defaultGridRef?.grid;
      if (defaultGrid == null) {
        issues.add('Missing defaultGrid.');
      } else {
        final gridIssues = GridValidator.validate(
          defaultGrid,
          lang,
          expectedWidth: config.gridWidth,
          expectedHeight: cliHeight ?? defaultGrid.height,
          timeToWords: lang.defaultGridRef?.timeToWords,
        );
        for (final issue in gridIssues) {
          issues.add('DefaultGrid: $issue');
        }
      }

      // Check TimeCheck Grid
      final timeCheckGrid = lang.referenceGridRef?.grid;
      if (timeCheckGrid != null) {
        final gridIssues = GridValidator.validate(
          timeCheckGrid,
          lang,
          expectedWidth: config.gridWidth,
          expectedHeight: cliHeight ?? timeCheckGrid.height,
          timeToWords: lang.referenceGridRef?.timeToWords,
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
}
