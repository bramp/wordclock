import 'package:flutter_test/flutter_test.dart';
import '../../bin/cli.dart';

void main() {
  group('CLI Alignment Utilities', () {
    test('isWide identifies CJK but not Latin Extended', () {
      // Latin Extended-A (Polish Ł, Ą)
      expect(isWide('Ł'.runes.first), isFalse);
      expect(isWide('Ą'.runes.first), isFalse);

      // Latin Extended Additional (German ß)
      expect(isWide('ẞ'.runes.first), isFalse);
      expect(isWide('ß'.runes.first), isFalse);

      // CJK Unified Ideographs (Japanese)
      expect(isWide('時'.runes.first), isTrue);
      expect(isWide('日'.runes.first), isTrue);

      // Katakana
      expect(isWide('カ'.runes.first), isTrue);
    });

    test('needsWideMode detects CJK strings correctly', () {
      expect(needsWideMode(['English text']), isFalse);
      expect(needsWideMode(['Polskie znaki: ŁĄĆŹŻ']), isFalse);
      expect(needsWideMode(['Deutsche Wörter: ẞ, Ü, Ö, Ä']), isFalse);
      expect(needsWideMode(['日本語']), isTrue);
    });
  });
}
