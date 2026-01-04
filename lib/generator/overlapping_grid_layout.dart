import 'dart:math';
import 'package:wordclock/generator/graph_types.dart';

// ignore_for_file: library_private_types_in_public_api

/// A 2D grid placement engine that supports word overlapping.
///
/// This engine places whole words on a 2D grid, allowing words to share
/// cells when they have matching characters at the overlap positions.
class OverlappingGridLayout {
  final int width;
  final int targetHeight;
  final Graph graph;
  final Random random;
  final List<String> paddingCells;
  final bool requiresPadding;

  // Current grid state: position -> character
  final Map<_Position, String> grid = {};

  // Track which words have been placed
  final Set<String> placedWords = {};

  OverlappingGridLayout({
    required this.width,
    required this.targetHeight,
    required this.graph,
    required this.random,
    required this.paddingCells,
    required this.requiresPadding,
  });

  /// Attempts to generate a grid with word overlap.
  /// Returns null if it cannot fit within the target dimensions.
  List<String>? tryGenerate(List<Node> sortedNodes) {
    // Group nodes into words, maintaining character order
    final wordNodes = <String, List<Node>>{};
    for (final node in sortedNodes) {
      wordNodes.putIfAbsent(node.word, () => []).add(node);
    }

    // Sort nodes within each word by character index
    for (final nodes in wordNodes.values) {
      nodes.sort((a, b) => a.charIndex.compareTo(b.charIndex));
    }

    // Process words in the order they appear in sortedNodes (topological order)
    final processedWords = <String>{};

    for (final node in sortedNodes) {
      final word = node.word;
      if (processedWords.contains(word)) continue;

      final nodes = wordNodes[word]!;
      if (!_placeWord(word, nodes)) {
        // Could not place - try fallback
        return null;
      }

      processedWords.add(word);
    }

    // Convert grid map to cell list
    return gridToCells();
  }

  bool _placeWord(String word, List<Node> nodes) {
    // Get the characters of this word
    final chars = nodes.map((n) => n.char).toList();

    // Try to find existing placements where this word could overlap
    final candidates = _findOverlapCandidates(chars);

    if (candidates.isNotEmpty) {
      // Sort by amount of overlap (prefer more overlap)
      candidates.sort((a, b) => b.overlapCount.compareTo(a.overlapCount));

      for (final candidate in candidates) {
        if (_canPlaceAt(chars, candidate.row, candidate.col)) {
          _placeAt(chars, candidate.row, candidate.col);
          placedWords.add(word);
          return true;
        }
      }
    }

    // Try to place on a new row/position
    return _findNewPlacement(chars, word);
  }

  List<_PlacementCandidate> _findOverlapCandidates(List<String> chars) {
    final candidates = <_PlacementCandidate>[];

    // Check all existing positions for potential overlap
    for (final entry in grid.entries) {
      final pos = entry.key;
      final existingChar = entry.value;

      // Try to overlap starting from this position
      for (int i = 0; i < chars.length; i++) {
        if (chars[i] == existingChar) {
          // This character matches - try placing word here
          final startRow = pos.row;
          final startCol = pos.col - i;

          if (startCol >= 0 && startCol + chars.length <= width) {
            int overlapCount = 0;
            bool valid = true;

            for (int j = 0; j < chars.length; j++) {
              final checkPos = _Position(startRow, startCol + j);
              if (grid.containsKey(checkPos)) {
                if (grid[checkPos] == chars[j]) {
                  overlapCount++;
                } else {
                  valid = false;
                  break;
                }
              }
            }

            if (valid && overlapCount > 0) {
              candidates.add(
                _PlacementCandidate(startRow, startCol, overlapCount),
              );
            }
          }
        }
      }
    }

    return candidates;
  }

  bool _canPlaceAt(List<String> chars, int row, int col) {
    if (row < 0 || row >= targetHeight) return false;
    if (col < 0 || col + chars.length > width) return false;

    for (int i = 0; i < chars.length; i++) {
      final pos = _Position(row, col + i);
      if (grid.containsKey(pos) && grid[pos] != chars[i]) {
        return false;
      }
    }

    return true;
  }

  void _placeAt(List<String> chars, int row, int col) {
    for (int i = 0; i < chars.length; i++) {
      grid[_Position(row, col + i)] = chars[i];
    }
  }

  bool _findNewPlacement(List<String> chars, String word) {
    // Find the first empty or partially filled row
    for (int row = 0; row < targetHeight; row++) {
      for (int col = 0; col <= width - chars.length; col++) {
        if (_canPlaceAt(chars, row, col)) {
          _placeAt(chars, row, col);
          placedWords.add(word);
          return true;
        }
      }
    }

    return false; // Could not find placement
  }

  List<String> gridToCells() {
    final cells = <String>[];

    for (int row = 0; row < targetHeight; row++) {
      for (int col = 0; col < width; col++) {
        final pos = _Position(row, col);
        if (grid.containsKey(pos)) {
          cells.add(grid[pos]!);
        } else {
          // Add random padding
          cells.add(paddingCells[random.nextInt(paddingCells.length)]);
        }
      }
    }

    return cells;
  }
}

class _Position {
  final int row;
  final int col;

  _Position(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      other is _Position && row == other.row && col == other.col;

  @override
  int get hashCode => row * 10000 + col;
}

class _PlacementCandidate {
  final int row;
  final int col;
  final int overlapCount;

  _PlacementCandidate(this.row, this.col, this.overlapCount);
}
