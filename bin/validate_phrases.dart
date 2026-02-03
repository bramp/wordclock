// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:wordclock/languages/all.dart';
import 'package:wordclock/generator/utils/word_clock_utils.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag(
      'dry-run',
      negatable: true,
      defaultsTo: true,
      help: 'Print the prompt instead of sending it to OpenAI.',
    );

  final args = parser.parse(arguments);
  final dryRun = args['dry-run'] as bool;

  final apiKey = Platform.environment['OPENAI_API_KEY'];
  if (!dryRun && (apiKey == null || apiKey.isEmpty)) {
    print('Error: OPENAI_API_KEY environment variable is not set.');
    exit(1);
  }

  final resultsDir = Directory('phrases_validation');
  if (!resultsDir.existsSync()) {
    resultsDir.createSync();
  }

  final languages = WordClockLanguages.all;
  print(
    'Validating ${languages.length} languages via OpenAI (generating phrases on the fly)...',
  );

  final client = HttpClient();

  for (final lang in languages) {
    final langId = lang.id;
    final resultFile = File('${resultsDir.path}/$langId.md');

    if (resultFile.existsSync()) {
      print(
        '  - Skipping ${lang.englishName} (${lang.id}) (already validated)',
      );
      continue;
    }

    print('  - Validating ${lang.englishName} (${lang.id})...');

    // Generate phrases on the fly
    final buffer = StringBuffer();
    buffer.writeln('Language: ${lang.englishName} (${lang.id})');
    buffer.writeln('----------------------------------------');

    final gridObj = lang.defaultGridRef;
    String gridDisplay = 'No grid available for this language.';
    if (gridObj != null) {
      final wordGrid = gridObj.grid;
      final gridBuffer = StringBuffer();
      for (int y = 0; y < wordGrid.height; y++) {
        final row = <String>[];
        for (int x = 0; x < wordGrid.width; x++) {
          row.add(wordGrid.cells[y * wordGrid.width + x]);
        }
        gridBuffer.writeln(row.join(' '));
      }
      gridDisplay = gridBuffer.toString().trim();
    }

    final seen = <String>{};
    String? samplePhrase;
    String? sampleTimeStr;

    WordClockUtils.forEachTime(lang, (time, phrase) {
      if (seen.contains(phrase)) return;
      seen.add(phrase);

      final hh = time.hour.toString().padLeft(2, '0');
      final mm = time.minute.toString().padLeft(2, '0');
      buffer.writeln('$hh:$mm: $phrase');

      if (samplePhrase == null) {
        samplePhrase = phrase;
        sampleTimeStr = '$hh:$mm';
      }
    });

    final content = buffer.toString();

    final systemPrompt =
        '''You are a linguistic expert and native speaker consultant for a Word Clock project.
A Word Clock displays time in 5-minute increments by lighting up specific words on a physical or digital character grid.

### The Word Grid Constraint:
Unlike standard text, these words must fit onto a compact grid (e.g., ${gridObj?.grid.width}x${gridObj?.grid.height} characters). To make the grid as small as possible, the software tries to "overlap" words or share character sequences.

**Example of Overlapping:**
In Italian, the single sequence `VENTICINQUE` (twenty-five) can be reused to show "VENTI" (20), "CINQUE" (5), or "VENTICINQUE" (25).

**The Grid for ${lang.englishName}:**
```
$gridDisplay
```
In this grid, to show "$sampleTimeStr" ($samplePhrase), the clock lights up the words "$samplePhrase" wherever they appear in the grid above.

### Your Task:
1. **Correctness & Naturalness**:
   - **Grammar**: Evaluate all phrases for grammatical correctness and naturalness.
   - **Reading Order**: The highlighted words must appear in the correct reading order (typically top-to-bottom, left-to-right). A phrase is poor if it requires jumping around the grid inconsistently.
   - **Flow**: When the words are highlighted in sequence on the grid, they must form a natural and common way for a native speaker to state the time.

2. **Optimization**: If a slightly different (but still standard and correct) phrasing uses fewer unique words or shares more letters with other times (compactness), it is better for the grid.

3. **Provide a score (0-100)**:
   - 100: Perfect. Phrases are natural, in order, and optimized for a grid.
   - 80-99: Minor issues. Understandable but slightly awkward or has tiny typos.
   - 50-79: Significant issues. Incorrect grammar, bad reading order, or confusing.
   - 0-49: Fatal errors. Literal translations, nonsense, or impossible to read in order.

### Output Format:
SCORE: [score]
SUMMARY: [Short summary of the quality]
ISSUES:
- [Timestamp]: [Error description]
SUGGESTIONS:
- [Timestamp]: [Better phrasing for correctness or compactness]

All of your feedback and responses must be in English.''';

    final userPrompt =
        'Check these phrases for ${lang.englishName} (ID: $langId):\n\n$content';

    if (dryRun) {
      print('--- DRY RUN: PROMPT FOR ${lang.englishName} ---');
      print('SYSTEM:\n$systemPrompt');
      print('USER:\n$userPrompt');
      print('--------------------------------------------\n');
      continue;
    }

    try {
      final request = await client.postUrl(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
      );
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $apiKey');

      final body = jsonEncode({
        'model': 'gpt-5-mini',
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
      });

      final bodyData = utf8.encode(body);
      request.headers.set('Content-Length', bodyData.length.toString());
      request.add(bodyData);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 429) {
        print(
          '    Rate limited for ${lang.englishName} (${lang.id}). Waiting 10 seconds...',
        );
        await Future.delayed(Duration(seconds: 10));
        continue;
      }

      if (response.statusCode != 200) {
        print(
          '    Failed for ${lang.englishName} (${lang.id}): ${jsonResponse['error']?['message'] ?? responseBody}',
        );
        continue;
      }

      final result = jsonResponse['choices'][0]['message']['content'];
      await resultFile.writeAsString(result);

      final scoreMatch = RegExp(r'SCORE:\s*(\d+)').firstMatch(result);
      final score = scoreMatch?.group(1) ?? '???';

      print('    ${lang.englishName} (${lang.id}) validated. Score: $score');

      await Future.delayed(Duration(milliseconds: 500));
    } catch (e) {
      print('    Error validating ${lang.englishName} (${lang.id}): $e');
    }
  }

  client.close();
  print(
    '\nValidation complete! Results are in the phrases_validation/ directory.',
  );
}
