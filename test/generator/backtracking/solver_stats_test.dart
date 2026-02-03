import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/languages/all.dart';
import 'package:wordclock/generator/backtracking/graph/graph_builder.dart';
import 'package:wordclock/generator/backtracking/graph/dependency_graph.dart';
import 'package:wordclock/generator/backtracking/trie_grid_builder.dart';

void main() {
  group('Solver Stats Performance', () {
    for (final language in WordClockLanguages.all) {
      test('${language.id} (${language.englishName}) stats calculation', () {
        final stopwatch = Stopwatch()..start();

        // 1. Check DAG stats (Backtracking)
        final graph = WordDependencyGraphBuilder.build(language: language);
        final dagSorts = graph.countTopologicalSorts();
        if (['JP', 'CS', 'CT'].contains(language.id)) {
          // These graphs consist of large components (>30 nodes) due to lack of splitting,
          // or lack of dependencies, which are too slow to count exactly.
          // We allow overflowSorts or a valid count.
          expect(
            dagSorts,
            anyOf(
              equals(WordDependencyGraph.overflowSorts),
              greaterThan(BigInt.zero),
            ),
          );
        } else {
          // All other languages should be calculable within the 1s limit.
          // overflowSorts indicates the graph component size exceeded the safety threshold.
          expect(
            dagSorts,
            greaterThan(BigInt.zero),
            reason:
                'Language ${language.id} returned invalid/overflow count ($dagSorts)',
          );
        }

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
