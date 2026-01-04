// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Grid Builder Smoke Test', () async {
    final result = await Process.run('dart', [
      'bin/grid_builder.dart',
      '--width=11',
      '--seed=123',
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

  test('Grid Builder Cycle Detection Test', () async {
    // This test ensures the tool can handle the inherent cycles in TimeToWords
    // by dynamically allocating nodes, so it should NOT fail.
    final result = await Process.run('dart', [
      'bin/grid_builder.dart',
      '--seed=0',
    ]);
    expect(result.exitCode, 0);
  });
}
