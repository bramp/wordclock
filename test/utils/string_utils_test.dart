import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/utils/string_utils.dart';

void main() {
  group('WordClockStringExtension.glyphs', () {
    test('splits standard English strings', () {
      expect('HELLO'.glyphs.toList(), ['H', 'E', 'L', 'L', 'O']);
    });

    test('merges Tengwar Tehtar (PUA range E040-E05F)', () {
      // LEBEN: 
      //  (L)
      //  +  (B + E-tehta)
      //  +  (N + E-tehta)
      final glyphs = ''.glyphs.toList();
      expect(glyphs, ['', '', '']);
      expect(glyphs.length, 3);
    });

    test('handles standard Unicode combining marks via characters package', () {
      // 'e' + accent (U+0301)
      final text = 'e\u0301';
      expect(text.glyphs.toList(), [text]);
      expect(text.glyphs.length, 1);
    });

    test('handles Tamil characters (grapheme clusters)', () {
      // "தமிழ்" (Tamil)
      // த (U+0BA4)
      // மி (U+0BAE, U+0BBF)
      // ழ் (U+0BB4, U+0BCD)
      expect('தமிழ்'.glyphs.toList(), ['த', 'மி', 'ழ்']);

      // "மணி" (Hour/Time)
      // ம (U+0BAE)
      // ணி (U+0BA3, U+0BBF)
      expect('மணி'.glyphs.toList(), ['ம', 'ணி']);

      // "பன்னிரண்டு" (Twelve)
      // ப, ன், னி, ர, ண், டு
      expect('பன்னிரண்டு'.glyphs.toList(), ['ப', 'ன்', 'னி', 'ர', 'ண்', 'டு']);
    });
  });

  group('WordClockStringExtension helpers', () {
    test('isApostrophe', () {
      expect("'".isApostrophe(), isTrue);
      expect("’".isApostrophe(), isTrue);
      expect("A".isApostrophe(), isFalse);
    });

    test('isTengwarTehta', () {
      expect("".isTengwarTehta(), isTrue); // E046
      expect("".isTengwarTehta(), isTrue); // E040
      expect("".isTengwarTehta(), isFalse); // E022
    });
  });
}
