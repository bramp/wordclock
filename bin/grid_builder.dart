import 'package:wordclock/generator/grid_generator.dart';
import 'package:wordclock/languages/english.dart';

// ignore_for_file: avoid_print

void main(List<String> args) {
  int gridWidth = 11; // Default
  int? seed;
  final language = EnglishLanguage();

  for (final arg in args) {
    if (arg.startsWith('--seed=')) {
      seed = int.tryParse(arg.substring(7));
    }
    if (arg.startsWith('--width=')) {
      final w = int.tryParse(arg.substring(8));
      if (w != null) gridWidth = w;
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

    print('\n/// AUTOMATICALLY GENERATED PREVIEW');
    print('/// Seed: ${seed ?? "Deterministic (0)"}');
    print('static final english${gridWidth}x$height = WordGrid(');
    print('  width: $gridWidth,');
    print('  letters:');
    for (int i = 0; i < height; i++) {
      print(
        "    '${gridString.substring(i * gridWidth, (i + 1) * gridWidth)}'",
      );
    }
    print('    ,');
    print('    timeConverter: EnglishTimeToWords(),');
    print(');');
  } catch (e) {
    print('Error generating grid: $e');
  }
}
