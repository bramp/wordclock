import 'dart:collection';
// ignore_for_file: avoid_print
import 'dart:math';
import 'package:wordclock/logic/time_to_words.dart';

/// SMART GRID GENERATOR
///
/// 1. Scans Logic to find all used Words.
/// 2. Builds a Dependency Graph.
/// 3. Topologically Sorts using simple (Word, Count) tuples.
/// 4. Generates the Grid.

void main(List<String> args) {
  int gridWidth = 11; // Default

  // Parse args
  int? seed;
  bool showDot = false;
  for (final arg in args) {
    if (arg.startsWith('--seed=')) {
      seed = int.tryParse(arg.substring(7));
    }
    if (arg.startsWith('--width=')) {
      final w = int.tryParse(arg.substring(8));
      if (w != null) gridWidth = w;
    }
    if (arg == '--dot') {
      showDot = true;
    }
  }

  // Initialize Random
  final Random random = seed != null ? Random(seed) : Random(0);

  // 1. SCAN & BUILD GRAPH
  final graph = _buildDependencyGraph();

  if (showDot) {
    _printDotUrl(graph);
    return;
  }

  // 2. TOPOLOGICAL SORT
  List<Node> sortedNodes;
  try {
    sortedNodes = _topologicalSort(graph, seed: seed);
  } catch (e) {
    print('ERROR: Cycle detected! $e');
    return;
  }

  // 3. GENERATE GRID
  _generateGrid(gridWidth, sortedNodes, graph, seed, random);
}

class Node {
  final String word;
  final int index; // 0-based occurrence index

  const Node(this.word, this.index);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Node &&
          runtimeType == other.runtimeType &&
          word == other.word &&
          index == other.index;

  @override
  int get hashCode => word.hashCode ^ index.hashCode;

  @override
  String toString() => '${word}_$index';
}

typedef Graph = Map<Node, Set<Node>>;

