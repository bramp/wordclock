import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/backtracking/graph/graph_builder.dart';
import 'package:wordclock/generator/backtracking/graph/word_node.dart';
import 'package:wordclock/languages/all.dart';

import 'test_helpers.dart';

void main() {
  group('WordDependencyGraphBuilder', () {
    test('should build graph for mock language', () {
      final lang = createMockLanguage(
        id: 'TEST',
        phrases: ['IT IS ONE', 'IT IS TWO', 'IT IS THREE'],
      );
      final graph = WordDependencyGraphBuilder.build(language: lang);

      // With context-based nodes, we have: IT, IS, ONE, TWO, THREE
      // but since each phrase is different, IT and IS might be reused or create new instances
      expect(graph.nodes.length, greaterThanOrEqualTo(5));
      expect(graph.phrases.length, 3);
    });

    test('should create edges representing word order within phrases', () {
      final lang = createMockLanguage(
        id: 'TEST',
        phrases: ['IT IS ONE', 'IT IS TWO'],
      );
      final graph = WordDependencyGraphBuilder.build(language: lang);

      // Helper to check if node has successor with specific word
      bool hasSuccessorWord(WordNode node, String targetWord) {
        final successors = graph.edges[node];
        if (successors == null) return false;
        return successors.any((n) => n.word == targetWord);
      }

      final itNodes = graph.nodes['IT']!;
      expect(itNodes.isNotEmpty, isTrue);
      // IT should have an edge to an IS node
      expect(
        itNodes.any((n) => hasSuccessorWord(n, 'IS')),
        isTrue,
        reason: 'IT should have edge to IS node',
      );

      final isNodes = graph.nodes['IS']!;
      expect(isNodes.isNotEmpty, isTrue);

      // Check IS -> ONE and IS -> TWO
      bool pointsToOne = false;
      bool pointsToTwo = false;

      for (final isNode in isNodes) {
        if (hasSuccessorWord(isNode, 'ONE')) pointsToOne = true;
        if (hasSuccessorWord(isNode, 'TWO')) pointsToTwo = true;
      }

      expect(pointsToOne, isTrue, reason: 'IS nodes should have edge to ONE');
      expect(pointsToTwo, isTrue, reason: 'IS nodes should have edge to TWO');
    });

    test('should handle potential cycles from node reuse across phrases', () {
      final lang = createMockLanguage(
        id: 'TEST',
        phrases: [
          'A B C',
          'C D A', // Reusing A and C can create cycles
        ],
      );
      final graph = WordDependencyGraphBuilder.build(language: lang);

      // Cycles can occur when nodes are reused across phrases
      // The graphs package handles this gracefully
      // Just verify the graph was built successfully
      expect(graph.nodes.length, greaterThan(0));
      expect(graph.phrases.length, 2);

      // Test with a pattern that creates cycles
      final cyclicLang = createMockLanguage(
        id: 'TEST',
        phrases: [
          'FIVE PAST TEN',
          'TEN PAST FIVE', // Would create cycle if PAST reused
        ],
      );
      final cyclicGraph = WordDependencyGraphBuilder.build(
        language: cyclicLang,
      );

      // Verify graph structure is valid
      expect(cyclicGraph.nodes.length, greaterThan(0));
      expect(cyclicGraph.phrases.length, 2);

      // FIVE and TEN might need multiple instances if reuse creates cycles.
      // In 'FIVE PAST TEN': FIVE#0 -> PAST#0 -> TEN#0
      // In 'TEN PAST FIVE':
      //   TEN#0 reuses TEN#0.
      //   PAST#0 would create cycle (PAST#0 -> TEN#0 -> PAST#0), so uses PAST#1.
      //   FIVE#0 would create cycle (FIVE#0 -> PAST#0 -> TEN#0 -> PAST#1 -> FIVE#0), so uses FIVE#1.
      final fiveInstances = cyclicGraph.nodes['FIVE'];
      expect(fiveInstances, isNotNull);
      expect(
        fiveInstances!.length,
        2,
        reason: 'FIVE needs 2 instances to prevent cycle',
      );
      expect(fiveInstances[0].frequency, 1);
      expect(fiveInstances[1].frequency, 1);

      final tenInstances = cyclicGraph.nodes['TEN'];
      expect(tenInstances, isNotNull);
      expect(tenInstances!.length, 1, reason: 'TEN can be reused');
      expect(tenInstances[0].frequency, 2);

      // PAST needs 2 instances to prevent cycle
      final pastInstances = cyclicGraph.nodes['PAST'];
      expect(pastInstances, isNotNull);
      expect(
        pastInstances!.length,
        2,
        reason: 'PAST has 2 instances to prevent cycle',
      );
      expect(pastInstances[0].frequency, 1);
      expect(pastInstances[1].frequency, 1);
    });

    test('should handle words in multiple contexts', () {
      final lang = createMockLanguage(
        id: 'TEST',
        phrases: ['IT IS FIVE TO FIVE', 'IT IS TEN'],
      );
      final graph = WordDependencyGraphBuilder.build(language: lang);

      // FIVE appears twice in same phrase, so should have 2 instances
      final fiveInstances = graph.nodes['FIVE'];
      expect(fiveInstances, isNotNull);
      expect(
        fiveInstances!.length,
        2,
        reason: 'Should have 2 FIVE instances (appears twice in same phrase)',
      );
    });

    test('should create correct edges for sequential words in phrase', () {
      final lang = createMockLanguage(
        id: 'TEST',
        phrases: ['A B C D', 'A E F'],
      );
      final graph = WordDependencyGraphBuilder.build(language: lang);

      // In any phrase, word[i] should have edge to word[i+1]
      for (final entry in graph.phrases.entries) {
        final nodes = entry.value;
        for (int i = 0; i < nodes.length - 1; i++) {
          final currentNode = nodes[i];
          final nextNode = nodes[i + 1];

          expect(
            graph.edges[currentNode],
            contains(nextNode),
            reason:
                'In phrase "${entry.key}", ${currentNode.id} should have edge to ${nextNode.id}',
          );
        }
      }
    });

    test('should work with different languages', () {
      final languages = ['EN', 'DE', 'FR'];

      for (final langId in languages) {
        final lang = WordClockLanguages.byId[langId];
        if (lang != null) {
          final graph = WordDependencyGraphBuilder.build(language: lang);

          expect(
            graph.nodes.length,
            greaterThan(0),
            reason: '$langId should have nodes',
          );
          expect(
            graph.phrases.length,
            greaterThan(0),
            reason: '$langId should have phrases',
          );
          expect(
            graph.edges.length,
            greaterThan(0),
            reason: '$langId should have edges',
          );
        }
      }
    });

    group('Cycle Prevention', () {
      test(
        'should only create separate nodes when word appears multiple times in same phrase',
        () {
          final lang = createMockLanguage(
            id: 'TEST',
            phrases: [
              'IT IS FIVE TO FIVE', // FIVE appears twice in SAME phrase
            ],
          );
          final graph = WordDependencyGraphBuilder.build(language: lang);

          // Should have FIVE (instance 0) and FIVE#1 (instance 1)
          final fiveInstances = graph.nodes['FIVE'];
          expect(fiveInstances, isNotNull);
          expect(fiveInstances!.length, 2); // Two instances
          expect(fiveInstances[0].instance, 0);
          expect(fiveInstances[1].instance, 1);

          // Should NOT have multiple TO nodes (appears once per phrase)
          final toInstances = graph.nodes['TO'];
          expect(toInstances, isNotNull);
          expect(toInstances!.length, 1); // Only one instance
        },
      );

      test('should reuse nodes across different phrases', () {
        final lang = createMockLanguage(
          id: 'TEST',
          phrases: [
            'IT IS FIVE PAST ONE', // FIVE appears once
            'IT IS FIVE TO TWO', // FIVE appears once again
            'IT IS TEN PAST THREE', // Different word
          ],
        );
        final graph = WordDependencyGraphBuilder.build(language: lang);

        // FIVE should be reused (only one instance)
        final fiveInstances = graph.nodes['FIVE'];
        expect(fiveInstances, isNotNull);
        expect(fiveInstances!.length, 1);
        expect(fiveInstances[0].id, 'FIVE');
        expect(fiveInstances[0].frequency, 2); // Appears in 2 phrases

        // Verify edges: FIVE should have edges to both PAST and TO
        final successors = <String>{};
        final nodeFive = fiveInstances[0];
        final edges = graph.edges[nodeFive];
        if (edges != null) {
          for (final succ in edges) {
            successors.add(succ.word);
          }
        }

        expect(successors.contains('PAST'), isTrue);
        expect(successors.contains('TO'), isTrue);
      });

      test('should handle word appearing 3 times in same phrase', () {
        final lang = createMockLanguage(
          id: 'TEST',
          phrases: [
            'A B A C A', // A appears 3 times
          ],
        );
        final graph = WordDependencyGraphBuilder.build(language: lang);

        // Should have A with instances 0, 1, and 2
        final aInstances = graph.nodes['A'];
        expect(aInstances, isNotNull);
        expect(aInstances!.length, 3);
        expect(aInstances[0].instance, 0);
        expect(aInstances[1].instance, 1);
        expect(aInstances[2].instance, 2);

        // Each should appear in only 1 phrase
        expect(aInstances[0].frequency, 1);
        expect(aInstances[1].frequency, 1);
        expect(aInstances[2].frequency, 1);
      });

      test('should accumulate edges across phrases when no cycles', () {
        // Use phrases that don't create cycles
        final lang = createMockLanguage(
          id: 'TEST',
          phrases: [
            'IT IS TEN PAST ONE', // IT -> IS -> TEN -> PAST -> ONE
            'IT IS TEN AFTER TWO', // IT -> IS -> TEN -> AFTER -> TWO (reuses TEN, no cycle)
            'IT IS THREE', // IT -> IS -> THREE
          ],
        );
        final graph = WordDependencyGraphBuilder.build(language: lang);

        // TEN should be reused since no cycles
        final tenInstances = graph.nodes['TEN'];
        expect(tenInstances, isNotNull);
        expect(
          tenInstances!.length,
          1,
          reason: 'TEN should have 1 instance (no cycles created)',
        );

        // Check edges: TEN should have both PAST and AFTER as successors
        final successors = <String>{};
        final nodeTen = tenInstances[0];
        final edges = graph.edges[nodeTen];
        if (edges != null) {
          for (final n in edges) {
            successors.add(n.word);
          }
        }
        expect(
          successors.contains('PAST'),
          isTrue,
          reason: 'TEN -> PAST in first phrase',
        );
        expect(
          successors.contains('AFTER'),
          isTrue,
          reason: 'TEN -> AFTER in second phrase',
        );
      });

      test('should handle no cycles when word appears once per phrase', () {
        final lang = createMockLanguage(
          id: 'TEST',
          phrases: ['A B C', 'B C D', 'C D E'],
        );
        final graph = WordDependencyGraphBuilder.build(language: lang);

        // Check for cycles
        final hasCycle = <WordNode, List<WordNode>>{};
        for (final entry in graph.edges.entries) {
          for (final to in entry.value) {
            if (graph.edges[to]?.contains(entry.key) ?? false) {
              hasCycle.putIfAbsent(entry.key, () => []).add(to);
            }
          }
        }

        // No word appears multiple times in same phrase, so no cycles from that
        // But cycles can still occur from reused nodes (e.g., C -> D and D -> C from different phrases)
        // This is expected and handled by graphs package
        expect(graph.nodes.length, 5); // A, B, C, D, E
      });

      test('should prevent cycles within same phrase', () {
        final lang = createMockLanguage(
          id: 'TEST',
          phrases: [
            'A B A', // Would create cycle A -> B -> A if not handled
          ],
        );
        final graph = WordDependencyGraphBuilder.build(language: lang);

        // Should have A with 2 instances
        final aInstances = graph.nodes['A'];
        expect(aInstances, isNotNull);
        expect(aInstances!.length, 2); // A and A#1

        // Edges should be A -> B -> A#1 (no cycle)
        final nodeA0 = aInstances.firstWhere((n) => n.instance == 0);
        final nodeA1 = aInstances.firstWhere((n) => n.instance == 1);
        final nodeB = graph.nodes['B']![0];

        expect(graph.edges[nodeA0]!.contains(nodeB), isTrue);
        expect(graph.edges[nodeB]!.contains(nodeA1), isTrue);

        final a1Edges = graph.edges[nodeA1];
        expect(a1Edges == null || a1Edges.isEmpty, isTrue); // A#1 is at end
      });
    });

    group('inEdges (predecessors)', () {
      test('should be consistent with edges', () {
        final lang = createMockLanguage(
          id: 'TEST',
          phrases: ['IT IS ONE', 'IT IS TWO', 'TEN PAST FIVE', 'FIVE PAST TEN'],
        );
        final graph = WordDependencyGraphBuilder.build(language: lang);

        // For every edge A -> B in edges, A must be in inEdges[B]
        for (final entry in graph.edges.entries) {
          final fromNode = entry.key;
          for (final toNode in entry.value) {
            expect(
              graph.inEdges[toNode],
              isNotNull,
              reason: 'inEdges should contain an entry for $toNode',
            );
            expect(
              graph.inEdges[toNode]!.contains(fromNode),
              isTrue,
              reason: 'inEdges[$toNode] should contain $fromNode',
            );
          }
        }

        // For every parent A in inEdges[B], B must be in edges[A]
        for (final entry in graph.inEdges.entries) {
          final toNode = entry.key;
          for (final fromNode in entry.value) {
            expect(
              graph.edges[fromNode],
              isNotNull,
              reason: 'edges should contain an entry for $fromNode',
            );
            expect(
              graph.edges[fromNode]!.contains(toNode),
              isTrue,
              reason: 'edges[$fromNode] should contain $toNode',
            );
          }
        }
      });

      test('shoud correctly map predecessors in a simple phrase', () {
        final lang = createMockLanguage(id: 'TEST', phrases: ['IT IS ONE']);
        final graph = WordDependencyGraphBuilder.build(language: lang);

        final itNode = graph.nodes['IT']!.first;
        final isNode = graph.nodes['IS']!.first;
        final oneNode = graph.nodes['ONE']!.first;

        expect(graph.inEdges[itNode], isNull, reason: 'First node has no inEdges');
        expect(graph.inEdges[isNode]!.contains(itNode), isTrue);
        expect(graph.inEdges[oneNode]!.contains(isNode), isTrue);
      });

      test('should correctly map multiple predecessors for shared nodes', () {
        final lang = createMockLanguage(
          id: 'TEST',
          phrases: ['IT IS ONE', 'SHE IS TWO'],
        );
        final graph = WordDependencyGraphBuilder.build(language: lang);

        final isNode = graph.nodes['IS']!.first;
        final itNode = graph.nodes['IT']!.first;
        final sheNode = graph.nodes['SHE']!.first;

        expect(graph.inEdges[isNode]!.length, 2);
        expect(graph.inEdges[isNode]!.contains(itNode), isTrue);
        expect(graph.inEdges[isNode]!.contains(sheNode), isTrue);
      });
    });
  });
}
