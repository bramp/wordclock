// ignore_for_file: avoid_print
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:wordclock/generator/backtracking/graph/dependency_graph.dart';
import 'package:wordclock/generator/backtracking/graph/phrase_trie.dart';
import 'package:wordclock/generator/backtracking/graph/word_node.dart';
import 'package:wordclock/generator/backtracking/graph/cell_codec.dart';
import 'package:wordclock/generator/model/word_placement.dart';
import 'package:wordclock/generator/utils/word_clock_utils.dart';
import 'package:wordclock/languages/all.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';

/// ANSI color codes for terminal output
class AnsiColors {
  static const String reset = '\x1B[0m';
  static const String dim = '\x1B[2m';

  // Bright foreground colors for better visibility
  static const List<String> wordColors = [
    '\x1B[91m', // Bright Red
    '\x1B[92m', // Bright Green
    '\x1B[93m', // Bright Yellow
    '\x1B[94m', // Bright Blue
    '\x1B[95m', // Bright Magenta
    '\x1B[96m', // Bright Cyan
    '\x1B[31m', // Red
    '\x1B[32m', // Green
    '\x1B[33m', // Yellow
    '\x1B[34m', // Blue
    '\x1B[35m', // Magenta
    '\x1B[36m', // Cyan
  ];

  static String getColor(int index) => wordColors[index % wordColors.length];
}

/// Helper to get Language from arguments
WordClockLanguage getLanguage(ArgResults results) {
  final inputId = results['lang'] as String;
  final match = WordClockLanguages.all
      .where((l) => l.id.toLowerCase() == inputId.toLowerCase())
      .toList();

  if (match.isEmpty) {
    throw UsageException(
      'Unknown language ID "$inputId". Available: ${WordClockLanguages.byId.keys.join(', ')}',
      '',
    );
  }
  return match.first;
}

/// Prints a grid with each word colored differently
void printColoredGrid(
  WordGrid grid,
  List<WordPlacement> placements, {
  String? header, // TODO Do we need this, the caller should just print.
}) {
  final colorMap = _buildColorMap(placements);

  // Group colored word labels by row
  final rowWords = <int, List<String>>{};
  for (int i = 0; i < placements.length; i++) {
    final p = placements[i];
    final color = AnsiColors.getColor(i);
    rowWords
        .putIfAbsent(p.row, () => [])
        .add('$color${p.word}${AnsiColors.reset}');
  }

  if (header != null) print(header);
  for (int row = 0; row < grid.height; row++) {
    final gridRow = _formatColoredRow(grid.cells, grid.width, row, colorMap);
    final words = (rowWords[row] ?? []).join(' ');
    print('$gridRow   $words');
  }
}

/// Returns a string representation of the grid in black and white
String formatGrid(WordGrid grid) {
  final buffer = StringBuffer();
  for (int row = 0; row < grid.height; row++) {
    for (int col = 0; col < grid.width; col++) {
      buffer.write(grid.cells[row * grid.width + col]);
    }
    buffer.writeln();
  }
  return buffer.toString();
}

Map<int, Map<int, String>> _buildColorMap(List<WordPlacement> placements) {
  final colorMap = <int, Map<int, String>>{};
  for (int i = 0; i < placements.length; i++) {
    final p = placements[i];
    final color = AnsiColors.getColor(i);
    colorMap.putIfAbsent(p.row, () => {});
    for (int col = p.startCol; col <= p.endCol; col++) {
      colorMap[p.row]![col] = color;
    }
  }
  return colorMap;
}

String _formatColoredRow(
  List<String?> cells,
  int width,
  int row,
  Map<int, Map<int, String>> colorMap,
) {
  final buffer = StringBuffer();
  for (int col = 0; col < width; col++) {
    final cell =
        cells[row * width + col] ?? '·'; // Use dot for empty/null cells
    final color = colorMap[row]?[col];
    if (color != null) {
      buffer.write('$color$cell${AnsiColors.reset}');
    } else {
      buffer.write('${AnsiColors.dim}$cell${AnsiColors.reset}');
    }
  }
  return buffer.toString();
}

