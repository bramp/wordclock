import 'package:wordclock/languages/language.dart';
import 'package:wordclock/logic/time_to_words.dart';
import 'package:wordclock/model/word_grid.dart';

class EnglishLanguage implements WordClockLanguage {
  @override
  String get displayName => 'English';

  @override
  final TimeToWords timeToWords = EnglishTimeToWords();

  @override
  final String paddingAlphabet =
      "EEEEEEEEEEE" // 11
      "AAAAAAAA" // 8
      "RRRRRR" // 6
      "IIIIII" // 6
      "OOOOOO" // 6
      "TTTTTT" // 6
      "NNNNN" // 5
      "SSSS" // 4
      "LLLL" // 4
      "CCCC" // 3
      "UUU" // 3
      "DDD" // 3
      "PPP" // 3
      "MMM" // 3
      "HHH" // 3
      "G"
      "B"
      "F"
      "Y"
      "W"
      "K"
      "V"
      "X"
      "Z"
      "J"
      "Q";

  // The original qlocktwo grid. Here for reference only
  // WordGrid get defaultGrid => WordGrid(
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
  // );

  @override
  WordGrid get defaultGrid => WordGrid(
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
  );
}
