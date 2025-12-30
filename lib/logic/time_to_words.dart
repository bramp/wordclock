import 'package:wordclock/model/word_type.dart';

class TimeToWords {
  /// Converts [time] into a set of [WordType]s representing the phrase.
  /// 
  /// Logic mimics the classic Word Clock:
  /// - Times are rounded to the nearest 5 minutes.
  /// - "Minutes past Hour" for 0-30.
  /// - "Minutes to (Hour + 1)" for 35-59.
  /// - "O'Clock" is used for the exact hour.
  static Set<WordType> convert(DateTime time) {
    Set<WordType> activeWords = {WordType.it, WordType.isVerb};
    
    // Round down to nearest 5 minutes
    int minute = time.minute;
    int hour = time.hour;
    
    // Rounding logic: Always floor
    int remainder = minute % 5;
    minute -= remainder;

    // Decide on Preposition and Minute Word
    if (minute == 0) {
       activeWords.add(WordType.oclock);
    } else if (minute == 5) {
       activeWords.add(WordType.fiveMinutes);
       activeWords.add(WordType.past);
    } else if (minute == 10) {
       activeWords.add(WordType.tenMinutes);
       activeWords.add(WordType.past);
    } else if (minute == 15) {
       activeWords.add(WordType.quarter);
       activeWords.add(WordType.past);
    } else if (minute == 20) {
       activeWords.add(WordType.twenty);
       activeWords.add(WordType.past);
    } else if (minute == 25) {
       activeWords.add(WordType.twenty);
       activeWords.add(WordType.fiveMinutes);
       activeWords.add(WordType.past);
    } else if (minute == 30) {
       activeWords.add(WordType.half);
       activeWords.add(WordType.past);
    } else if (minute == 35) {
       // 25 to next hour
       activeWords.add(WordType.twenty);
       activeWords.add(WordType.fiveMinutes);
       activeWords.add(WordType.to);
       hour += 1;
    } else if (minute == 40) {
       activeWords.add(WordType.twenty);
       activeWords.add(WordType.to);
       hour += 1;
    } else if (minute == 45) {
       activeWords.add(WordType.quarter);
       activeWords.add(WordType.to);
       hour += 1;
    } else if (minute == 50) {
       activeWords.add(WordType.tenMinutes);
       activeWords.add(WordType.to);
       hour += 1;
    } else if (minute == 55) {
       activeWords.add(WordType.fiveMinutes);
       activeWords.add(WordType.to);
       hour += 1;
    }
    
    // Determine Hour Word
    // Normalize hour (0-23) to (1-12)
    int displayHour = hour % 12;
    if (displayHour == 0) displayHour = 12;
    
    switch (displayHour) {
      case 1: activeWords.add(WordType.one); break;
      case 2: activeWords.add(WordType.two); break;
      case 3: activeWords.add(WordType.three); break;
      case 4: activeWords.add(WordType.four); break;
      case 5: activeWords.add(WordType.five); break;
      case 6: activeWords.add(WordType.six); break;
      case 7: activeWords.add(WordType.seven); break;
      case 8: activeWords.add(WordType.eight); break;
      case 9: activeWords.add(WordType.nine); break;
      case 10: activeWords.add(WordType.ten); break;
      case 11: activeWords.add(WordType.eleven); break;
      case 12: activeWords.add(WordType.twelve); break;
    }

    return activeWords;
  }
}
