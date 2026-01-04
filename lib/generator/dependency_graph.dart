import 'dart:collection';
import 'package:wordclock/generator/graph_types.dart';
import 'package:wordclock/generator/utils/word_clock_utils.dart';
import 'package:wordclock/languages/language.dart';

class DependencyGraphBuilder {
  static Graph build({required WordClockLanguage language}) {
    final Graph graph = {};

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

    // 1. Pre-collect units (either words or characters) from all phrases
    final Set<String> allUnits = {};
    if (language.atomizePhrases) {
      // Treat every unique character as a unit
      WordClockUtils.forEachTime(language, (time, phrase) {
        for (int i = 0; i < phrase.length; i++) {
          if (phrase[i] != ' ') {
            allUnits.add(phrase[i]);
          }
        }
      });
    } else {
      allUnits.addAll(WordClockUtils.collectAllWords(language));
    }

    // 2. Sort by length descending to maximize sub-string reuse
    final sortedUnits = allUnits.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    // 3. Cache for unit nodes: unit -> list of versions (each version is a list of nodes)
    final Map<String, List<List<Node>>> unitCache = {};

    List<Node> createNewUnitNodes(String unit, int retryIndex) {
      return List.generate(
        unit.length,
        (i) => Node(
          unit[i],
          unit,
          i,
          getGlobalIndex(unit[i], unit, i, retryIndex),
        ),
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

    // 4. Initialize cache with longest units first to allow sub-string reuse
    for (final unit in sortedUnits) {
      bool found = false;
      for (final entry in unitCache.entries) {
        final cachedUnit = entry.key;
        final index = cachedUnit.indexOf(unit);
        if (index != -1) {
          // Reuse the first version of the cached unit
          unitCache[unit] = [
            entry.value.first.sublist(index, index + unit.length),
          ];
          found = true;
          break;
        }
      }
      if (!found) {
        final nodes = createNewUnitNodes(unit, 0);
        unitCache[unit] = [nodes];
        ensureInternalEdges(nodes);
      }
    }

    // 5. Build the graph by linking units in phrases
    WordClockUtils.forEachTime(language, (time, phrase) {
      List<String> units;
      if (language.atomizePhrases) {
        units = phrase.split('').where((c) => c != ' ').toList();
      } else {
        units = phrase.split(' ').where((w) => w.isNotEmpty).toList();
      }

      Node? prevNode;

      for (final unit in units) {
        // Find a version of this unit that doesn't create a cycle
        List<Node>? selectedNodes;
        for (final version in unitCache[unit]!) {
          if (prevNode == null ||
              !_pathExists(graph, version.first, prevNode)) {
            selectedNodes = version;
            break;
          }
        }

        if (selectedNodes == null) {
          // Create a new version (retry)
          int retryIndex = unitCache[unit]!.length;
          selectedNodes = createNewUnitNodes(unit, retryIndex);
          unitCache[unit]!.add(selectedNodes);
          ensureInternalEdges(selectedNodes);
        }

        // Link prevNode to the start of the unit
        if (prevNode != null) {
          graph[prevNode]!.add(selectedNodes.first);
        }
        prevNode = selectedNodes.last;
      }
    });

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
