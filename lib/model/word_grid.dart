import 'package:wordclock/logic/time_to_words.dart';

class WordGrid {
  final int width;
  final String letters;
  final TimeToWords timeConverter;

  WordGrid({
    required this.width,
    required this.letters,
    required this.timeConverter,
  }) : assert(
         letters.length % width == 0,
         "Grid letters must fit perfectly into width",
       );

  factory WordGrid.fromLetters(int width, String letters) {
    return WordGrid(
      width: width,
      letters: letters,
      timeConverter: EnglishTimeToWords(),
    );
  }

  int get height => letters.length ~/ width;

  /// Calculates the set of indices to light up for the given [time].
  Set<int> getIndices(DateTime time) {
    final phrase = timeConverter.convert(time);
    final words = phrase.split(' ');
    final activeIndices = <int>{};
    int lastEndIndex = -1;

    for (final wordStr in words) {
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

  // The original qlocktwo grid. Here for reference only
  // static final englishQlocktwo = WordGrid(
  //   width: 11,
  //   letters:
  //       "ITLISASTIME"
  //       "ACQUARTERDC"
  //       "TWENTYFIVEX"
  //       "HALFBTENFTO"
  //       "PASTERUNINE"
  //       "ONESIXTHREE"
  //       "FOURFIVETWO"
  //       "EIGHTELEVEN"
  //       "SEVENTWELVE"
  //       "TENSEOCLOCK",
  //   timeConverter: EnglishTimeToWords(),
  // );

  // Automatically generated grid using bin/grid_builder.dart
  static final english11x10 = WordGrid(
    width: 11,
    letters:
        'ITRISSHALFA'
        'AQUARTERTEN'
        'TWENTYCFIVE'
        'SPASTTOETMO'
        'EIGHTELEVEN'
        'ODQFIVEFOUR'
        'RZUNINEONEP'
        'SEVENSIXTEN'
        'THREETWELVE'
        'ATWOIOCLOCK',
    timeConverter: EnglishTimeToWords(),
  );
}
