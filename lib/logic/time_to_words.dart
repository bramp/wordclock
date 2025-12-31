abstract class TimeToWords {
  /// Converts a [DateTime] object into a human-readable string representation of time.
  String convert(DateTime time);
}

class EnglishTimeToWords implements TimeToWords {
  @override
  String convert(DateTime time) {
    // Round down to nearest 5 minutes
    int minute = time.minute;
    int hour = time.hour;

    // Rounding logic: Always floor
    int remainder = minute % 5;
    minute -= remainder;

    // Phrase components
    // Format: IT IS [MINUTES] [PAST/TO] [HOUR] [OCLOCK]
    List<String> parts = ["IT", "IS"];
    List<String> minuteParts = [];
    String? relation; // PAST or TO
    String? hourStr;
    String? suffix;

    // 1. Determine Minutes & Relation
    if (minute == 0) {
      suffix = "OCLOCK";
    } else if (minute == 5) {
      minuteParts = ["FIVE"];
      relation = "PAST";
    } else if (minute == 10) {
      minuteParts = ["TEN"];
      relation = "PAST";
    } else if (minute == 15) {
      minuteParts = ["QUARTER"];
      relation = "PAST";
    } else if (minute == 20) {
      minuteParts = ["TWENTY"];
      relation = "PAST";
    } else if (minute == 25) {
      minuteParts = ["TWENTY", "FIVE"];
      relation = "PAST";
    } else if (minute == 30) {
      minuteParts = ["HALF"];
      relation = "PAST";
    } else if (minute == 35) {
      // 25 to next hour
      minuteParts = ["TWENTY", "FIVE"];
      relation = "TO";
      hour += 1;
    } else if (minute == 40) {
      minuteParts = ["TWENTY"];
      relation = "TO";
      hour += 1;
    } else if (minute == 45) {
      minuteParts = ["QUARTER"];
      relation = "TO";
      hour += 1;
    } else if (minute == 50) {
      minuteParts = ["TEN"];
      relation = "TO";
      hour += 1;
    } else if (minute == 55) {
      minuteParts = ["FIVE"];
      relation = "TO";
      hour += 1;
    }

    // 2. Determine Hour
    // Normalize hour (0-23) to (1-12)
    int displayHour = hour % 12;
    if (displayHour == 0) displayHour = 12;

    switch (displayHour) {
      case 1:
        hourStr = "ONE";
        break;
      case 2:
        hourStr = "TWO";
        break;
      case 3:
        hourStr = "THREE";
        break;
      case 4:
        hourStr = "FOUR";
        break;
      case 5:
        hourStr = "FIVE";
        break;
      case 6:
        hourStr = "SIX";
        break;
      case 7:
        hourStr = "SEVEN";
        break;
      case 8:
        hourStr = "EIGHT";
        break;
      case 9:
        hourStr = "NINE";
        break;
      case 10:
        hourStr = "TEN";
        break;
      case 11:
        hourStr = "ELEVEN";
        break;
      case 12:
        hourStr = "TWELVE";
        break;
    }

    // 3. Assemble
    parts.addAll(minuteParts);
    if (relation != null) parts.add(relation);
    if (hourStr != null) parts.add(hourStr);
    if (suffix != null) parts.add(suffix);

    return parts.join(" ");
  }
}
