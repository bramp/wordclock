import 'dart:collection';
import 'package:wordclock/generator/greedy/graph_types.dart';
import 'package:wordclock/generator/utils/word_clock_utils.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';

/// A builder that constructs a directed acyclic graph (DAG) representing the
/// dependencies between characters in a word clock's phrases.
///
/// ### Atoms vs. Cells
/// - A **cell** is the atomic unit of the grid. While usually a single character,
///   it can be a multi-character sequence (e.g., O' for O'Clock) that occupies
///   a single position in the grid.
/// - An **atom** is the unit of tokenization (returned by [WordClockLanguage.tokenize]).
///   It is the smallest block that the layout engine will not split across lines.
///   Depending on the language configuration:
///   - If `atomizePhrases` is false (default), an atom is a **word** (e.g., "TEN").
///   - If `atomizePhrases` is true, an atom is a **single cell** (e.g., "T").
///
/// An atom always consists of one or more cells.
///
/// The graph ensures that characters within a word are linked sequentially,
/// and words within a phrase are linked in order. It also attempts to reuse
/// character nodes (substrings) across different words to minimize the total
/// number of cells in the final grid.
class DependencyGraphBuilder {
  /// Builds a [Graph] for the given [language].
  ///
  /// The process involves:
  /// 1. Collecting all unique words (atoms) from the language's phrases.
  /// 2. Sorting atoms by length to maximize substring reuse (e.g., "TEN" inside "SEVENTEEN").
  /// 3. Creating [Node]s for each character/cell in the atoms.
  /// 4. Linking nodes within atoms and between atoms in phrases.
  /// 5. Handling potential cycles by creating "retry" versions of atoms if a path already exists.
  ///
  /// Example:
  /// ```dart
  /// final graph = DependencyGraphBuilder.build(language: English());
  /// ```
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

    // 1. Pre-collect atoms (either words or characters) from all phrases
    final Set<String> allAtoms = WordClockUtils.getAllWords(language);

    // 2. Sort by length descending to maximize sub-string reuse
    final sortedAtoms = allAtoms.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    // 3. Cache for atom nodes: atom -> list of versions (each version is a list of nodes)
    final Map<String, List<List<Node>>> atomCache = {};
    final Map<String, List<String>> atomCellsCache = {};

    List<String> getCells(String atom) =>
        atomCellsCache.putIfAbsent(atom, () => WordGrid.splitIntoCells(atom));

    List<Node> createNodesFromCells(
      List<String> cells,
      int retryIndex, {
      int offset = 0,
      required String word,
    }) {
      return List.generate(
        cells.length,
        (i) => Node(
          cells[i],
          word,
          i + offset,
          getGlobalIndex(cells[i], word, i + offset, retryIndex),
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

    // 4. Initialize cache with longest atoms first to allow sub-string reuse
    for (final atom in sortedAtoms) {
      final atomCells = getCells(atom);
      bool found = false;

      // 4.1. Full substring reuse
      for (final entry in atomCache.entries) {
        final cachedCells = getCells(entry.key);
        final cachedNodes = entry.value.first;

        // Find atomCells in cachedCells
        for (int i = 0; i <= cachedCells.length - atomCells.length; i++) {
          bool match = true;
          for (int j = 0; j < atomCells.length; j++) {
            if (cachedCells[i + j] != atomCells[j]) {
              match = false;
              break;
            }
          }
          if (match) {
            atomCache[atom] = [cachedNodes.sublist(i, i + atomCells.length)];
            found = true;
            break;
          }
        }
        if (found) break;
      }
      if (found) continue;

      /*
      // 4.2. Prefix/Suffix overlap reuse
      for (final entry in atomCache.entries) {
        final cachedCells = getCells(entry.key);
        final cachedNodes = entry.value.first;

        // Longest overlap first
        for (int len = min(cachedCells.length, atomCells.length) - 1;
            len > 0;
            len--) {
          bool match = true;
          for (int i = 0; i < len; i++) {
            if (cachedCells[cachedCells.length - len + i] != atomCells[i]) {
              match = false;
              break;
            }
          }

          if (match) {
            final overlapNodes = cachedNodes.sublist(cachedCells.length - len);
            final remainingCells = atomCells.sublist(len);
            final remainingNodes = createNodesFromCells(
              remainingCells,
              0,
              offset: len,
              word: atom,
            );
            final allNodes = [...overlapNodes, ...remainingNodes];
            atomCache[atom] = [allNodes];
            ensureInternalEdges(allNodes);
            found = true;
            break;
          }
        }
        if (found) break;
      }
      */

      if (!found) {
        final nodes = createNodesFromCells(atomCells, 0, word: atom);
        atomCache[atom] = [nodes];
        ensureInternalEdges(nodes);
      }
    }

    // 5. Build the graph by linking atoms in phrases
    WordClockUtils.forEachTime(language, (time, phrase) {
      final atoms = language.tokenize(phrase);
      Node? prevNode;

      for (final atom in atoms) {
        // Find a version of this atom that doesn't create a cycle
        List<Node>? selectedNodes;
        for (final version in atomCache[atom]!) {
          if (prevNode == null ||
              !_pathExists(graph, version.first, prevNode)) {
            selectedNodes = version;
            break;
          }
        }

        if (selectedNodes == null) {
          // Create a new version (retry)
          int retryIndex = atomCache[atom]!.length;
          selectedNodes = createNodesFromCells(
            getCells(atom),
            retryIndex,
            word: atom,
          );
          atomCache[atom]!.add(selectedNodes);
          ensureInternalEdges(selectedNodes);
        }

        // Link prevNode to the start of the atom
        if (prevNode != null) {
          graph[prevNode]!.add(selectedNodes.first);
        }
        prevNode = selectedNodes.last;
      }
    });

    return graph;
  }

  /// Checks if a path exists from [start] to [target] using Breadth-First Search.
  ///
  /// This is used to prevent cycles when linking atoms in the graph. If a path
  /// already exists from the current atom to the previous one, adding an edge
  /// from previous to current would create a cycle.
  ///
  /// Example:
  /// ```dart
  /// bool cycle = _pathExists(graph, nextNode, prevNode);
  /// ```
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
