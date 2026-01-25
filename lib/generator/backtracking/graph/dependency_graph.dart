import 'package:wordclock/generator/backtracking/graph/word_node.dart';
import 'package:wordclock/generator/backtracking/graph/cell_codec.dart';
import 'package:wordclock/languages/language.dart';

/// A word-level dependency graph (DAG) for the word clock.
///
/// Unlike the character-level DAG in dependency_graph.dart, this represents
/// dependencies between entire words in phrases. Words appearing in different
/// contexts are represented as separate nodes to avoid cycles.
class WordDependencyGraph {
  /// All word nodes grouped by word: word → list of instances
  /// e.g., nodes["FIVE"] returns [FIVE (instance 0), FIVE#1 (instance 1)]
  final Map<String, List<WordNode>> nodes;

  /// Edges representing word ordering: node ID → set of successor node IDs
  final Map<WordNode, Set<WordNode>> edges;

  /// Inverted edges (parents): node ID → set of predecessor node IDs
  final Map<WordNode, Set<WordNode>> inEdges;

  /// All phrases: phrase text -> ordered list of nodes
  final Map<String, List<WordNode>> phrases;

  /// Language this graph was built for
  final WordClockLanguage language;

  /// Cell codec for encoding/decoding cells to integers
  final CellCodec codec;

  WordDependencyGraph({
    required this.nodes,
    required this.edges,
    required this.inEdges,
    required this.phrases,
    required this.language,
    required this.codec,
  });

  /// All word nodes in the graph
  List<WordNode> get allNodes => nodes.values.expand((i) => i).toList();

  /// Compute topological ranks for all word instances in this graph.
  /// Ranks represent the longest path from a root node to this node.
  Map<WordNode, int> computeRanks() {
    final inDegree = <WordNode, int>{};
    final nodes = allNodes;

    for (final node in nodes) {
      inDegree[node] = 0;
    }

    for (final entry in edges.entries) {
      for (final succ in entry.value) {
        inDegree[succ] = (inDegree[succ] ?? 0) + 1;
      }
    }

    final ranks = <WordNode, int>{};
    var queue = inDegree.entries
        .where((e) => e.value == 0)
        .map((e) => e.key)
        .toList();

    // Sort initial queue for deterministic results
    queue.sort((a, b) => a.id.compareTo(b.id));

    int currentRank = 0;
    while (queue.isNotEmpty) {
      final nextQueue = <WordNode>[];
      for (final node in queue) {
        ranks[node] = currentRank;
        for (final succ in edges[node] ?? {}) {
          inDegree[succ] = inDegree[succ]! - 1;
          if (inDegree[succ] == 0) nextQueue.add(succ);
        }
      }
      queue = nextQueue;
      queue.sort((a, b) => a.id.compareTo(b.id));
      currentRank++;
    }

    // Nodes in cycles might not be in ranks; assign them a rank
    for (final node in nodes) {
      if (!ranks.containsKey(node)) ranks[node] = currentRank;
    }
    return ranks;
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('WordDependencyGraph:');
    int totalNodes = 0;
    for (final instances in nodes.values) {
      totalNodes += instances.length;
    }
    buffer.writeln('  ${nodes.length} unique words ($totalNodes total nodes)');
    buffer.writeln('  ${phrases.length} phrases');

    int totalEdges = 0;
    for (final successors in edges.values) {
      totalEdges += successors.length;
    }
    buffer.writeln('  $totalEdges dependencies');

    final sorts = countTopologicalSorts();
    String sortsStr;
    if (sorts == BigInt.zero) {
      sortsStr = '0';
    } else {
      final s = sorts.toString();
      if (s.length <= 15) {
        sortsStr = s;
      } else {
        sortsStr = '${s[0]}.${s.substring(1, 4)}e+${s.length - 1}';
      }
    }
    buffer.writeln('  $sortsStr topological sorts');

    return buffer.toString();
  }

  /// Calculates the number of valid topological sorts (linear extensions).
  /// This represents the number of valid word placement sequences.
  BigInt countTopologicalSorts() {
    final all = allNodes;
    if (all.isEmpty) return BigInt.zero;

    // Find weakly connected components
    final components = _findComponents(all);

    var totalNodesFound = 0;
    var result = BigInt.one;

    for (final componentNodes in components) {
      final componentSorts = _countSortsRecursive(componentNodes);
      if (componentSorts == BigInt.zero) return BigInt.zero;

      // Combine with previous result using multinomial coefficient:
      // result = result * componentSorts * nCr(totalNodesFound + size, size)
      result =
          result *
          componentSorts *
          _nCr(totalNodesFound + componentNodes.length, componentNodes.length);
      totalNodesFound += componentNodes.length;
    }

    return result;
  }

  List<List<WordNode>> _findComponents(List<WordNode> all) {
    final adj = <WordNode, Set<WordNode>>{};
    for (final node in all) {
      adj[node] = {};
      for (final succ in edges[node] ?? {}) {
        adj[node]!.add(succ);
      }
      for (final pred in inEdges[node] ?? {}) {
        adj[node]!.add(pred);
      }
    }

    final visited = <WordNode>{};
    final components = <List<WordNode>>[];

    for (final node in all) {
      if (visited.contains(node)) continue;
      final component = <WordNode>[];
      final queue = [node];
      visited.add(node);
      while (queue.isNotEmpty) {
        final current = queue.removeLast();
        component.add(current);
        for (final neighbor in adj[current]!) {
          if (visited.add(neighbor)) {
            queue.add(neighbor);
          }
        }
      }
      components.add(component);
    }
    return components;
  }

  BigInt _countSortsRecursive(List<WordNode> nodes) {
    final n = nodes.length;
    if (n > 63) return BigInt.zero; // Safety limit for bitset

    final idToIndex = {for (int i = 0; i < n; i++) nodes[i].id: i};
    final predMasks = List<int>.filled(n, 0);
    for (int i = 0; i < n; i++) {
      for (final pred in inEdges[nodes[i]] ?? <WordNode>{}) {
        final idx = idToIndex[pred.id];
        if (idx != null) predMasks[i] |= (1 << idx);
      }
    }

    final memo = <int, BigInt>{};

    BigInt solve(int mask) {
      if (mask == (1 << n) - 1) return BigInt.one;
      if (memo.containsKey(mask)) return memo[mask]!;

      var count = BigInt.zero;
      for (int i = 0; i < n; i++) {
        if ((mask & (1 << i)) == 0) {
          if ((predMasks[i] & mask) == predMasks[i]) {
            count += solve(mask | (1 << i));
          }
        }
      }
      return memo[mask] = count;
    }

    return solve(0);
  }

  BigInt _nCr(int n, int r) {
    if (r < 0 || r > n) return BigInt.zero;
    if (r == 0 || r == n) return BigInt.one;
    if (r > n / 2) r = n - r;

    var res = BigInt.one;
    for (int i = 1; i <= r; i++) {
      res = res * BigInt.from(n - i + 1) ~/ BigInt.from(i);
    }
    return res;
  }
}
