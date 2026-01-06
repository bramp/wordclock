import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/backtracking/graph/dependency_graph.dart';
import 'package:wordclock/generator/backtracking/graph/word_node.dart';
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

      final nodeA0 = nodes['A']![0];
      final nodeA1 = nodes['A']![1];
      final nodeB = nodes['B']![0];

      final edges = {
        nodeA0: {nodeB}, // A (Instance 0) -> B (Instance 0)
        nodeB: {nodeA1}, // B (Instance 0) -> A#1
        nodeA1: <WordNode>{}, // Sink
      };

      final inEdges = <WordNode, Set<WordNode>>{};
      for (final entry in edges.entries) {
        for (final succ in entry.value) {
          inEdges.putIfAbsent(succ, () => {}).add(entry.key);
        }
      }

      final graph = WordDependencyGraph(
        nodes: nodes,
        edges: edges,
        inEdges: inEdges,
        phrases: <String, List<WordNode>>{},
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
  final Map<WordNode, Set<WordNode>> edges = {};

  // 1. Create nodes
  for (final entry in adjacency.entries) {
    final word = entry.key;
    if (!nodes.containsKey(word)) {
      nodes[word] = [_createNode(word, 0)];
    }
    for (final target in entry.value) {
      // Handle "A#1" style inputs if any (the test helper handles sequential reuse test)
      final parts = target.split('#');
      final targetWord = parts[0];
      final targetInstance = parts.length > 1 ? int.parse(parts[1]) : 0;

      if (!nodes.containsKey(targetWord)) {
        nodes[targetWord] = [];
      }
      // Ensure specific instance exists
      var exists = false;
      for (final n in nodes[targetWord]!) {
        if (n.instance == targetInstance) {
          exists = true;
          break;
        }
      }
      if (!exists) {
        nodes[targetWord]!.add(_createNode(targetWord, targetInstance));
      }
    }
  }

  // 2. Create edges
  for (final entry in adjacency.entries) {
    final sourceParts = entry.key.split('#');
    final sourceWord = sourceParts[0];
    final sourceInstance = sourceParts.length > 1
        ? int.parse(sourceParts[1])
        : 0;

    final sourceNode = nodes[sourceWord]!.firstWhere(
      (n) => n.instance == sourceInstance,
    );

    final targets = <WordNode>{};
    for (final target in entry.value) {
      final targetParts = target.split('#');
      final targetWord = targetParts[0];
      final targetInstance = targetParts.length > 1
          ? int.parse(targetParts[1])
          : 0;

      final targetNode = nodes[targetWord]!.firstWhere(
        (n) => n.instance == targetInstance,
      );
      targets.add(targetNode);
    }
    edges[sourceNode] = targets;
  }

  final inEdges = <WordNode, Set<WordNode>>{};
  for (final entry in edges.entries) {
    for (final succ in entry.value) {
      inEdges.putIfAbsent(succ, () => {}).add(entry.key);
    }
  }

  return WordDependencyGraph(
    nodes: nodes,
    edges: edges,
    inEdges: inEdges,
    phrases: <String, List<WordNode>>{},
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
