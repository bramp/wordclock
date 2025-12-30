
import 'dart:collection';
import 'dart:math';
import 'package:wordclock/logic/time_to_words.dart';
import 'package:wordclock/model/word_type.dart';

/// SMART GRID GENERATOR
/// 
/// 1. Scans Logic to find all used Words.
/// 2. Builds a Dependency Graph (A -> B if "A" comes before "B" in a phrase).
/// 3. Topologically Sorts the Graph to find the optimal global order.
/// 4. Generates the Grid.
void main() {
  const int gridWidth = 11;
  const int gridHeight = 10; // Try to fit in 10, or auto-expand
  
  // 1. SCAN & BUILD GRAPH
  final graph = _buildDependencyGraph();
  
  // 2. TOPOLOGICAL SORT
  // This gives us the linear order of words that satisfies ALL phrases.
  List<WordType> sortedMetadata;
  try {
     sortedMetadata = _topologicalSort(graph);
  } catch (e) {
    print('ERROR: Cycle detected in word logic! Phrases cannot be linearized.');
    print(e);
    return;
  }

  print('// Optimized Order found: ${sortedMetadata.map((e) => e.name).toList()}');

  // 3. GENERATE GRID
  _generateGrid(gridWidth, sortedMetadata);
}


typedef Graph = Map<WordType, Set<WordType>>;

Graph _buildDependencyGraph() {
  final Graph graph = {};
  
  // Initialize nodes
  for (var w in WordType.values) {
    graph[w] = {};
  }
  
  // Scan 24 Hours
  for (int h = 0; h < 24; h++) {
    for (int m = 0; m < 60; m++) {
      final time = DateTime(2025, 1, 1, h, m);
      final List<WordType> phrase = TimeToWords.convert(time);
      
      // Add edges A -> B
      for (int i = 0; i < phrase.length - 1; i++) {
        final current = phrase[i];
        final next = phrase[i + 1];
        
        // Add edge
        graph[current]!.add(next);
      }
    }
  }
  
  // Remove unused nodes (words that never appear)
  final usedWords = <WordType>{};
  graph.forEach((node, edges) {
    if (edges.isNotEmpty) usedWords.add(node);
    for (var neighbor in edges) {
        usedWords.add(neighbor);
    }
  });
  
  // Clean graph
  final Graph cleanedGraph = {};
  for (var w in usedWords) {
    cleanedGraph[w] = graph[w] ?? {};
  }
  
  return cleanedGraph;
}

List<WordType> _topologicalSort(Graph graph) {
  // Kahn's Algorithm
  final Map<WordType, int> inDegree = {};
  for (var node in graph.keys) {
    inDegree[node] = 0;
  }
  
  for (var edges in graph.values) {
    for (var neighbor in edges) {
      inDegree[neighbor] = (inDegree[neighbor] ?? 0) + 1;
    }
  }
  
  final Queue<WordType> queue = Queue();
  inDegree.forEach((node, degree) {
    if (degree == 0) queue.add(node);
  });
  
  final List<WordType> result = [];
  
  while (queue.isNotEmpty) {
    // Heuristic: If multiple nodes available, pick the one with longest word length? 
    // Or specific priority? For now: FIFO.
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
    throw Exception("Graph has a cycle! Result: $result vs Graph: ${graph.keys}");
  }
  
  return result;
}

void _generateGrid(int width, List<WordType> sortedVocab) {
  final buffer = StringBuffer();
  final Map<WordType, List<int>> mapping = {};
  
  int currentIndex = 0;
  String currentRow = "";
  
  for (final wordEnum in sortedVocab) {
    String wordStr = _enumToString(wordEnum);
    
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
    
    // Map
    final indices = List.generate(wordStr.length, (i) => currentIndex + i);
    mapping[wordEnum] = indices;
    
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
  
  print('\n/// AUTOMATICALLY GENERATED FROM DEPENDENCY GRAPH');
  print('static const graph${width}x$height = GridDefinition(');
  print('  width: $width,');
  print('  height: $height,');
  print('  letters:');
  for (int i = 0; i < height; i++) {
    print("    '${gridString.substring(i * width, (i + 1) * width)}'");
  }
  print("    ,");
  print('  mapping: {');
  for (final entry in mapping.entries) {
    print('    WordType.${entry.key.name}: ${entry.value},');
  }
  print('  },');
  print(');');
}

String _enumToString(WordType type) {
  switch (type) {
    case WordType.isVerb: return "IS";
    case WordType.fiveMinutes: return "FIVE";
    case WordType.tenMinutes: return "TEN";
    case WordType.oclock: return "OCLOCK";
    default: return type.name.toUpperCase();
  }
}

String _generatePadding(int length) {
  const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  final random = Random();
  return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
}
