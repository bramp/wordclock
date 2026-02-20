import 'package:wordclock/logic/time_to_words.dart';

class HighValyrianTimeToWords extends TimeToWords {
  @override
  String convert(DateTime time) {
    // High Valyrian Time Logic (Simplified/Constructed)
    // "Tubī" (In the day) / "Gēlenka" (In the night) context is usually omitted for clocks.

    // We will use standard phonetic spelling, and the custom font will map it to glyphs if desired,
    // or just render it in the stylish font.

    // Note: User provided "ValyrianAdvanced.ttf" which likely maps standard Latin characters
    // to High Valyrian glyphs. The grid should be composed of these Latin characters.

    int hour = time.hour;
    int minute = time.minute;

    // Round down to the nearest 5 minute increment
    minute = minute - (minute % 5);

    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;

    final hourWord = _getNumber(hour);

    // Phrase structure: "Is it [Hour] [Minute]"
    final buffer = StringBuffer('ISSA $hourWord'); // ISSA = It is

    if (minute != 0) {
      // "se [Minute]" (and [Minute])
      buffer.write(' SE ${_getNumber(minute)}');
    }

    return buffer.toString();
  }

  String _getNumber(int n) {
    if (n <= 10) {
      return switch (n) {
        1 => 'MĒRE',
        2 => 'LANTA',
        3 => 'HĀRE',
        4 => 'IZULA',
        5 => 'TŌMA',
        6 => 'BȲRE',
        7 => 'SĪKUDA',
        8 => 'JĒNQA',
        9 => 'VŌRE',
        10 => 'AMPA',
        _ => '',
      };
    }

    if (n < 20) return 'AMPA ${_getNumber(n - 10)}';
    if (n == 20) return 'LANTEPSA';
    if (n < 30) return 'LANTEPSA ${_getNumber(n - 20)}';
    if (n == 30) return 'HĀREPSA';
    if (n < 40) return 'HĀREPSA ${_getNumber(n - 30)}';
    if (n == 40) return 'IZULEPSA';
    if (n < 50) return 'IZULEPSA ${_getNumber(n - 40)}';
    if (n == 50) return 'TŌMEPSA';
    if (n < 60) return 'TŌMEPSA ${_getNumber(n - 50)}';

    return '';
  }
}
