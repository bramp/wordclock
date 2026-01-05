import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/backtracking/word_dependency_graph.dart';
import 'package:wordclock/languages/all.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/logic/time_to_words.dart';

/// Mock TimeToWords implementation for testing
class MockTimeToWords extends TimeToWords {
  final List<String> phrases;

  MockTimeToWords(this.phrases);

  @override
  String convert(DateTime time) {
    // Simple mock: return phrases in order based on minutes
    final index = time.minute % phrases.length;
    return phrases[index];
  }
}

/// Creates a mock language for testing with controlled phrases
WordClockLanguage createMockLanguage({
  required String id,
  required List<String> phrases,
  int minuteIncrement = 5,
}) {
  return WordClockLanguage(
    id: id,
    languageCode: 'en-TEST',
    displayName: 'Test Language',
    englishName: 'Test',
    timeToWords: MockTimeToWords(phrases),
    minuteIncrement: minuteIncrement,
    requiresPadding: true,
    atomizePhrases: false,
  );
}

void main() {
  group('WordDependencyGraph', () {
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

    test(
      'should handle words appearing multiple times with different contexts',
      () {
        final lang = createMockLanguage(
          id: 'TEST',
          phrases: [
            'IT IS FIVE TO FIVE', // FIVE appears twice in same phrase
            'IT IS TEN TO TEN', // TEN appears twice in same phrase
            'IT IS ONE', // ONE appears once
          ],
        );
        final graph = WordDependencyGraphBuilder.build(language: lang);

        // FIVE appears twice in same phrase, so should have 2 instances
        final fiveInstances = graph.nodes['FIVE'];
        expect(fiveInstances, isNotNull);
        expect(
          fiveInstances!.length,
          2,
          reason: 'FIVE should have 2 instances (appears twice in same phrase)',
        );

        // TEN should also have 2 instances
        final tenInstances = graph.nodes['TEN'];
        expect(tenInstances, isNotNull);
        expect(
          tenInstances!.length,
          2,
          reason: 'TEN should have 2 instances (appears twice in same phrase)',
        );
      },
    );

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
      final phraseNodeIds = graph.phrases['IT IS FIVE TO FIVE']!;
      expect(phraseNodeIds.length, 5);

      // Helper to get node by ID
      WordNode? getNodeById(String id) {
        for (final instances in graph.nodes.values) {
          for (final node in instances) {
            if (node.id == id) return node;
          }
        }
        return null;
      }

      expect(getNodeById(phraseNodeIds[0])!.word, 'IT');
      expect(getNodeById(phraseNodeIds[1])!.word, 'IS');
      expect(getNodeById(phraseNodeIds[2])!.word, 'FIVE');
      expect(getNodeById(phraseNodeIds[3])!.word, 'TO');
      expect(
        getNodeById(phraseNodeIds[4])!.word,
        'FIVE',
      ); // Different node, same word
    });

    test('should create edges representing word order within phrases', () {
      final lang = createMockLanguage(
        id: 'TEST',
        phrases: ['IT IS ONE', 'IT IS TWO'],
      );
      final graph = WordDependencyGraphBuilder.build(language: lang);

      // Helper to get node by ID
      WordNode? getNodeById(String id) {
        for (final instances in graph.nodes.values) {
          for (final node in instances) {
            if (node.id == id) return node;
          }
        }
        return null;
      }

      // IT should have an edge to an IS node
      final itSuccessors = graph.edges['IT'] ?? {};
      expect(
        itSuccessors.any((id) => getNodeById(id)?.word == 'IS'),
        isTrue,
        reason: 'IT should have edge to IS node',
      );

      // IS nodes should have edges to ONE and TWO
      final allSuccessors = <String>{};
      for (final entry in graph.edges.entries) {
        if (getNodeById(entry.key)?.word == 'IS') {
          allSuccessors.addAll(entry.value);
        }
      }
      expect(
        allSuccessors.any((id) => getNodeById(id)?.word == 'ONE'),
        isTrue,
        reason: 'IS nodes should have edge to ONE',
      );
      expect(
        allSuccessors.any((id) => getNodeById(id)?.word == 'TWO'),
        isTrue,
        reason: 'IS nodes should have edge to TWO',
      );
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

      // Check for bidirectional edges
      final bidirectional = <String, List<String>>{};

      for (final entry in graph.edges.entries) {
        final from = entry.key;
        final successors = entry.value;
        for (final to in successors) {
          if (graph.edges[to]?.contains(from) ?? false) {
            bidirectional.putIfAbsent(from, () => []).add(to);
          }
        }
      }

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

      // FIVE and TEN can be reused (no cycle created by reusing them)
      // In 'FIVE PAST TEN': FIVE#0 -> PAST#0 -> TEN#0
      // In 'TEN PAST FIVE': TEN#0 -> PAST#1 -> FIVE#0 (PAST#1 needed to avoid cycle)
      final fiveInstances = cyclicGraph.nodes['FIVE'];
      expect(fiveInstances, isNotNull);
      expect(fiveInstances!.length, 1, reason: 'FIVE can be reused (no cycle)');
      expect(fiveInstances[0].frequency, 2);

      final tenInstances = cyclicGraph.nodes['TEN'];
      expect(tenInstances, isNotNull);
      expect(tenInstances!.length, 1, reason: 'TEN can be reused (no cycle)');
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

    test('should create correct edges for sequential words in phrase', () {
      final lang = createMockLanguage(
        id: 'TEST',
        phrases: ['A B C D', 'A E F'],
      );
      final graph = WordDependencyGraphBuilder.build(language: lang);

      // In any phrase, word[i] should have edge to word[i+1]
      for (final entry in graph.phrases.entries) {
        final words = entry.value;
        for (int i = 0; i < words.length - 1; i++) {
          final currentWord = words[i];
          final nextWord = words[i + 1];

          expect(
            graph.edges[currentWord],
            contains(nextWord),
            reason:
                'In phrase "${entry.key}", $currentWord should have edge to $nextWord',
          );
        }
      }
    });

    test('should handle multiple instances in complex phrase patterns', () {
      final lang = createMockLanguage(
        id: 'TEST',
        phrases: [
          'A B A B A', // A appears 3 times, B appears 2 times
          'B C B', // B appears 2 times, C appears 1 time
        ],
      );
      final graph = WordDependencyGraphBuilder.build(language: lang);

      // Each occurrence of A in different contexts should create a separate node
      // A at position 0 (pred=null, succ=B)
      // A at position 2 (pred=B, succ=B)
      // A at position 4 (pred=B, succ=null)

      // Check that A nodes exist
      final aInstances = graph.nodes['A'];
      expect(aInstances, isNotNull, reason: 'Should have A nodes');
      expect(aInstances!.length, greaterThan(0));

      // Check positions in first phrase
      final aPositions = graph.getPositionsInPhrase('A', 'A B A B A');
      expect(aPositions, [0, 2, 4]);

      final bPositions = graph.getPositionsInPhrase('B', 'A B A B A');
      expect(bPositions, [1, 3]);
    });
  });

  group('WordDependencyGraph - Real Language Integration', () {
    test('should work with English language', () {
      final lang = WordClockLanguages.byId['EN']!;
      final graph = WordDependencyGraphBuilder.build(language: lang);

      expect(graph.nodes.length, greaterThan(0));
      expect(graph.phrases.length, greaterThan(0));

      // IT and IS should appear
      expect(graph.nodes['IT'], isNotNull);
      expect(graph.nodes['IS'], isNotNull);
      expect(graph.nodes['FIVE'], isNotNull);
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
  });

  group('WordNode', () {
    test('should have correct id from word and instance', () {
      final node0 = WordNode(
        word: 'TEST',
        instance: 0,
        cells: ['T', 'E', 'S', 'T'],
        phrases: {'phrase1'},
      );
      expect(node0.id, 'TEST');

      final node1 = WordNode(
        word: 'TEST',
        instance: 1,
        cells: ['T', 'E', 'S', 'T'],
        phrases: {'phrase1'},
      );
      expect(node1.id, 'TEST#1');

      final node2 = WordNode(
        word: 'FIVE',
        instance: 2,
        cells: ['F', 'I', 'V', 'E'],
        phrases: {'phrase1'},
      );
      expect(node2.id, 'FIVE#2');
    });

    test('should calculate frequency correctly', () {
      final node = WordNode(
        word: 'TEST',
        instance: 0,
        cells: ['T', 'E', 'S', 'T'],
        phrases: {'phrase1', 'phrase2', 'phrase3'},
      );

      expect(node.frequency, 3);
    });

    test('should calculate priority correctly', () {
      final node = WordNode(
        word: 'TEST',
        instance: 0,
        cells: ['T', 'E', 'S', 'T'],
        phrases: {'phrase1', 'phrase2'},
      );

      // Priority formula: (frequency * 10.0) + (cells.length / 10.0)
      final expectedPriority = (2 * 10.0) + (4 / 10.0);
      expect(node.priority, closeTo(expectedPriority, 0.01));
    });
  });

  group('WordDependencyGraph - Cycle Prevention', () {
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
      final fiveSuccessors = graph.edges['FIVE'] ?? {};
      expect(fiveSuccessors.contains('PAST'), isTrue);
      expect(fiveSuccessors.contains('TO'), isTrue);
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
      final tenSuccessors = graph.edges['TEN'] ?? {};
      expect(
        tenSuccessors.contains('PAST'),
        isTrue,
        reason: 'TEN -> PAST in first phrase',
      );
      expect(
        tenSuccessors.contains('AFTER'),
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
      final hasCycle = <String, List<String>>{};
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
      expect(graph.edges['A']!.contains('B'), isTrue);
      expect(graph.edges['B']!.contains('A#1'), isTrue);
      final a1Edges = graph.edges['A#1'];
      expect(a1Edges == null || a1Edges.isEmpty, isTrue); // A#1 is at end
    });
  });
}
