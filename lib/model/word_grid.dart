import 'package:wordclock/model/types.dart';

class WordGrid {
  final List<Cell> cells;

  /// Whether apostrophes were merged when creating this grid from letters.
  /// If created directly from cells, this defaults to false.
  final bool mergeApostrophes;

  final int width;
  int get height => cells.length ~/ width;

  /// Default constructor for manually providing cells.
  const WordGrid({
    required this.width,
    required this.cells,
    this.mergeApostrophes = false,
  }) : assert(
         cells.length % width == 0,
         'Cells length (${cells.length}) must be a multiple of width ($width)',
       );

  /// Creates a WordGrid from a string of letters.
  /// Note: This is not a const constructor as it performs merging logic.
  WordGrid.fromLetters({
    required this.width,
    required String letters,
    this.mergeApostrophes = true,
  }) : cells = splitIntoCells(letters, mergeApostrophes: mergeApostrophes) {
    assert(
      cells.length % width == 0,
      'Letters length (${cells.length} after merging) must be a multiple of width ($width). '
      'Original length: ${letters.length}. Merge apostrophes: $mergeApostrophes',
    );
  }

  static List<Cell> splitIntoCells(
    String letters, {
    bool mergeApostrophes = true,
  }) {
    final List<Cell> result = [];
    for (int i = 0; i < letters.length; i++) {
      final char = letters[i];
      // Merge ' or ’ with the previous character if applicable
      if (mergeApostrophes &&
          (char == "'" || char == "’") &&
          result.isNotEmpty) {
        result[result.length - 1] = result.last + char;
      } else {
        result.add(char);
      }
    }
    return result;
  }

  /// Calculates the set of indices to light up for the given [searchUnits].
  ///
  /// If [requiresPadding] is true, this method will attempt to find occurrences
  /// that satisfy the padding constraint (at least one empty cell or newline between words).
  Set<int> getIndices(
    List<String> searchUnits, {
    bool requiresPadding = false,
  }) {
    final activeIndices = <int>{};
    final sequences = getWordSequences(
      searchUnits,
      requiresPadding: requiresPadding,
    );

    for (int i = 0; i < sequences.length; i++) {
      final indices = sequences[i];
      if (indices == null) {
        // Log usage error if needed, similar to original assert
        assert(
          false,
          "Programming Error: Unit '${searchUnits[i]}' not found in grid. Search units: $searchUnits",
        );
        continue;
      }
      activeIndices.addAll(indices);
    }
    return activeIndices;
  }

  /// Finds the sequence of indices for each unit in [searchUnits].
  ///
  /// Returns a list of the same length as [searchUnits], where each element is the list of indices
  /// for that unit, or null if the unit could not be found satisfying constraints.
  List<List<int>?> getWordSequences(
    List<String> searchUnits, {
    bool requiresPadding = false,
  }) {
    final results = <List<int>?>[];
    int lastEndIndex = -1;

    for (int i = 0; i < searchUnits.length; i++) {
      final unit = searchUnits[i];
      if (unit.isEmpty) {
        results.add(const []); // Empty unit -> empty indices
        continue;
      }

      // Find all occurrences and pick the best one
      List<int>? bestIndices;

      int searchStart = lastEndIndex + 1;

      while (true) {
        final matchIndex = _findWord(unit, searchStart);
        if (matchIndex == -1) break;

        // Calculate full indices for this match
        final indices = <int>[];
        int cellsUsed = 0;
        String matched = "";
        while (matched.length < unit.length &&
            (matchIndex + cellsUsed) < cells.length) {
          indices.add(matchIndex + cellsUsed);
          matched += cells[matchIndex + cellsUsed];
          cellsUsed++;
        }

        // Check padding
        bool paddingOk = true;
        if (requiresPadding && i > 0 && lastEndIndex != -1) {
          // matchIndex is searchStart.
          // Actually _findWord returns the start index.
          // matchIndex is start.
          if (matchIndex == lastEndIndex + 1) {
            final prevRow = lastEndIndex ~/ width;
            final currRow = matchIndex ~/ width;
            if (prevRow == currRow) {
              paddingOk = false;
            }
          }
        }

        if (paddingOk) {
          bestIndices = indices;
          break; // Found good match
        } else {
          bestIndices ??= indices; // Keep first found as fallback
        }

        searchStart = matchIndex + 1; // Continue search
      }

      // Fallback: search from beginning (reverse logic) if nothing found forward
      if (bestIndices == null && lastEndIndex != -1) {
        final reverseIndices = _findWordIndices(unit, 0, reverse: true);
        if (reverseIndices != null) {
          bestIndices = reverseIndices;
        }
      }

      results.add(bestIndices);
      if (bestIndices != null) {
        lastEndIndex = bestIndices.last;
      }
    }

    return results;
  }

  /// Finds the indices used by a single [word] starting from [start].
  ///
  /// Returns null if not found.
  ///
  /// This searches for a contiguous sequence of cells that form the word,
  /// skipping over multi-character cells appropriately.
  ///
  /// [start] is the index in [cells] to start searching from.
  /// [reverse] determines the search direction.
  List<int>? _findWordIndices(String word, int start, {bool reverse = false}) {
    final matchIndex = _findWord(word, start, reverse: reverse);
    if (matchIndex == -1) return null;

    final indices = <int>[];
    int cellsUsed = 0;
    String matched = "";
    while (matched.length < word.length &&
        (matchIndex + cellsUsed) < cells.length) {
      indices.add(matchIndex + cellsUsed);
      matched += cells[matchIndex + cellsUsed];
      cellsUsed++;
    }
    return indices;
  }

  /// Finds the starting cell index of [word] in the grid.
  ///
  /// Returns -1 if not found.
  int _findWord(String word, int start, {bool reverse = false}) {
    if (reverse) {
      for (int i = cells.length - 1; i >= 0; i--) {
        if (_matchAt(word, i)) return i;
      }
    } else {
      for (int i = start; i < cells.length; i++) {
        if (_matchAt(word, i)) return i;
      }
    }
    return -1;
  }

  /// Checks if [word] matches the cells starting at [index].
  ///
  /// Handles multi-character cells by concatenating them and comparing.
  bool _matchAt(String word, int index) {
    String found = "";
    int i = index;
    // Accumulate cell content until we match length or run out
    while (found.length < word.length && i < cells.length) {
      found += cells[i];
      i++;
    }
    return found == word;
  }
}
