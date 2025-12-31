
import 'dart:collection';
import 'dart:math';
import 'package:wordclock/logic/time_to_words.dart';
// Note: We don't need WordType anymore, just Strings.

/// SMART GRID GENERATOR
/// 
/// 1. Scans Logic to find all used Words.
/// 2. Builds a Dependency Graph.
/// 3. Topologically Sorts.
/// 4. Generates the Grid.
void main() {
  const int gridWidth = 11;
  const int gridHeight = 10;
  
  // 1. SCAN & BUILD GRAPH
  final graph = _buildDependencyGraph();
  
  // 2. TOPOLOGICAL SORT
  List<String> sortedMetadata;
  try {
     sortedMetadata = _topologicalSort(graph);
  } catch (e) {
    print('ERROR: Cycle detected! $e');
    return;
  }

  print('// Optimized Order found: $sortedMetadata');

  // 3. GENERATE GRID
  _generateGrid(gridWidth, sortedMetadata);
}


typedef Graph = Map<String, Set<String>>;

Graph _buildDependencyGraph() {
  final Graph graph = {};
  final Set<String> allWords = {};

  // Scan 24 Hours
  for (int h = 0; h < 24; h++) {
    for (int m = 0; m < 60; m++) {
      final time = DateTime(2025, 1, 1, h, m);
      final phrase = TimeToWords.convert(time);
      final words = phrase.split(' ');
      
      allWords.addAll(words);
      
      // Add edges
      for (int i = 0; i < words.length - 1; i++) {
        final current = words[i];
        final next = words[i + 1];
        
        if (!graph.containsKey(current)) graph[current] = {};
        graph[current]!.add(next);
      }
      // Ensure last word is in graph too
      if (words.isNotEmpty) {
        if (!graph.containsKey(words.last)) graph[words.last] = {};
      }
    }
  }
  
  return graph;
}

List<String> _topologicalSort(Graph graph) {
  // Kahn's Algorithm
  final Map<String, int> inDegree = {};
  for (var node in graph.keys) {
    inDegree[node] = 0;
  }
  
  for (var edges in graph.values) {
    for (var neighbor in edges) {
      inDegree[neighbor] = (inDegree[neighbor] ?? 0) + 1;
    }
  }
  
  final Queue<String> queue = Queue();
  inDegree.forEach((node, degree) {
    if (degree == 0) queue.add(node);
  });
  
  // Sort queue initially for deterministic output?
  // queue is not sortable easily, but we can process in alphabetical order if tied?
  
  final List<String> result = [];
  
  while (queue.isNotEmpty) {
    final current = queue.removeFirst();
    result.add(current);
    
    if (graph[current] != null) {
      for (var neighbor in graph[current]!) {
        inDegree[neighbor] = inDegree[neighbor]! - 1;
        if (inDegree[neighbor] == 0) {
          queue.add(neighbor);
        }
      }
    }
  }
  
  if (result.length != graph.length) {
    throw Exception("Graph sequence cycle detected. $result");
  }
  
  return result;
}

void _generateGrid(int width, List<String> sortedVocab) {
  final buffer = StringBuffer();
  
  int currentIndex = 0;
  String currentRow = "";
  
  for (final wordStr in sortedVocab) {
    // Check fit
    if (currentRow.length + wordStr.length > width) {
      // Pad
      final paddingNeeded = width - currentRow.length;
      final padding = _generatePadding(paddingNeeded);
      buffer.write(currentRow + padding);
      currentIndex += paddingNeeded;
      currentRow = "";
    }
    
    if (wordStr.length > width) {
       print('ERROR: $wordStr is too wide ($width)');
       return;
    }
    
    currentRow += wordStr;
    currentIndex += wordStr.length;
  }
  
  // Flush
  if (currentRow.isNotEmpty) {
    final paddingNeeded = width - currentRow.length;
    final padding = _generatePadding(paddingNeeded);
    buffer.write(currentRow + padding);
  }
  
  final gridString = buffer.toString();
  final height = gridString.length ~/ width;
  
  print('\n/// AUTOMATICALLY GENERATED PREVIEW');
  print('// Grid Dimensions: ${width}x$height');
  // Formatted preview
  for (int i = 0; i < height; i++) {
     print("    '${gridString.substring(i * width, (i + 1) * width)}'");
  }
  
  print('\n// Copy this into your GridDefinition vocabulary:');
  print('vocabulary: const [');
  for (final word in sortedVocab) {
    print('  "$word",');
  }
  print('],');
}

String _generatePadding(int length) {
  const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  final random = Random();
  return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
}
