import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/logic/timecheck_time_to_words.dart';

void main() {
  Map<String, Map<String, String>> expectedOutputs = {};
  Map<String, dynamic> timeCheckData = {};

  setUpAll(() async {
    // 1. Run the extraction script (using TimeCheck source)
    // We assume the test is run from the project root
    final process = await Process.run('node', [
      'bin/extract_timecheck_times.js',
    ]);

    if (process.exitCode != 0) {
      fail('Failed to run bin/extract_timecheck_times.js: ${process.stderr}');
    }

    // 2. Parse the output
    final output = process.stdout as String;
    String currentLanguage = '';

    // Output format:
    // ### Language: CODE
    // HH:MM -> WORDS...

    final lines = LineSplitter.split(output);
    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      if (line.startsWith('### Language: ')) {
        currentLanguage = line.substring('### Language: '.length).trim();
        expectedOutputs[currentLanguage] = {};
      } else if (line.contains('->')) {
        final parts = line.split('->');
        if (parts.length == 2 && currentLanguage.isNotEmpty) {
          final timeStr = parts[0].trim();
          final words = parts[1].trim();
          expectedOutputs[currentLanguage]![timeStr] = words;
        }
      }
    }

    // 3. Load timecheck_languages.json
    final jsonFile = File('assets/timecheck_languages.json');
    if (!jsonFile.existsSync()) {
      fail('assets/timecheck_languages.json not found');
    }
    timeCheckData = jsonDecode(jsonFile.readAsStringSync());
  });

  group('TimeCheckTimeToWords vs Original JS Output', () {
    test('Verify all languages match original JS logic', () {
      if (expectedOutputs.isEmpty) {
        fail('No expected outputs were parsed from the node script.');
      }

      final List<String> failures = [];
      final List<String> passed = [];

      // Iterate over each language found in the extraction output
      expectedOutputs.forEach((langCode, timeMap) {
        if (!timeCheckData.containsKey(langCode)) {
          failures.add('$langCode: Missing in JSON data');
          return;
        }

        final data = TimeCheckLanguageData.fromJson(timeCheckData[langCode]);
        final converter = TimeCheckTimeToWords(data);

        bool langFailed = false;

        for (final entry in timeMap.entries) {
          final timeStr = entry.key;
          final expectedWords = entry.value;

          final parts = timeStr.split(':');
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          final time = DateTime(2024, 1, 1, hour, minute);

          final actualWords = converter.convert(time);

          if (actualWords != expectedWords) {
            failures.add(
              '$langCode at $timeStr:\n  Expected: $expectedWords\n  Actual:   $actualWords',
            );
            langFailed = true;
            break; // Stop after first failure per language to avoid spam
          }
        }

        if (!langFailed) {
          passed.add(langCode);
        }
      });

      // ignore: avoid_print
      print('Passed languages: ${passed.join(', ')}');

      if (failures.isNotEmpty) {
        fail('Failed languages:\n${failures.join('\n\n')}');
      }
    });
  });
}
