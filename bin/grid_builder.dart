import 'dart:io';
import 'package:wordclock/generator/grid_generator.dart';
import 'package:wordclock/languages/english.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/languages/scriptable.dart';

// ignore_for_file: avoid_print

void main(List<String> args) {
  int gridWidth = 11; // Default
  int? seed;
  WordClockLanguage language = EnglishLanguage();

  for (final arg in args) {
    if (arg.startsWith('--seed=')) {
      seed = int.tryParse(arg.substring(7));
    }
    if (arg.startsWith('--width=')) {
      final w = int.tryParse(arg.substring(8));
      if (w != null) gridWidth = w;
    }
    if (arg.startsWith('--language=')) {
      final langCode = arg.substring(11);
      if (langCode != 'en') {
        // Try to load from scriptable dataset
        final jsonFile = File('assets/scriptable_languages.json');
        if (!jsonFile.existsSync()) {
          print('Error: assets/scriptable_languages.json not found.');
          return;
        }
        final languages = ScriptableLanguage.loadAll(
          jsonFile.readAsStringSync(),
        );
        if (!languages.containsKey(langCode)) {
          print('Error: Unknown language code "$langCode".');
          print('Available codes: ${languages.keys.join(', ')}');
          return;
        }
        language = languages[langCode]!;
      }
    }
    if (arg == '--dot') {
      print('DOT output not supported in this version via grid_builder.');
      return;
    }
  }

  try {
    final gridString = GridGenerator.generate(
      width: gridWidth,
      seed: seed,
      language: language,
    );
    final height = gridString.length ~/ gridWidth;
    final langName = language.displayName.toLowerCase().replaceAll(' ', '');

    print('\n/// AUTOMATICALLY GENERATED PREVIEW');
    print('/// Seed: ${seed ?? "Deterministic (0)"}');
    print('static final $langName${gridWidth}x$height = WordGrid(');
    print('  width: $gridWidth,');
    print('  letters:');
    for (int i = 0; i < height; i++) {
      print(
        "    '${gridString.substring(i * gridWidth, (i + 1) * gridWidth)}'",
      );
    }
    print('    ,');
    print(');');
  } catch (e) {
    print('Error generating grid: $e');
  }
}
