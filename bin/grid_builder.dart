import 'package:wordclock/generator/dependency_graph.dart';
import 'package:wordclock/generator/dot_exporter.dart';
import 'package:wordclock/generator/grid_generator.dart';
import 'package:wordclock/generator/mermaid_exporter.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/languages/all.dart';

// ignore_for_file: avoid_print

void main(List<String> args) {
  int gridWidth = 11; // Default
  int? seed;
  WordClockLanguage language = WordClockLanguages.byId['en']!;
  bool outputDot = false;
  bool outputMermaid = false;

  for (final arg in args) {
    if (arg.startsWith('--seed=')) {
      seed = int.tryParse(arg.substring(7));
    }
    if (arg.startsWith('--width=')) {
      final w = int.tryParse(arg.substring(8));
      if (w != null) gridWidth = w;
    }
    if (arg.startsWith('--language=')) {
      final langId = arg.substring(11).toLowerCase();
      if (WordClockLanguages.byId.containsKey(langId)) {
        language = WordClockLanguages.byId[langId]!;
      } else {
        print('Error: Unknown language ID "$langId".');
        print('Available IDs: ${WordClockLanguages.byId.keys.join(', ')}');
        return;
      }
    }
    if (arg == '--dot') {
      outputDot = true;
    }
    if (arg == '--mermaid') {
      outputMermaid = true;
    }
  }

  if (outputDot || outputMermaid) {
    final graph = DependencyGraphBuilder.build(language: language);
    if (outputDot) {
      print(DotExporter.export(graph));
    } else if (outputMermaid) {
      print(MermaidExporter.export(graph));
    }
    return;
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
