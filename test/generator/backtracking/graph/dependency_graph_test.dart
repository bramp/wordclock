import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/backtracking/graph/dependency_graph.dart';
import 'package:wordclock/generator/backtracking/graph/graph_builder.dart';
import 'package:wordclock/generator/backtracking/graph/word_node.dart';
import 'package:wordclock/languages/all.dart';

import 'test_helpers.dart';

void main() {
  group('WordDependencyGraph Methods', () {
    test('should track word frequency correctly', () {
      final lang = createMockLanguage(
        id: 'TEST',
        phrases: ['IT IS ONE', 'IT IS TWO', 'IT IS THREE'],
      );
      final graph = WordDependencyGraphBuilder.build(language: lang);

      // IT should be reused across all 3 phrases
      final itInstances = graph.nodes['IT'];
      expect(itInstances, isNotNull);
      expect(itInstances!.length, 1); // Only one instance
      expect(itInstances[0].frequency, 3); // Reused across all 3 phrases
    });

    test('should work with English language', () {
      final lang = WordClockLanguages.byId['EN']!;
      final graph = WordDependencyGraphBuilder.build(language: lang);

      expect(graph.nodes.length, greaterThan(0));
      expect(graph.phrases.length, greaterThan(0));

      // IT and IS should appear
      expect(graph.nodes['IT'], isNotNull);
      expect(graph.nodes['IS'], isNotNull);
      expect(graph.nodes['FIVE'], isNotNull);

      // Verify duplicate instances for FIVE (e.g. in "FIVE PAST FIVE")
      // English E3 definitely has this.
      final fiveInstances = graph.nodes['FIVE'];
      expect(
        fiveInstances!.length,
        greaterThanOrEqualTo(2),
        reason: 'FIVE should appear multiple times in English phrases',
      );
    });
  });
}
