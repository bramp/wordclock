import 'dart:collection';
import 'package:wordclock/generator/graph_types.dart';
import 'package:wordclock/languages/language.dart';

class DependencyGraphBuilder {
  static Graph build({required WordClockLanguage language}) {
    final Graph graph = {};
    final timeConverter = language.timeToWords;
    final increment = language.minuteIncrement;

    // Global character counts to keep Node indices unique but stable
    final Map<String, int> charCounts = {};
    final Map<String, int> assignedIndices = {};

    int getGlobalIndex(
      String char,
      String word,
      int charIndex,
      int retryIndex,
    ) {
      final key = '$char-$word-$charIndex-$retryIndex';
      if (!assignedIndices.containsKey(key)) {
        int idx = charCounts[char] ?? 0;
        charCounts[char] = idx + 1;
        assignedIndices[key] = idx;
      }
      return assignedIndices[key]!;
    }

    // 1. Pre-collect all unique words from all possible phrases
    final Set<String> allWords = {};
    for (int h = 0; h < 24; h++) {
      for (int m = 0; m < 60; m += increment) {
        final time = DateTime(2025, 1, 1, h, m);
        final phrase = timeConverter.convert(time);
        allWords.addAll(phrase.split(' ').where((w) => w.isNotEmpty));
      }
    }

    // 2. Sort by length descending to maximize sub-string reuse
    final sortedWords = allWords.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    // 3. Cache for word nodes: word -> list of versions (each version is a list of nodes)
    final Map<String, List<List<Node>>> wordCache = {};

    List<Node> createNewWordNodes(String word, int retryIndex) {
      return List.generate(
        word.length,
        (i) =>
            Node(word[i], word, getGlobalIndex(word[i], word, i, retryIndex)),
      );
    }

    void ensureInternalEdges(List<Node> nodes) {
      for (int i = 0; i < nodes.length - 1; i++) {
        graph.putIfAbsent(nodes[i], () => {});
        graph.putIfAbsent(nodes[i + 1], () => {});
        graph[nodes[i]]!.add(nodes[i + 1]);
      }
      if (nodes.isNotEmpty) {
        graph.putIfAbsent(nodes.last, () => {});
      }
    }

    // 4. Initialize cache with longest words first to allow sub-string reuse
    for (final word in sortedWords) {
      bool found = false;
      for (final entry in wordCache.entries) {
        final cachedWord = entry.key;
        final index = cachedWord.indexOf(word);
        if (index != -1) {
          // Reuse the first version of the cached word
          wordCache[word] = [
            entry.value.first.sublist(index, index + word.length),
          ];
          found = true;
          break;
        }
      }
      if (!found) {
        final nodes = createNewWordNodes(word, 0);
        wordCache[word] = [nodes];
        ensureInternalEdges(nodes);
      }
    }

    // 5. Build the graph by linking words in phrases
    for (int h = 0; h < 24; h++) {
      for (int m = 0; m < 60; m += increment) {
        final time = DateTime(2025, 1, 1, h, m);
        final phrase = timeConverter.convert(time);

        final words = phrase.split(' ').where((w) => w.isNotEmpty).toList();
        Node? prevNode;

        for (final word in words) {
          // Find a version of this word that doesn't create a cycle
          List<Node>? selectedNodes;
          for (final version in wordCache[word]!) {
            if (prevNode == null ||
                !_pathExists(graph, version.first, prevNode)) {
              selectedNodes = version;
              break;
            }
          }

          if (selectedNodes == null) {
            // Create a new version (retry)
            int retryIndex = wordCache[word]!.length;
            selectedNodes = createNewWordNodes(word, retryIndex);
            wordCache[word]!.add(selectedNodes);
            ensureInternalEdges(selectedNodes);
          }

          // Link prevNode to the start of the word
          if (prevNode != null) {
            graph[prevNode]!.add(selectedNodes.first);
          }
          prevNode = selectedNodes.last;
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
        for (final neighbor in neighbors) {
          if (visited.add(neighbor)) queue.add(neighbor);
        }
      }
    }
    return false;
  }
}
