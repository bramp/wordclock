import 'package:wordclock/logic/time_to_words.dart';

/// Klingon (tlhIngan Hol) time telling.
///
/// Uses standard "military time" format as is common in Klingon (Hours: Rep, Minutes: Tup).
///
/// This implementation internally uses **xifan hol** (a 1-to-1 ASCII mapping) to represent
/// Klingon characters. This simplifies the conversion to pIqaD (CSUR PUA) as we avoid
/// complex digraph parsing (e.g., 'tlh', 'ng').
///
/// **Mapping Table:**
///
/// | Latin (Standard) | xifan hol | pIqaD (CSUR PUA) | Note |
/// | :--- | :--- | :--- | :--- |
/// | a | a | U+F8D0 | |
/// | b | b | U+F8D1 | |
/// | ch | c | U+F8D2 | Digraph in standard |
/// | D | d | U+F8D3 | |
/// | e | e | U+F8D4 | |
/// | gh | g | U+F8D5 | Digraph in standard |
/// | H | h | U+F8D6 | |
/// | I | I | U+F8D7 | Upper 'I' in standard |
/// | j | j | U+F8D8 | |
/// | l | l | U+F8D9 | |
/// | m | m | U+F8DA | |
/// | n | n | U+F8DB | |
/// | ng | f | U+F8DC | Digraph in standard |
/// | o | o | U+F8DD | |
/// | p | p | U+F8DE | |
/// | q | q | U+F8DF | Lowercase 'q' |
/// | Q | k | U+F8E0 | Uppercase 'Q' (uvular) |
/// | r | r | U+F8E1 | |
/// | S | S | U+F8E2 | |
/// | t | t | U+F8E3 | |
/// | tlh | x | U+F8E4 | Trigraph in standard |
/// | u | u | U+F8E5 | |
/// | v | v | U+F8E6 | |
/// | w | w | U+F8E7 | |
/// | y | y | U+F8E8 | |
/// | ' | z | U+F8E9 | Glottal stop |
/// | 0-9 | 0-9 | U+F8F0-9 | Digits |
///
/// Reference: http://klingonska.org/piqad/
class KlingonTimeToWords extends TimeToWords {
  final bool usePiqad;

  const KlingonTimeToWords({this.usePiqad = false});

  @override
  String convert(DateTime time) {
    // 12-hour format for now to fit standard clock faces better,
    // though Klingon speakers often use 24-hour.
    // However, 24-hour would require numbers 13-24 (wa'maH wej ... cha'maH loS).
    // Let's stick to 12h for simplicity on the grid.
    int hour = time.hour;
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;

    final minute = time.minute;

    final hourWord = _getNumber(hour);
    final minuteWord = minute == 0 ? '' : _getNumber(minute);

    final buffer = StringBuffer();
    // "rep" = hour/o'clock. Standard: rep. xifan: rep.
    buffer.write('$hourWord rep');

    if (minute != 0) {
      // "tup" = minute. Standard: tup. xifan: tup.
      buffer.write(' $minuteWord tup');
    }

    if (usePiqad) {
      return _toPiqad(buffer.toString());
    }
    return buffer.toString();
  }

  String _getNumber(int n) {
    if (n <= 0) return '';
    if (n <= 9) return _digits[n]!;
    if (n == 10) return 'wazmah';
    if (n < 20) return 'wazmah ${_digits[n % 10]}';

    // 20-99
    final ten = n ~/ 10;
    final unit = n % 10;
    final tenWord = '${_digits[ten]}mah';
    if (unit == 0) return tenWord;
    return '$tenWord ${_digits[unit]}';
  }

  // Uses xifan-hol mapping (one char per sound) to resolve digraphs.
  // ch -> c
  // gh -> g
  // ng -> f
  // tlh -> x
  // ' -> z
  // Q -> k
  static const _digits = {
    1: 'waz', // wa'
    2: 'caz', // cha'
    3: 'wej', // wej
    4: 'loS', // loS
    5: 'vag', // vagh
    6: 'jav', // jav
    7: 'Soc', // Soch
    8: 'corg', // chorgh
    9: 'hut', // Hut -> hut (xifan often lowercases H)
  };

  /// Converts a xifan hol string to pIqaD (CSUR PUA).
  ///
  /// Since xifan hol uses 1-to-1 mapping for phonemes, we just map characters.
  String _toPiqad(String text) {
    final sb = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      // Check exact match (case sensitive for xifan)
      if (_xifanToPiqadMap.containsKey(char)) {
        sb.write(_xifanToPiqadMap[char]);
      } else {
        sb.write(char);
      }
    }
    return sb.toString();
  }

  // Mapping from xifan hol chars to pIqaD (CSUR PUA).
  static const Map<String, String> _xifanToPiqadMap = {
    'a': '\uF8D0',
    'b': '\uF8D1',
    'c': '\uF8D2', // ch
    'd': '\uF8D3', // D
    'e': '\uF8D4',
    'g': '\uF8D5', // gh
    'h': '\uF8D6', // H
    'I': '\uF8D7',
    'j': '\uF8D8',
    'l': '\uF8D9',
    'm': '\uF8DA',
    'n': '\uF8DB',
    'f': '\uF8DC', // ng
    'o': '\uF8DD',
    'p': '\uF8DE',
    'q': '\uF8DF', // q
    'k': '\uF8E0', // Q
    'r': '\uF8E1',
    'S': '\uF8E2',
    't': '\uF8E3',
    'x': '\uF8E4', // tlh
    'u': '\uF8E5',
    'v': '\uF8E6',
    'w': '\uF8E7',
    'y': '\uF8E8',
    'z': '\uF8E9', // '
    '0': '\uF8F0',
    '1': '\uF8F1',
    '2': '\uF8F2',
    '3': '\uF8F3',
    '4': '\uF8F4',
    '5': '\uF8F5',
    '6': '\uF8F6',
    '7': '\uF8F7',
    '8': '\uF8F8',
    '9': '\uF8F9',
  };
}