Graph _buildDependencyGraph() {
  final Graph graph = {};

  // Cache to check if a node has been created in the graph
  // We use the graph keys as the definitive set of existing nodes.

  final converter = EnglishTimeToWords();

  // Scan 24 Hours
  for (int h = 0; h < 24; h++) {
    for (int m = 0; m < 60; m++) {
      final time = DateTime(2025, 1, 1, h, m);
      final phrase = converter.convert(time);
      final rawWords = phrase.split(' ');

      Node? prevNode;

      // Track occurrences within THIS sentence
      final Map<String, int> sentenceCounts = {};

      for (final word in rawWords) {
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
bool _pathExists(Graph graph, Node start, Node target) {
  if (start == target) return true;

  final Queue<Node> queue = Queue()..add(start);
  final Set<Node> visited = {start};

  while (queue.isNotEmpty) {
    final current = queue.removeFirst();
    if (current == target) return true;

    final neighbors = graph[current];
    if (neighbors != null) {
      for (final n in neighbors) {
        if (visited.add(n)) {
          queue.add(n);
        }
      }
    }
  }
  return false;
}

List<Node> _topologicalSort(Graph graph, {int? seed}) {
  // 1. Calculate 'Level' for each node.
  // Level = Length of longest path from any source to this node.
  // This ensures that if A -> B, Level(B) > Level(A).
  // So sorting by Level guarantees Topological Order.

  // Memoization for depth

  // Actually, Kahn's algorithm yields layers naturally!
  // Layer 0: Initial In-Degree 0.
  // Layer 1: Nodes that become In-Degree 0 after removing Layer 0.
  // ...

  // Let's implement Layered Kahn's.

  final Map<Node, int> inDegree = {};
  for (var node in graph.keys) {
    inDegree[node] = 0;
  }
  for (var edges in graph.values) {
    for (var neighbor in edges) {
      inDegree[neighbor] = (inDegree[neighbor] ?? 0) + 1;
    }
  }

  final List<Node> orderedResult = [];
  final Random? random = seed != null ? Random(seed) : null;

  // Current Layer: All nodes with In-Degree 0
  List<Node> currentLayer = [];
  inDegree.forEach((node, degree) {
    if (degree == 0) currentLayer.add(node);
  });

  while (currentLayer.isNotEmpty) {
    // 1. Shuffle CURRENT Layer
    // Since these nodes have no dependencies among themselves (all in-degree 0 at this step),
    // and no remaining dependencies on unvisited nodes, their relative order DOES NOT MATTER.
    currentLayer.sort((a, b) => a.word.compareTo(b.word)); // Deterministic
    if (random != null) {
      currentLayer.shuffle(random);
    }

    // 2. Add to result
    orderedResult.addAll(currentLayer);

    // 3. Process children to find NEXT Layer
    final List<Node> nextLayer = [];

    for (final node in currentLayer) {
      final neighbors = graph[node];
      if (neighbors != null) {
        for (final neighbor in neighbors) {
          inDegree[neighbor] = inDegree[neighbor]! - 1;
          if (inDegree[neighbor] == 0) {
            nextLayer.add(neighbor);
          }
        }
      }
    }

    currentLayer = nextLayer;
  }

  if (orderedResult.length != graph.length) {
    throw Exception("Graph sequence cycle detected during sort.");
  }

  return orderedResult;
}

void _generateGrid(
  int width,
  List<Node> orderedResult,
  Graph graph,
  int? seed,
  Random random,
) {
  final buffer = StringBuffer();

  // We accumulate words for a single line, then flush them with distributed padding.
  List<String> currentLineWords = [];
  int currentLineLength = 0;

  // Track previous node to determine required padding betweeen words
  Node? prevNode;

  // Identify special "pinned" nodes
  // Note: We assume the first node is top-left and last is bottom-right based on topological sort/input
  final Node firstNode = orderedResult.first;
  final Node lastNode = orderedResult.last;

  void flushLine({required bool isLastLine}) {
    if (currentLineWords.isEmpty) return;

    final int paddingTotal = width - currentLineLength;
    String line = "";

    // 1. PIN TOP-LEFT: If this line contains the very first node (IT), padding goes at the END.
    if (currentLineWords.contains(firstNode.word) &&
        currentLineWords.first == firstNode.word) {
      // Ideally check if it's strictly the first item, which it should be.
      line = currentLineWords.join("");
      line += _generatePadding(paddingTotal, random);
    }
    // 2. PIN BOTTOM-RIGHT: If this is the LAST line and contains the last node, padding goes at the START.
    else if (isLastLine && currentLineWords.contains(lastNode.word)) {
      // Verify it's actually the last node of the list
      line = _generatePadding(paddingTotal, random);
      line += currentLineWords.join("");
    }
    // 3. RANDOM SCATTER: Randomly split padding before and after
    else {
      // Split padding randomly
      final int paddingBefore = random.nextInt(paddingTotal + 1);
      final int paddingAfter = paddingTotal - paddingBefore;

      line += _generatePadding(paddingBefore, random);
      line += currentLineWords.join("");
      line += _generatePadding(paddingAfter, random);
    }

    buffer.write(line);

    // Clear for next line
    currentLineWords = [];
    currentLineLength = 0;
  }

  for (int i = 0; i < orderedResult.length; i++) {
    final node = orderedResult[i];
    final wordStr = node.word;

    // Determine if padding is required due to direct dependency
    // If A->B, we need at least 1 padding char if they are on the same line?
    // Actually, generic padding is just filling the grid.
    // The requirement "padding ... within the line" suggests we might split padding between words too,
    // but the user said "distribute the padding within the line", which often means around the block of words.
    // Let's stick to placing the block of words together for readability, but shifting that block left/right/center randomly.
    // Splitting words apart with padding makes them hard to read (e.g. T W E N T Y).
    // EXCEPT if we need a required separator.

    bool needsSeparator = false;
    if (prevNode != null && graph[prevNode]?.contains(node) == true) {
      needsSeparator = true;
    }

    // Calculate space needed (Word + separator)
    int spaceNeeded = wordStr.length + (needsSeparator ? 1 : 0);

    // Check fit
    if (currentLineLength + spaceNeeded > width) {
      // Flush current line
      flushLine(isLastLine: false);
    }

    // Add separator if needed and not start of line
    if (currentLineWords.isNotEmpty && needsSeparator) {
      // We add 'separator' as a 1-char padding string to the list of words for simplicity
      // or just account for it in length and append strictly.
      // Actually, easiest is to append a padding char to the PREVIOUS word or START of CURRENT word.
      // Let's add independent random character as a "word"
      currentLineWords.add(_generatePadding(1, random));
      currentLineLength += 1;
    }

    currentLineWords.add(wordStr);
    currentLineLength += wordStr.length;

    prevNode = node;

    if (wordStr.length > width) {
      print('ERROR: $wordStr is too wide ($width)');
      return;
    }
  }

  // Flush remaining
  flushLine(isLastLine: true);

  final gridString = buffer.toString();
  final height = gridString.length ~/ width;

  print('\n/// AUTOMATICALLY GENERATED PREVIEW');
  print('/// Seed: ${seed ?? "Deterministic (0)"}');
  print('static final english${width}x$height = WordGrid(');
  print('  width: $width,');
  print('  letters:');
  for (int i = 0; i < height; i++) {
    print("    '${gridString.substring(i * width, (i + 1) * width)}'");
  }
  print('    ,');
  print('    timeConverter: EnglishTimeToWords(),');
  print(');');
}

String _generatePadding(int length, Random random) {
  // English Letter Frequency (Roughly)
  const String frequencyString =
      "EEEEEEEEEEE" // 11
      "AAAAAAAA" // 8
      "RRRRRR" // 6
      "IIIIII" // 6
      "OOOOOO" // 6
      "TTTTTT" // 6
      "NNNNN" // 5
      "SSSS" // 4
      "LLLL" // 4
      "CCCC" // 3
      "UUU" // 3
      "DDD" // 3
      "PPP" // 3
      "MMM" // 3
      "HHH" // 3
      "G"
      "B"
      "F"
      "Y"
      "W"
      "K"
      "V"
      "X"
      "Z"
      "J"
      "Q";

  return List.generate(
    length,
    (index) => frequencyString[random.nextInt(frequencyString.length)],
  ).join();
}

void _printDotUrl(Graph graph) {
  final dotContent = _generateDot(graph);
  final encoded = Uri.encodeComponent(dotContent);
  print('https://dreampuf.github.io/GraphvizOnline/#$encoded');
}

String _generateDot(Graph graph) {
  // Pre-calculate word frequencies to determine if index is needed
  final wordCounts = <String, int>{};
  for (final node in graph.keys) {
    wordCounts[node.word] = (wordCounts[node.word] ?? 0) + 1;
  }

  String nodeName(Node node) {
    return wordCounts[node.word]! > 1 ? node.toString() : node.word;
  }

  String quote(String s) {
    // Only quote if necessary (simplified check for our known domain)
    if (RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(s)) {
      return s;
    }
    return '"$s"';
  }

  final buffer = StringBuffer();
  buffer.writeln('digraph WordClock {');
  buffer.writeln('  rankdir=LR;');
  buffer.writeln('  node [shape=box, fontname="Helvetica"];');

  // Sort keys for deterministic output
  final sortedNodes = graph.keys.toList()
    ..sort((a, b) => a.toString().compareTo(b.toString()));

  for (final node in sortedNodes) {
    final edges = graph[node];

    // Only show index if there are multiple occurrences of this word
    final label = wordCounts[node.word]! > 1
        ? '${node.word} (${node.index})'
        : node.word;

    final id = quote(nodeName(node));

    // Print the node definition for clarity
    buffer.writeln('  $id [label="$label"];');

    if (edges != null && edges.isNotEmpty) {
      final sortedEdges = edges.toList()
        ..sort((a, b) => a.toString().compareTo(b.toString()));

      for (final child in sortedEdges) {
        final childId = quote(nodeName(child));
        buffer.writeln('  $id->$childId;');
      }
    }
  }
  buffer.writeln('}');
  return buffer.toString();
}
