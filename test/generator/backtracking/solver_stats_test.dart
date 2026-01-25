import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/languages/all.dart';
import 'package:wordclock/generator/backtracking/graph/graph_builder.dart';
import 'package:wordclock/generator/backtracking/trie_grid_builder.dart';

void main() {
  group('Solver Stats Performance', () {
    for (final language in WordClockLanguages.all) {
      test('${language.id} (${language.englishName}) stats calculation < 1s', () {
        final stopwatch = Stopwatch()..start();

        // 1. Check DAG stats (Backtracking)
        final graph = WordDependencyGraphBuilder.build(language: language);
        final dagSorts = graph.countTopologicalSorts();
        expect(dagSorts, greaterThan(BigInt.zero));

        // 2. Check Trie stats (Experimental Trie Solver)
        final (trieSorts, _) = TrieGridBuilder.calculateStats(language);
        expect(trieSorts, greaterThan(BigInt.zero));

        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(1000),
          reason:
              'Stats for ${language.id} took ${stopwatch.elapsedMilliseconds}ms',
        );
      });
    }
  });
}
