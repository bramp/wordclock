
import 'dart:collection';
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
  for (final arg in args) {
    if (arg.startsWith('--seed=')) {
      seed = int.tryParse(arg.substring(7));
    }
    if (arg.startsWith('--width=')) {
      final w = int.tryParse(arg.substring(8));
      if (w != null) gridWidth = w;
    }
  }
  
  // Initialize Random
  final Random random = seed != null ? Random(seed) : Random(0);

  // 1. SCAN & BUILD GRAPH
  final graph = _buildDependencyGraph();
  
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
      other is Node && runtimeType == other.runtimeType && word == other.word && index == other.index;

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

  // Scan 24 Hours
  for (int h = 0; h < 24; h++) {
    for (int m = 0; m < 60; m++) {
      final time = DateTime(2025, 1, 1, h, m);
      final phrase = TimeToWords.convert(time);
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
  final Map<Node, int> levels = {};
  
  // Helper to compute depth
  int getDepth(Node n, Set<Node> visitedStack) {
    if (levels.containsKey(n)) return levels[n]!;
    
    // Cycle check (shouldn't happen if graph is clean, but good for safety)
    if (visitedStack.contains(n)) throw Exception("Cycle detected during level sort: $n");
    visitedStack.add(n);
    
    int maxParentDepth = -1;
    
    // Find all parents (nodes that point TO n)
    // Graph is Map<Node, Set<Node>> (Adjacency List: From -> To).
    // This is inefficient to find parents. We should inverse the graph or pass it.
    // Actually, simple recursion: Depth(n) = 1 + Max(Depth(children))?
    // No, Depth(n) = 1 + Max(Depth(parents)).
    
    // Since our Graph structure is From->To, calculating "Longest Path from Source" is best done via DP forward pass?
    // Or standard topological traversal.
    
    visitedStack.remove(n);
    return 0; // Placeholder
  }

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

void _generateGrid(int width, List<Node> orderedResult, Graph graph, int? seed, Random random) {
  final buffer = StringBuffer();
  
  int currentIndex = 0;
  String currentRow = "";
  Node? prevNode;
  
  for (final node in orderedResult) {
    final wordStr = node.word; 

    // Determine if padding is required due to direct dependency
    bool needsPadding = false;
    if (prevNode != null && graph[prevNode]?.contains(node) == true) {
      needsPadding = true;
    }

    // Calculate space needed (Word + optional Padding)
    int spaceNeeded = wordStr.length + (needsPadding ? 1 : 0);

    // Check fit
    if (currentRow.length + spaceNeeded > width) {
      // Wrap to next line
      final paddingNeeded = width - currentRow.length;
      final padding = _generatePadding(paddingNeeded, random);
      buffer.write(currentRow + padding);
      currentIndex += paddingNeeded;
      
      currentRow = "";
      
      if (needsPadding && paddingNeeded == 0) {
        currentRow += _generatePadding(1, random);
        currentIndex += 1;
      }
    } else {
      // Fits on same line
      if (needsPadding) {
        currentRow += _generatePadding(1, random);
        currentIndex += 1;
      }
    }
    
    if (wordStr.length > width) {
       print('ERROR: $wordStr is too wide ($width)');
       return;
    }
    
    currentRow += wordStr;
    currentIndex += wordStr.length;
    prevNode = node;
  }
  
  // Flush
  if (currentRow.isNotEmpty) {
    final paddingNeeded = width - currentRow.length;
    final padding = _generatePadding(paddingNeeded, random);
    buffer.write(currentRow + padding);
  }
  
  final gridString = buffer.toString();
  final height = gridString.length ~/ width;
  
  print('\n/// AUTOMATICALLY GENERATED PREVIEW');
  print('/// Seed: ${seed ?? "Deterministic (0)"}');
  print('static final english${width}x$height = GridDefinition(');
  print('  width: $width,');
  print('  height: $height,');
  print('  letters:');
  for (int i = 0; i < height; i++) {
     print("    '${gridString.substring(i * width, (i + 1) * width)}'");
  }
  
  print('    ,');
  print('  vocabulary: const [');
  for (final node in orderedResult) {
    print('    "${node.word}",');
  }
  print('  ],');
  print(');');
}

String _generatePadding(int length, Random random) {
  const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
}
