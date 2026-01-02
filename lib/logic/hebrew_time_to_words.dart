import 'package:wordclock/logic/time_to_words.dart';

// TODO Come back and check how Right-to-Left works here.
class HebrewTimeToWords implements TimeToWords {
  @override
  String convert(DateTime time) {
    int m = time.minute;
    int h = time.hour;

    m = m - (m % 5);
    if (m >= 80) h++;
    final displayHour = h % 12;

    List<_Word> activeWords = [];

    // Intro: (0, 7)
    activeWords.add(_Word('העשה', 0, 7));

    // Exact Hour Words
    // 0: Twelve (Split: 1,0 and 1,5)
    // 11: Eleven (Split: 0,3 and 1,0)
    final exactWords = switch (displayHour) {
      0 => [_Word('הרשע', 1, 0), _Word('םײתש', 1, 5)],
      1 => [_Word('תחא', 0, 3)],
      2 => [_Word('םײתש', 1, 5)],
      3 => [_Word('ש׀לש', 2, 7)],
      4 => [_Word('עברא', 2, 3)],
      5 => [_Word('שמח', 3, 8)],
      6 => [_Word('שש', 3, 7)],
      7 => [_Word('עבש', 3, 5)],
      8 => [_Word('הנ׀מש', 3, 0)],
      9 => [_Word('עשת', 4, 7)],
      10 => [_Word('רשע', 0, 0)],
      11 => [_Word('תחא', 0, 3), _Word('הרשע', 1, 0)],
      _ => <_Word>[],
    };
    activeWords.addAll(exactWords);

    // Delta Words
    // 25, 35, 45, 55 are split.
    if (m != 0) {
      final deltaWords = switch (m) {
        5 => [_Word('השימח׀', 4, 0)],
        10 => [_Word('הרשעו', 6, 0)],
        15 => [_Word('עברו', 7, 0)],
        20 => [_Word('םירשעו', 5, 4)],
        25 => [_Word('םירשע', 5, 4), _Word('שמחו', 9, 1)],
        30 => [_Word('יצחו', 8, 0)],
        35 => [_Word('םישןלש', 6, 5), _Word('שמחו', 9, 1)],
        40 => [_Word('םיעבראו', 7, 4)],
        45 => [_Word('םיעברא', 7, 4), _Word('שמחו', 9, 1)],
        50 => [_Word('םישימחו', 8, 4)],
        55 => [_Word('םישימח', 8, 4), _Word('שמחו', 9, 1)],
        _ => <_Word>[],
      };
      activeWords.addAll(deltaWords);
    }

    // Sort by Grid Position (Row then Col)
    activeWords.sort((a, b) {
      if (a.r != b.r) {
        return a.r.compareTo(b.r);
      }
      return a.c.compareTo(b.c);
    });

    return activeWords.map((w) => w.text).join(' ').trim();
  }
}

class _Word {
  final String text;
  final int r;
  final int c;
  _Word(this.text, this.r, this.c);
}
