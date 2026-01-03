// ignore_for_file: avoid_print
import 'package:wordclock/generator/dependency_graph.dart';
import 'package:wordclock/generator/mermaid_exporter.dart';
import 'package:wordclock/generator/dot_exporter.dart';
import 'package:wordclock/languages/all.dart';

void main(List<String> args) {
  String langId = 'en';
  String format = 'mermaid';

  for (final arg in args) {
    if (arg.startsWith('--language=')) {
      langId = arg.substring(11).toLowerCase();
    } else if (arg == '--dot') {
      format = 'dot';
    } else if (arg == '--mermaid') {
      format = 'mermaid';
    }
  }

  final language = WordClockLanguages.byId[langId];
  if (language == null) {
    print('Unknown language: $langId');
    return;
  }

  final graph = DependencyGraphBuilder.build(language: language);

  if (format == 'mermaid') {
    print(MermaidExporter.export(graph));
  } else {
    print(DotExporter.export(graph));
  }
}
