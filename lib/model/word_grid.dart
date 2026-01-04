class WordGrid {
  final List<String> cells;

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

  static List<String> splitIntoCells(
    String letters, {
    bool mergeApostrophes = true,
  }) {
    final List<String> result = [];
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

  /// Calculates the set of indices to light up for the given [phrase].
  Set<int> getIndices(String phrase) {
    final words = phrase.split(' ');
    final activeIndices = <int>{};
    int lastEndIndex = -1;

    for (final wordStr in words) {
      if (wordStr.isEmpty) continue;

      // Find the first occurrence of the word in the cells strictly after the last one ended.
      final indices = findWordIndices(wordStr, lastEndIndex + 1);
      final actualIndices =
          indices ?? findWordIndices(wordStr, 0, reverse: true);

      if (actualIndices == null) {
        // In debug mode, this will throw. In release, it does nothing and we skip.
        assert(
          false,
          "Programming Error: Word '$wordStr' not found in grid. Full phrase: '$phrase'",
        );
        continue;
      }

      activeIndices.addAll(actualIndices);
      lastEndIndex = actualIndices.last;
    }
    return activeIndices;
  }

  /// Finds the indices used by a single [word] starting from [start].
  /// Returns null if not found.
  List<int>? findWordIndices(String word, int start, {bool reverse = false}) {
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
