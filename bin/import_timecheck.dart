// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:wordclock/logic/timecheck_time_to_words.dart';

/// This script parses the TimeCheck widget's JavaScript file
/// and generates a JSON file containing the grid data and the logic.
///
/// To use this script, run:
///
/// dart run bin/import_timecheck.dart
///
/// The output file will be saved to assets/timecheck_languages.json
///
void main() async {
  // Parsing the TimeCheck JS file using the helper script
  final dumpScript = File('bin/dump_timecheck_json.js');
  if (!await dumpScript.exists()) {
    print('Error: Could not find ${dumpScript.path}');
    return;
  }

  print('Running ${dumpScript.path}...');
  final process = await Process.start('node', [dumpScript.path]);
  final jsonStr = await process.stdout.transform(utf8.decoder).join();
  final stderr = await process.stderr.transform(utf8.decoder).join();

  if (stderr.isNotEmpty) {
    print('Node.js Error: $stderr');
    // If output is empty, fail. If stderr is just warnings, proceed?
    // dump script outputs error to stderr and exits 1.
  }

  if (await process.exitCode != 0) {
    print('Failed to dump JSON (Exit code ${await process.exitCode})');
    return;
  }

  if (jsonStr.trim().isEmpty) {
    print('Error: Empty output from dump script');
    return;
  }

  final Map<String, dynamic> matrix = jsonDecode(jsonStr);
  final Map<String, dynamic> timeCheckDataJson = {};

  matrix.forEach((key, value) {
    if (key == 'DOT') return; // Skip DOT view (if any)

    // Check for valid data
    if (value['a'] == null || value['r'] == null) {
      print('Skipping $key (Missing grid or rules)');
      return;
    }

    // Skip system languages if 's' is set (assuming s=true means system/special)
    if (value['s'] != null && value['s'] != false) {
      print('Skipping $key (Marked as System attributes)');
      return;
    }

    print('Processing $key...');

    final List<dynamic> gridRows = value['a'];
    final int width = gridRows[0].length;
    final String gridStr = gridRows.map((r) => (r as List).join('')).join('');
    // Use 'b' (limit) or 'G' (fallback found in CT) or default 35
    final int hourDisplayLimit = value['b'] ?? value['G'] ?? 35;
    final Map<String, dynamic> rules = value['r'] ?? {};

    // Helper to extract words with their coordinates
    List<TimeCheckWord> extractWords(List<dynamic> coords) {
      return coords.map<TimeCheckWord>((c) {
        final List<dynamic> coord = c as List;
        final int row = coord[0];
        final int col = coord[1];
        final int lengthParam = (coord.length > 2) ? (coord[2] ?? 0) : 0;
        // In Scriptable/TimeCheck logic, loop is i <= start + length. So span is length + 1.
        final int span = lengthParam + 1;

        final int endIdx = math.min(col + span, gridRows[row].length);

        final String text = gridRows[row].sublist(col, endIdx).join('');

        return TimeCheckWord(text: text, row: row, col: col, span: span);
      }).toList();
    }

    final data = TimeCheckLanguageData(
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

    // Fix for JP 3:30 bug (merged words)
    if (key == 'JP') {
      final cond3_30 = data.conditional[3]?[30];
      if (cond3_30 != null &&
          cond3_30.length == 1 &&
          cond3_30.first.text == '三時半です') {
        final original = cond3_30.first;
        // Update text to include space. Reference logic will not merge but just use text.
        final newWord = TimeCheckWord(
          text: '三時半 です',
          row: original.row,
          col: original.col,
          span: original.span,
        );
        data.conditional[3]![30] = [newWord];
        print('Patched JP 3:30 conditional text');
      }
    }

    timeCheckDataJson[key] = data.toJson();
  });

  final outputFile = File('assets/timecheck_languages.json');
  await outputFile.writeAsString(
    JsonEncoder.withIndent('  ').convert(timeCheckDataJson),
  );
  print('Successfully generated ${outputFile.path}');
}
