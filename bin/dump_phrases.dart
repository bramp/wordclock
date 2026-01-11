// ignore_for_file: avoid_print
import 'dart:io';
import 'package:wordclock/languages/all.dart';
import 'package:wordclock/generator/utils/word_clock_utils.dart';

void main() async {
  final outputDir = Directory('phrases_dump');
  if (!outputDir.existsSync()) {
    outputDir.createSync();
  }

  print('Dumping phrases for all languages to ${outputDir.path}...');

  for (final lang in WordClockLanguages.all) {
    final file = File('${outputDir.path}/${lang.id}.txt');
    final sink = file.openWrite();

    sink.writeln('Language: ${lang.englishName} (${lang.id})');
    sink.writeln('----------------------------------------');

    final seen = <String>{};
    WordClockUtils.forEachTime(lang, (time, phrase) {
      if (seen.contains(phrase)) return;
      seen.add(phrase);

      final hh = time.hour.toString().padLeft(2, '0');
      final mm = time.minute.toString().padLeft(2, '0');
      sink.writeln('$hh:$mm: $phrase');
    });

    await sink.close();
    print('  - Wrote ${lang.id}.txt');
  }

  print('Done!');
}
