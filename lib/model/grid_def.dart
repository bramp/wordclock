

class GridDefinition {
  final int width;
  final int height;
  final String letters;
  final List<String> vocabulary; // The words hidden in the grid
  
  // Cache the mapping
  late final Map<String, List<List<int>>> mapping = _generateMapping();

  GridDefinition({
    required this.width,
    required this.height,
    required this.letters,
    required this.vocabulary,
  });

  Map<String, List<List<int>>> _generateMapping() {
    final Map<String, List<List<int>>> result = {};
    
    // For each word in our vocabulary, find ALL its occurrences in the grid string.
    // We treat the grid as a single 1D string.
    for (final word in vocabulary) {
      final List<List<int>> matches = [];
      
      int startIndex = 0;
      while (true) {
        final index = letters.indexOf(word, startIndex);
        if (index == -1) break;
        
        // Found a match at [index]
        final List<int> indices = List.generate(word.length, (i) => index + i);
        matches.add(indices);
        
        // This assumes non-overlapping usage of words.
        startIndex = index + 1;
      }
      
      if (matches.isNotEmpty) {
        result[word] = matches;
      }
    }
    return result;
  }
  
  static final english11x10 = GridDefinition(
    width: 11,
    height: 10,
    letters: 
      "ITLISASTIME"
      "ACQUARTERDC"
      "TWENTYFIVEX"
      "HALFBTENFTO"
      "PASTERUNINE"
      "ONESIXTHREE"
      "FOURFIVETWO"
      "EIGHTELEVEN"
      "SEVENTWELVE"
      "TENSEOCLOCK",
    vocabulary: const [
      "IT", "IS", "QUARTER", "TWENTY", "FIVE", "HALF", "TEN", "TO", "PAST",
      "NINE", "ONE", "SIX", "THREE", "FOUR", "TWO", "EIGHT", "ELEVEN", "SEVEN",
      "TWELVE", "OCLOCK"
    ],
  );
}
