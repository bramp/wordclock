// ignore_for_file: avoid_print
import 'package:args/command_runner.dart';
import 'commands/solve_command.dart';
import 'commands/view_command.dart';
import 'commands/graph_command.dart';
import 'commands/check_command.dart';
import 'commands/debug_command.dart';

void main(List<String> args) async {
  final runner =
      CommandRunner<void>(
          'grid_builder',
          'Word Clock Grid Builder & Validation Tool',
        )
        ..addCommand(SolveCommand())
        ..addCommand(ViewCommand())
        ..addCommand(GraphCommand())
        ..addCommand(CheckCommand())
        ..addCommand(DebugCommand());

  try {
    await runner.run(args);
  } catch (e) {
    if (e is UsageException) {
      print(e);
      // print(runner.usage); // UsageException prints usage automatically?
    } else {
      print('Error: $e');
      // For debugging unhandled exceptions
      // print(StackTrace.current);
    }
  }
}
