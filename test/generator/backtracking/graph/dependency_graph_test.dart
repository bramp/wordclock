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

    test('should track word positions in phrases', () {
      final lang = createMockLanguage(
        id: 'TEST',
        phrases: ['IT IS FIVE', 'IT IS TEN'],
      );
      final graph = WordDependencyGraphBuilder.build(language: lang);

      // IT is always at position 0
      final itPositions1 = graph.getPositionsInPhrase('IT', 'IT IS FIVE');
      final itPositions2 = graph.getPositionsInPhrase('IT', 'IT IS TEN');
      expect(itPositions1, [0]);
      expect(itPositions2, [0]);

      // IS is always at position 1
      final isPositions1 = graph.getPositionsInPhrase('IS', 'IT IS FIVE');
      final isPositions2 = graph.getPositionsInPhrase('IS', 'IT IS TEN');
      expect(isPositions1, [1]);
      expect(isPositions2, [1]);
    });

    test('should handle phrase with duplicate word', () {
      final lang = createMockLanguage(
        id: 'TEST',
        phrases: ['IT IS FIVE TO FIVE'],
      );
      final graph = WordDependencyGraphBuilder.build(language: lang);

      // FIVE should appear at positions 2 and 4
      final fivePositions = graph.getPositionsInPhrase(
        'FIVE',
        'IT IS FIVE TO FIVE',
      );
      expect(fivePositions, [2, 4]);

      // The phrase uses node IDs, so second FIVE will have a different ID
      final phraseNodes = graph.phrases['IT IS FIVE TO FIVE']!;
      expect(phraseNodes.length, 5);

      expect(phraseNodes[0].word, 'IT');
      expect(phraseNodes[1].word, 'IS');
      expect(phraseNodes[2].word, 'FIVE');
      expect(phraseNodes[3].word, 'TO');
      expect(phraseNodes[4].word, 'FIVE'); // Different node, same word
    });

    test('should calculate priority correctly', () {
      final lang = createMockLanguage(
        id: 'TEST',
        phrases: ['IT IS ONE', 'IT IS TWO', 'IT IS THREE'],
      );
      final graph = WordDependencyGraphBuilder.build(language: lang);

      // IT should have highest priority (appears in all phrases, reused)
      final sortedWords = graph.getWordsByPriority();
      expect(sortedWords[0], 'IT', reason: 'IT should have highest priority');

      // Priority formula: (frequency * 10.0) + (cells.length / 10.0)
      final itInstances = graph.nodes['IT']!;
      final itNode = itInstances[0];
      final expectedPriority =
          (itNode.frequency * 10.0) + (itNode.cells.length / 10.0);
      expect(itNode.priority, closeTo(expectedPriority, 0.01));

      // Verify IT has high frequency since it's reused across all phrases
      expect(itNode.frequency, 3, reason: 'IT appears in all 3 phrases');
    });

    test('should handle phrases with same words in different order', () {
      final lang = createMockLanguage(
        id: 'TEST',
        phrases: ['IT IS FIVE PAST TEN', 'IT IS TEN PAST FIVE'],
      );
      final graph = WordDependencyGraphBuilder.build(language: lang);

      // Both FIVE and TEN appear at different positions in different phrases
      final fiveInFirst = graph.getPositionsInPhrase(
        'FIVE',
        'IT IS FIVE PAST TEN',
      );
      final fiveInSecond = graph.getPositionsInPhrase(
        'FIVE',
        'IT IS TEN PAST FIVE',
      );

      expect(fiveInFirst, [2]);
      expect(fiveInSecond, [4]);

      // Check that nodes exist
      final fiveInstances = graph.nodes['FIVE'];
      expect(fiveInstances, isNotNull);
      expect(fiveInstances!.length, greaterThan(0));
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
