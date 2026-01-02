// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:wordclock/logic/scriptable_time_to_words.dart';

/// This script parses the Scriptable widget's JavaScript file
/// and generates a JSON file containing the grid data and the logic.
///
/// To use this script, run:
///
/// git clone https://github.com/bitKrakenCode/ScriptableWordClockWidget
/// dart run bin/import_scriptable.dart
///
/// The output file will be saved to assets/scriptable_languages.json
///
void main() async {
  final jsFile = File('ScriptableWordClockWidget/Word Clock Widget.js');
  if (!await jsFile.exists()) {
    print('Error: Could not find Scriptable JS file at ${jsFile.path}');
    return;
  }

  final content = await jsFile.readAsString();

  // Extract the full_matrix object from the JS file
  final startMarker = 'const full_matrix = {';
  final endMarker = 'if (language in full_matrix) {';

  int start = content.indexOf(startMarker);
  int end = content.lastIndexOf(endMarker);

  if (start == -1 || end == -1) {
    print('Error: Could not find full_matrix object in JS file');
    return;
  }

  // Extract the object literal string
  String matrixStr = content
      .substring(start + startMarker.length - 1, end)
      .trim();
  if (matrixStr.endsWith(';')) {
    matrixStr = matrixStr.substring(0, matrixStr.length - 1);
  }

  // Use Node.js to parse the JS object literal and convert it to JSON
  final tempFile = File('${Directory.systemTemp.path}/matrix_parser.js');
  await tempFile.writeAsString(
    'const matrix = $matrixStr; console.log(JSON.stringify(matrix));',
  );

  final process = await Process.start('node', [tempFile.path]);
  final jsonStr = await process.stdout.transform(utf8.decoder).join();
  final stderr = await process.stderr.transform(utf8.decoder).join();

  if (await tempFile.exists()) {
    await tempFile.delete();
  }

  if (stderr.isNotEmpty) {
    print('Node.js Error: $stderr');
    return;
  }

  final Map<String, dynamic> matrix = jsonDecode(jsonStr);
  final Map<String, dynamic> scriptableDataJson = {};

  matrix.forEach((key, value) {
    if (key == 'DOT') return; // Skip DOT view
    print('Processing $key...');

    final List<dynamic> gridRows = value['a'];
    final int width = gridRows[0].length;
    final String gridStr = gridRows.map((r) => (r as List).join('')).join('');
    final int hourDisplayLimit = value['b'] ?? 35;
    final Map<String, dynamic> rules = value['r'] ?? {};

    List<String> extractWords(List<dynamic> coords) {
      return coords.map<String>((c) {
        final List<dynamic> coord = c as List;
        final int row = coord[0];
        final int col = coord[1];
        final int length = (coord.length > 2) ? (coord[2] ?? 0) : 0;
        final int endIdx = math.min(col + length + 1, gridRows[row].length);
        return gridRows[row].sublist(col, endIdx).join('');
      }).toList();
    }

    final data = ScriptableLanguageData(
      grid: gridStr,
      width: width,
      hourDisplayLimit: hourDisplayLimit,
      intro: extractWords(rules['i'] ?? []),
      exact: (rules['e'] as Map<String, dynamic>? ?? {}).map(
        (h, coords) => MapEntry(int.parse(h), extractWords(coords)),
      ),
      delta: (rules['d'] as Map<String, dynamic>? ?? {}).map(
        (m, coords) => MapEntry(int.parse(m), extractWords(coords)),
      ),
      conditional: (rules['c'] as Map<String, dynamic>? ?? {}).map(
        (h, mins) => MapEntry(
          int.parse(h),
          (mins as Map<String, dynamic>).map(
            (m, coords) => MapEntry(int.parse(m), extractWords(coords)),
          ),
        ),
      ),
    );

    scriptableDataJson[key] = data.toJson();
  });

  final outputFile = File('assets/scriptable_languages.json');
  await outputFile.writeAsString(
    JsonEncoder.withIndent('  ').convert(scriptableDataJson),
  );
  print('Successfully generated ${outputFile.path}');
}
