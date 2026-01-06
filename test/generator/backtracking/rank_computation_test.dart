import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/backtracking/dependency_graph.dart';
import 'package:wordclock/generator/backtracking/grid_builder.dart';
import 'package:wordclock/languages/english.dart';

void main() {
  group('BacktrackingGridBuilder.computeRanks', () {
    test('computes ranks for linear dependency A -> B -> C', () {
      final graph = _buildGraph({
        'A': {'B'},
        'B': {'C'},
        'C': <String>{},
      });

      final ranks = _simplifyRanks(BacktrackingGridBuilder.computeRanks(graph));

      expect(ranks['A'], 0);
      expect(ranks['B'], 1);
      expect(ranks['C'], 2);
    });

    test('computes ranks for branching dependency A -> B, A -> C', () {
      final graph = _buildGraph({
        'A': {'B', 'C'},
        'B': <String>{},
        'C': <String>{},
      });

      final ranks = _simplifyRanks(BacktrackingGridBuilder.computeRanks(graph));

      expect(ranks['A'], 0);
      expect(ranks['B'], 1);
      expect(ranks['C'], 1);
    });

    test('computes ranks for merge dependency A -> C, B -> C', () {
      final graph = _buildGraph({
        'A': {'C'},
        'B': {'C'},
        'C': <String>{},
      });

      final ranks = _simplifyRanks(BacktrackingGridBuilder.computeRanks(graph));

      expect(ranks['A'], 0);
      expect(ranks['B'], 0);
      expect(ranks['C'], 1);
    });

    test('computes ranks for disconnected components A -> B, C -> D', () {
      final graph = _buildGraph({
        'A': {'B'},
        'B': <String>{},
        'C': {'D'},
        'D': <String>{},
      });

      final ranks = _simplifyRanks(BacktrackingGridBuilder.computeRanks(graph));

      expect(ranks['A'], 0);
      expect(ranks['B'], 1);
      expect(ranks['C'], 0);
      expect(ranks['D'], 1);
    });

    test('handles cycles by assigning them to the last rank', () {
      // A -> B -> A
      final graph = _buildGraph({
        'A': {'B'},
        'B': {'A'},
      });

      final ranks = _simplifyRanks(BacktrackingGridBuilder.computeRanks(graph));

      // Cycle nodes get the rank after the last processed rank (which is 0)
      expect(ranks['A'], 0);
      expect(ranks['B'], 0);
    });

    test('handles partial cycles A -> B -> C -> B', () {
      // A -> B -> C
      //      ^    |
      //      |____|
      final graph = _buildGraph({
        'A': {'B'},
        'B': {'C'},
        'C': {'B'},
      });

      final ranks = _simplifyRanks(BacktrackingGridBuilder.computeRanks(graph));

      expect(ranks['A'], 0);
      // B and C are in a cycle, reachable from rank 0
      // In Kahn's algo:
      // - Init: A inDegree=0. Queue=[A].
      // - Process A: ranks[A]=0. Decrement B inDegree (was 1 from A + 1 from C = 2). B now 1.
      // - Queue empty.
      // - Remaining: B, C.
      // - Assigned currentRank (1).
      expect(ranks['B'], 1);
      expect(ranks['C'], 1);
    });

    test('handles sequential reuse of words (A#0 -> B -> A#1)', () {
      // Logic should NOT collapse ranks.
      // A#0 -> B#0 -> A#1

      final nodes = {
        'A': [_createNode('A', 0), _createNode('A', 1)],
        'B': [_createNode('B', 0)],
      };

      final edges = {
        'A': {'B'}, // A (Instance 0) -> B (Instance 0)
        'B': {'A#1'}, // B (Instance 0) -> A#1
        'A#1': <String>{}, // Sink
      };

      final graph = WordDependencyGraph(
        nodes: nodes,
        edges: edges,
        phrases: <String, List<String>>{},
        language: englishLanguage,
      );

      final ranks = _simplifyRanks(BacktrackingGridBuilder.computeRanks(graph));

      // Expected: A (0) -> B (1) -> A#1 (2)
      // Note: Instance 0 ID is simply "A" (not A#0) in current implementation convention.

      expect(ranks['A'], 0, reason: 'A (Instance 0) should be rank 0');
      expect(ranks['B'], 1, reason: 'B (Instance 0) should be rank 1');
      expect(ranks['A#1'], 2, reason: 'A#1 (Instance 1) should be rank 2');
    });
  });
}

// Helper to build a simple graph from a map of word -> successors
WordDependencyGraph _buildGraph(Map<String, Set<String>> adjacency) {
  final Map<String, List<WordNode>> nodes = {};
  final Map<String, Set<String>> edges = {};

  for (final entry in adjacency.entries) {
    final word = entry.key;
    nodes[word] = [_createNode(word, 0)];
    edges[word] = entry.value; // Simple 1:1 mapping for this test helper

    // Ensure targets exist in nodes
    for (final target in entry.value) {
      if (!nodes.containsKey(target)) {
        nodes[target] = [_createNode(target, 0)];
      }
      if (!edges.containsKey(target)) {
        edges[target] = <String>{};
      }
    }
  }

  return WordDependencyGraph(
    nodes: nodes,
    edges: edges,
    phrases: <String, List<String>>{},
    language: englishLanguage,
  );
}

WordNode _createNode(String word, int instance) {
  return WordNode(
    word: word,
    instance: instance,
    cells: word.split(''),
    phrases: {},
  );
}

Map<String, int> _simplifyRanks(Map<WordNode, int> ranks) {
  final simplified = <String, int>{};
  for (final entry in ranks.entries) {
    simplified[entry.key.id] = entry.value;
  }
  return simplified;
}
