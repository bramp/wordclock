import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/dependency_graph.dart';
import 'package:wordclock/languages/japanese.dart';

void main() {
  test('Japanese language graph size and reuse', () {
    final language = JapaneseLanguage();
    final graph = DependencyGraphBuilder.build(language: language);

    final goNodes = graph.keys.where((n) => n.char == "午").toList();

    // With word-level reuse, '午' should be 2 (one for 午前, one for 午後)
    expect(goNodes.length, 2);

    // Total nodes should be reasonable.
    expect(graph.length, lessThan(600));
  });
}
