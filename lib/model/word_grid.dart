class WordGrid {
  final List<String> cells;

  final int width;
  int get height => cells.length ~/ width;

  const WordGrid({required this.width, required this.cells})
    : assert(
        cells.length % width == 0,
        'Cells length (${cells.length}) must be a multiple of width ($width)',
      );

  /// Creates a WordGrid from a string of letters.
  /// Note: This is not a const constructor as it performs merging logic.
  WordGrid.fromLetters({required this.width, required String letters})
    : cells = splitIntoCells(letters) {
    assert(
      cells.length % width == 0,
      'Letters length (${cells.length} after merging) must be a multiple of width ($width)',
    );
  }

  static List<String> splitIntoCells(String letters) {
    final List<String> result = [];
    for (int i = 0; i < letters.length; i++) {
      final char = letters[i];
      // Merge ' or ’ with the previous character if applicable
      if ((char == "'" || char == "’") && result.isNotEmpty) {
        result[result.length - 1] = result.last + char;
      } else {
        result.add(char);
      }
    }
    return result;
  }

  /// Calculates the set of indices to light up for the given [phrase].
  Set<int> getIndices(String phrase) {
    final words = phrase.split(' ');
    final activeIndices = <int>{};
    int lastEndIndex = -1;

    for (final wordStr in words) {
      if (wordStr.isEmpty) continue;

      // Find the first occurrence of the word in the cells strictly after the last one ended.
      // We look for a sequence of cells that, when joined, match the word.
      int matchIndex = _findWord(wordStr, lastEndIndex + 1);

      // If not found sequentially, fallback to finding the last occurrence in the grid
      if (matchIndex == -1) {
        matchIndex = _findWord(wordStr, 0, reverse: true);
      }

      if (matchIndex == -1) {
        // In debug mode, this will throw. In release, it does nothing and we skip.
        assert(
          false,
          "Programming Error: Word '$wordStr' not found in grid. Full phrase: '$phrase'",
        );
        continue;
      }

      // Add indices for all cells that matched the word.
      // Note: A single word might span multiple cells, or even a single cell might contain a word.
      // But typically, a word is a sequence of cells.
      int cellsUsed = 0;
      String matched = "";
      while (matched.length < wordStr.length &&
          (matchIndex + cellsUsed) < cells.length) {
        activeIndices.add(matchIndex + cellsUsed);
        matched += cells[matchIndex + cellsUsed];
        cellsUsed++;
      }
      lastEndIndex = matchIndex + cellsUsed - 1;
    }
    return activeIndices;
  }

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

  bool _matchAt(String word, int index) {
    String found = "";
    int i = index;
    while (found.length < word.length && i < cells.length) {
      found += cells[i];
      i++;
    }
    return found == word;
  }
}
