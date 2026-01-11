import 'package:wordclock/generator/backtracking/graph/dependency_graph.dart';
import 'package:wordclock/generator/backtracking/graph/word_node.dart';

/// Pre-computed word metadata indexed for efficient backtracking.
///
/// Groups together the sorted word list and precomputed metadata that are
/// computed once during setup and used throughout the search.
///
/// ## Why this exists
/// During backtracking, we need to:
/// 1. Iterate words in a specific order (by rank, then length)
/// 2. Look up successors by index (not by node reference)
/// 3. Track which words have been placed using a bitset
/// 4. Quickly compute space requirements for pruning
///
/// This class pre-computes and caches these structures to avoid
/// repeated lookups during the hot path.
class IndexedWordList {
  /// Nodes sorted by (rank ascending, length descending).
  /// Lower indices = lower rank (fewer dependencies), longer words.
  final List<WordNode> nodes;

  /// For each node index, the list of successor indices.
  /// `successorIndices[i]` contains indices of nodes that depend on node i.
  final List<List<int>> successorIndices;

  /// Initial in-degree (predecessor count) for each node.
  /// Used to compute the initial eligible mask.
  final List<int> initialInDegree;

  /// Nodes with in-degree 0 (can be placed immediately).
  /// Encoded as a bitmask where bit i set means node i is initially eligible.
  final int initialEligibleMask;

  /// Word length for each node index (for fast lookup during pruning)
  final List<int> wordLengths;

  /// Minimum cells each word must contribute beyond overlap.
  /// `minContribution[i]` = wordLengths[i] - maxIncomingOverlap[i]
  /// where maxIncomingOverlap is the best-case overlap with any other word.
  /// Precomputed for fast summing during pruning.
  final List<int> minContribution;

  IndexedWordList._(
    this.nodes,
    this.successorIndices,
    this.initialInDegree,
    this.initialEligibleMask,
    this.wordLengths,
    this.minContribution,
  );

  /// Build an IndexedWordList from a dependency graph.
  ///
  /// Sorts words by (rank, length) and pre-computes metadata.
  factory IndexedWordList.build(WordDependencyGraph graph) {
    final allNodes = graph.allNodes;

    // Compute ranks for sorting
    final ranks = graph.computeRanks();

    // Sort all nodes by (rank, length desc) - this way iterating bits in order
    // processes lower ranks first, and within each rank, longer words first
    allNodes.sort((a, b) {
      final rankCmp = ranks[a]!.compareTo(ranks[b]!);
      if (rankCmp != 0) return rankCmp;
      return b.cellCodes.length.compareTo(a.cellCodes.length); // longer first
    });

    // Map node -> index for quick lookup (after sorting!)
    final nodeIndex = <WordNode, int>{};
    for (int i = 0; i < allNodes.length; i++) {
      nodeIndex[allNodes[i]] = i;
    }

    // Pre-compute successor indices for each node
    final successorIndices = <List<int>>[];
    for (final node in allNodes) {
      final succs = graph.edges[node] ?? <WordNode>{};
      successorIndices.add(succs.map((s) => nodeIndex[s]!).toList());
    }

    // Compute initial in-degree for each node (count of predecessors)
    final inDegree = List<int>.filled(allNodes.length, 0);
    for (final entry in graph.edges.entries) {
      for (final succ in entry.value) {
        inDegree[nodeIndex[succ]!]++;
      }
    }

    // Initial eligible mask: nodes with in-degree 0 (no predecessors)
    int eligibleMask = 0;
    for (int i = 0; i < allNodes.length; i++) {
      if (inDegree[i] == 0) {
        eligibleMask |= (1 << i);
      }
    }

    // Pre-compute word lengths for fast lookup during pruning
    final wordLengths = allNodes.map((n) => n.cellCodes.length).toList();

    // Pre-compute maximum incoming overlap for each word.
    // For word i, this is the max overlap where i's prefix matches
    // any other word j's suffix (j placed before i).
    final maxIncomingOverlap = computeMaxIncomingOverlaps(allNodes);

    // Pre-compute minimum contribution (cells beyond overlap) for each word
    final minContribution = List<int>.generate(
      allNodes.length,
      (i) => wordLengths[i] - maxIncomingOverlap[i],
    );

    return IndexedWordList._(
      allNodes,
      successorIndices,
      inDegree,
      eligibleMask,
      wordLengths,
      minContribution,
    );
  }

  /// Compute maximum overlap for each word when placed after any other word.
  ///
  /// For word i, finds the longest prefix of i that matches any suffix of
  /// any other word j. This represents the best-case overlap when placing i.
  ///
  /// @visibleForTesting
  static List<int> computeMaxIncomingOverlaps(List<WordNode> nodes) {
    final n = nodes.length;
    final maxOverlap = List<int>.filled(n, 0);

    for (int i = 0; i < n; i++) {
      final codesI = nodes[i].cellCodes;
      final lenI = codesI.length;

      // Check against all other words j (j comes before i)
      for (int j = 0; j < n; j++) {
        if (i == j) continue;

        final codesJ = nodes[j].cellCodes;
        final lenJ = codesJ.length;

        // Find longest suffix of j that matches prefix of i
        // Try overlap lengths from min(lenI, lenJ) down to 1
        final maxPossibleOverlap = lenI < lenJ ? lenI : lenJ;
        for (
          int overlap = maxPossibleOverlap;
          overlap > maxOverlap[i];
          overlap--
        ) {
          // Check if last 'overlap' chars of j match first 'overlap' chars of i
          bool matches = true;
          for (int k = 0; k < overlap; k++) {
            if (codesJ[lenJ - overlap + k] != codesI[k]) {
              matches = false;
              break;
            }
          }
          if (matches) {
            maxOverlap[i] = overlap;
            break; // Found best overlap for this j, try next j
          }
        }
      }
    }

    return maxOverlap;
  }

  /// Number of nodes in the graph
  int get length => nodes.length;
}
