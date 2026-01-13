// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:wordclock/languages/all.dart';
import 'package:wordclock/generator/utils/word_clock_utils.dart';

void main() async {
  final apiKey = Platform.environment['OPENAI_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
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

    final seen = <String>{};
    WordClockUtils.forEachTime(lang, (time, phrase) {
      if (seen.contains(phrase)) return;
      seen.add(phrase);

      final hh = time.hour.toString().padLeft(2, '0');
      final mm = time.minute.toString().padLeft(2, '0');
      buffer.writeln('$hh:$mm: $phrase');
    });

    final content = buffer.toString();

    try {
      final request = await client.postUrl(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
      );
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $apiKey');

      final body = jsonEncode({
        'model': 'gpt-5-mini',
        'messages': [
          {
            'role': 'system',
            'content':
                '''You are a linguistic expert and native speaker consultant for a Word Clock project.
A Word Clock displays time in 5-minute increments by lighting up specific words on a physical or digital character grid.

### The Word Grid Constraint:
Unlike standard text, these words must fit onto a compact grid (e.g., 11x10 characters). To make the grid as small as possible, the software tries to "overlap" words or share character sequences (e.g., sharing the "SIX" in "SIX" and "SIXTY").

### Your Task:
1. **Correctness vs. Compactness**: Evaluate all phrases for grammatical correctness and naturalness.
   - **Critical**: Phrases must be accurate and understandable to a native speaker.
   - **Optimization**: If a slightly different (but still standard and correct) phrasing uses fewer unique words or shares more letters with other times, it is better for the grid.

2. **Provide a score (0-100)**:
   - 100: Perfect. Phrases are natural and optimized for a grid.
   - 80-99: Minor issues. Understandable but slightly awkward or has tiny typos.
   - 50-79: Significant issues. Incorrect grammar, wrong cases, or confusing.
   - 0-49: Fatal errors. Literal translations or nonsense.

### Output Format:
SCORE: [score]
SUMMARY: [Short summary of the quality]
ISSUES:
- [Timestamp]: [Error description]
SUGGESTIONS:
- [Timestamp]: [Better phrasing for correctness or compactness]

All of your feedback and responses must be in English.''',
          },
          {
            'role': 'user',
            'content':
                'Check these phrases for ${lang.englishName} (ID: $langId):\n\n$content',
          },
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
