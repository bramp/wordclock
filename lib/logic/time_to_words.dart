abstract class TimeToWords {
  /// Converts a [DateTime] object into a human-readable string representation of time.
  String convert(DateTime time);
}

class EnglishTimeToWords implements TimeToWords {
  static const hours = {
    1: "ONE",
    2: "TWO",
    3: "THREE",
    4: "FOUR",
    5: "FIVE",
    6: "SIX",
    7: "SEVEN",
    8: "EIGHT",
    9: "NINE",
    10: "TEN",
    11: "ELEVEN",
    12: "TWELVE",
  };

  static const minutes = {
    5: "FIVE",
    10: "TEN",
    20: "TWENTY",
    25: "TWENTY FIVE",
  };

  @override
  String convert(DateTime time) {
    int m = (time.minute ~/ 5) * 5; // Round down to nearest 5
    int h = (m > 30) ? time.hour + 1 : time.hour;

    int displayHour = h % 12;
    if (displayHour == 0) displayHour = 12;

    final hStr = hours[displayHour]!;

    return switch (m) {
      0 => "IT IS $hStr OCLOCK", // Exact hour
      15 => "IT IS QUARTER PAST $hStr", // Quarter after X
      30 => "IT IS HALF PAST $hStr", // Half past X
      45 => "IT IS QUARTER TO $hStr", // Quarter before X
      < 30 => "IT IS ${minutes[m]} PAST $hStr", // X minutes past Y
      _ => "IT IS ${minutes[60 - m]} TO $hStr", // X minutes to Y
    };
  }
}