/// Reconstructs the WordDependencyGraph and Placements from an existing Grid.
///
/// This is shared because View, Graph, and Debug commands all need it.
({List<WordPlacement> placements, WordDependencyGraph graph})
reconstructGraphFromGrid(WordGrid grid, WordClockLanguage language) {
  final codec = CellCodec();

  // 1. Identify all physical word occurrences (Word String -> Set of Start Offsets)
  final observedOffsets = <String, Set<int>>{};
  final phraseToOffsets = <String, List<int>>{};

  WordClockUtils.forEachTime(language, (time, phrase) {
    if (phraseToOffsets.containsKey(phrase)) return; // Already processed

    final words = language.tokenize(phrase);
    final sequences = grid.getWordSequences(
      words,
      requiresPadding: language.requiresPadding,
    );

    final offsets = <int>[];
    for (int i = 0; i < words.length; i++) {
      final indices = sequences[i];
      if (indices != null && indices.isNotEmpty) {
        final start = indices.first;
        offsets.add(start);
        observedOffsets.putIfAbsent(words[i], () => {}).add(start);
      }
    }
    phraseToOffsets[phrase] = offsets;
  });

  // 2. Create WordNodes based on physical order
  final offsetToNode = <int, WordNode>{};
  final nodesByName = <String, List<WordNode>>{};

  // To verify consistency, we'll track instances.
  for (final word in observedOffsets.keys) {
    final sortedOffsets = observedOffsets[word]!.toList()..sort();

    final nodes = <WordNode>[];
    for (int i = 0; i < sortedOffsets.length; i++) {
      final offset = sortedOffsets[i];
      final cells = <String>[];
      int current = offset;
      String accumulated = "";
      while (accumulated.length < word.length && current < grid.cells.length) {
        final cell = grid.cells[current];
        cells.add(cell);
        accumulated += cell;
        current++;
      }

      final node = WordNode(
        word: word,
        instance: i,
        cellCodes: codec.encodeAll(cells),
        phrases: {}, // Will populate in step 3
      );

      offsetToNode[offset] = node;
      nodes.add(node);
    }
    nodesByName[word] = nodes;
  }

  // 3. Build Graph Structure (Edges & Phrases)
  final edges = <WordNode, Set<WordNode>>{};
  final inEdges = <WordNode, Set<WordNode>>{};
  final phraseNodesMap = <String, List<WordNode>>{};

  phraseToOffsets.forEach((phrase, offsets) {
    final phraseNodes = <WordNode>[];
    WordNode? prevNode;

    for (int i = 0; i < offsets.length; i++) {
      final offset = offsets[i];
      final node = offsetToNode[offset];
      if (node != null) {
        phraseNodes.add(node);
        node.phrases.add(phrase);

        // Handle edges
        if (prevNode != null) {
          edges.putIfAbsent(prevNode, () => {}).add(node);
          inEdges.putIfAbsent(node, () => {}).add(prevNode);
        }

        prevNode = node;
      }
    }
    phraseNodesMap[phrase] = phraseNodes;
  });

  // 4. Rebuild Phrase Trie (Required for solver to find placements)
  final globalTrie = PhraseTrie();

  for (final entry in phraseNodesMap.entries) {
    final phraseNodes = entry.value;
    if (phraseNodes.isEmpty) continue;

    phraseNodes[0].hasEmptyPredecessor = true;

    for (int targetIdx = 1; targetIdx < phraseNodes.length; targetIdx++) {
      final targetNode = phraseNodes[targetIdx];
      var currentTrieNode = globalTrie.getOrCreateRoot(phraseNodes[0].word);

      if (!phraseNodes[0].ownedTrieNodes.contains(currentTrieNode)) {
        phraseNodes[0].ownedTrieNodes.add(currentTrieNode);
      }

      for (int predIdx = 1; predIdx < targetIdx; predIdx++) {
        final predNode = phraseNodes[predIdx];
        currentTrieNode = globalTrie.getOrCreateChild(
          currentTrieNode,
          predNode.word,
        );
        if (!predNode.ownedTrieNodes.contains(currentTrieNode)) {
          predNode.ownedTrieNodes.add(currentTrieNode);
        }
      }

      if (!targetNode.phraseTrieNodes.contains(currentTrieNode)) {
        targetNode.phraseTrieNodes.add(currentTrieNode);
      }
    }
  }

  // 5. Generate Placements
  final placements = <WordPlacement>[];
  for (final entry in offsetToNode.entries) {
    final offset = entry.key;
    final node = entry.value;

    placements.add(
      WordPlacement(
        word: '${node.word} (#${node.instance})',
        startOffset: offset,
        width: grid.width,
        length: node.cellCodes.length,
      ),
    );
  }

  placements.sort((a, b) => a.startOffset.compareTo(b.startOffset));

  final graph = WordDependencyGraph(
    nodes: nodesByName,
    edges: edges,
    inEdges: inEdges,
    phrases: phraseNodesMap,
    language: language,
    codec: codec,
  );

  return (placements: placements, graph: graph);
}
