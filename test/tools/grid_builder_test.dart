// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Grid Builder Smoke Test', () async {
    // Use English (EN) which is very fast to solve.
    final result = await Process.run('dart', [
      'bin/grid_builder.dart',
      'solve',
      '--lang',
      'EN',
      '--width',
      '11',
    ]);

    if (result.exitCode != 0) {
      print('STDERR: ${result.stderr}');
      print('STDOUT: ${result.stdout}');
    }

    expect(result.exitCode, 0, reason: "Grid Builder failed to run");
    expect(
      result.stdout,
      contains('defaultGrid: WordGrid.fromLetters('),
      reason: "Output missing GridDefinition",
    );
  });
}
