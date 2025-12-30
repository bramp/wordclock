import 'package:wordclock/model/word_type.dart';

class GridDefinition {
  final int width;
  final int height;
  final String letters; // All rows concatenated
  final Map<WordType, List<int>> mapping;

  const GridDefinition({
    required this.width,
    required this.height,
    required this.letters,
    required this.mapping,
  });
  
  static const english11x10 = GridDefinition(
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
    mapping: {
      WordType.it: [0, 1],
      WordType.isVerb: [3, 4],
      
      WordType.quarter: [13, 14, 15, 16, 17, 18, 19], // AC QUARTER DC (Row 1, indices 2-8 -> 11+2=13)
      
      WordType.twenty: [22, 23, 24, 25, 26, 27], // Row 2 (22), 0-5
      WordType.fiveMinutes: [28, 29, 30, 31],    // Row 2, 6-9
      
      WordType.half: [33, 34, 35, 36], // Row 3 (33), 0-3
      WordType.tenMinutes: [38, 39, 40], // Row 3, 5-7
      WordType.to: [42, 43], // Row 3, 9-10
      
      WordType.past: [44, 45, 46, 47], // Row 4 (44), 0-3
      WordType.nine: [51, 52, 53, 54], // Row 4, 7-10
      
      WordType.one: [55, 56, 57], // Row 5 (55), 0-2
      WordType.six: [58, 59, 60], // Row 5, 3-5
      WordType.three: [61, 62, 63, 64, 65], // Row 5, 6-10
      
      WordType.four: [66, 67, 68, 69], // Row 6 (66), 0-3
      WordType.five: [70, 71, 72, 73], // Row 6, 4-7
      WordType.two: [74, 75, 76], // Row 6, 8-10
      
      WordType.eight: [77, 78, 79, 80, 81], // Row 7 (77), 0-4
      WordType.eleven: [82, 83, 84, 85, 86, 87], // Row 7, 5-10
      
      WordType.seven: [88, 89, 90, 91, 92], // Row 8 (88), 0-4
      WordType.twelve: [93, 94, 95, 96, 97, 98], // Row 8, 5-10
      
      WordType.ten: [99, 100, 101], // Row 9 (99), 0-2
      WordType.oclock: [104, 105, 106, 107, 108, 109], // Row 9, 5-10
    }
  );
}
