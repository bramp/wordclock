import 'dart:collection';
import 'package:wordclock/generator/graph_types.dart';
import 'package:wordclock/languages/language.dart';

class DependencyGraphBuilder {
  static Graph build({required WordClockLanguage language}) {
    final Graph graph = {};
    final timeConverter = language.timeToWords;
    final increment = language.minuteIncrement;

    // Scan 24 Hours
    for (int h = 0; h < 24; h++) {
      for (int m = 0; m < 60; m += increment) {
        final time = DateTime(2025, 1, 1, h, m);
        final phrase = timeConverter.convert(time);
        final rawWords = phrase.split(' ');

        Node? prevNode;

        // Track occurrences within THIS sentence
        final Map<String, int> sentenceCounts = {};

        for (final word in rawWords) {
          if (word.isEmpty) continue;
          // 1. Determine minimum allowed index based on occurrences in THIS sentence
          // 0-based indexing: 1st word k=0. 2nd k=1.
          int count = sentenceCounts[word] ?? 0;
          sentenceCounts[word] = count + 1;

          // 2. Find a valid Global Node for this word
          // We initially try to use the Local Index (k-th occurrence in this sentence) as the Global Index.
          // e.g. 1st "FIVE" -> Node("FIVE", 0).
          //
          // However, this might create a cycle if the same Node ID is used for conflicting concepts.
          // Example:
          //  - "FIVE PAST..." uses Node("FIVE", 0) for Minute 5.
          //  - "...HALF PAST FIVE" uses Node("FIVE", 0) for Hour 5.
          //  - Dependencies: FIVE(Min) -> PAST -> FIVE(Hr).
          //  - If both are Node("FIVE", 0), we get FIVE_0 -> PAST -> FIVE_0 (Cycle!).
          //
          // Resolution: We check for cycles. If Node("FIVE", 0) is invalid, we bump to Node("FIVE", 1), etc.
          Node candidate;
          int candidateIndex = count;

          while (true) {
            candidate = Node(word, candidateIndex);

            if (prevNode != null) {
              // If this specific edge (prev -> candidate) already exists, it's valid.
              if (graph[prevNode]?.contains(candidate) == true) {
                break;
              }

              // Check if adding this edge closes a loop (Cycle Detection)
              if (_pathExists(graph, candidate, prevNode)) {
                // Cycle detected! The candidate Global Node is "upstream" of prevNode.
                // This implies 'candidate' is conceptually distinct from the node we picked.
                // Try the next available Global Index.
                candidateIndex++;
                continue;
              }
            }
            break;
          }

          // 3. Commit to Graph
          if (!graph.containsKey(candidate)) graph[candidate] = {};
          if (prevNode != null) {
            if (!graph.containsKey(prevNode)) graph[prevNode] = {};
            graph[prevNode]!.add(candidate);
          }
          prevNode = candidate;
        }
      }
    }
    return graph;
  }

  /// BFS to check if 'target' is reachable from 'start'
  static bool _pathExists(Graph graph, Node start, Node target) {
    if (start == target) return true;
    final Queue<Node> queue = Queue()..add(start);
    final Set<Node> visited = {start};

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      if (current == target) return true;
      final neighbors = graph[current];
      if (neighbors != null) {
        for (final n in neighbors) {
          if (visited.add(n)) queue.add(n);
        }
      }
    }
    return false;
  }
}
