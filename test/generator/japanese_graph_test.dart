import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/dependency_graph.dart';
import 'package:wordclock/languages/japanese.dart';

void main() {
  test('Japanese language graph size and reuse', () {
    final graph = DependencyGraphBuilder.build(language: japaneseLanguage);

    // Total nodes should be reasonable.
    // With spaces, reuse is much better (approx 175 nodes vs 3300+ without spaces).
    expect(graph.length, lessThan(200));
  });
}
