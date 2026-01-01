class WordGrid {
  final int width;
  final String letters;

  WordGrid({required this.width, required this.letters})
    : assert(
        letters.length % width == 0,
        "Grid letters must fit perfectly into width",
      );

  int get height => letters.length ~/ width;

  /// Calculates the set of indices to light up for the given [phrase].
  Set<int> getIndices(String phrase) {
    final words = phrase.split(' ');
    final activeIndices = <int>{};
    int lastEndIndex = -1;

    for (final wordStr in words) {
      if (wordStr.isEmpty) continue;

      // Find the first occurrence of the word strictly after the last one ended
      int matchIndex = letters.indexOf(wordStr, lastEndIndex + 1);

      // If not found sequentially, fallback to finding the last occurrence in the grid
      if (matchIndex == -1) {
        matchIndex = letters.lastIndexOf(wordStr);
      }

      if (matchIndex == -1) {
        // In debug mode, this will throw. In release, it does nothing and we skip.
        assert(
          false,
          "Programming Error: Word '$wordStr' not found in grid strictly after index $lastEndIndex. Full phrase: '$phrase'",
        );
        continue;
      }

      for (int i = 0; i < wordStr.length; i++) {
        activeIndices.add(matchIndex + i);
      }
      lastEndIndex = matchIndex + wordStr.length - 1;
    }
    return activeIndices;
  }
}
