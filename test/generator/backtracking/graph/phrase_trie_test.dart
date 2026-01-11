import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/backtracking/graph/phrase_trie.dart';
import '../../test_helpers.dart';

void main() {
  group('PhraseTrie.fromPhrases', () {
    test('builds empty trie from empty phrases', () {
      final language = createMockLanguage();
      final trie = PhraseTrie.fromPhrases([], language);
      expect(trie.roots, isEmpty);
    });

    test('adds single word phrases as roots', () {
      final language = createMockLanguage();
      final trie = PhraseTrie.fromPhrases(['HELLO', 'WORLD'], language);

      expect(trie.roots.keys, containsAll(['HELLO', 'WORLD']));
      expect(trie.roots['HELLO']!.children, isEmpty);
      expect(trie.roots['WORLD']!.children, isEmpty);
    });

    test('builds paths for multi-word phrases', () {
      final language = createMockLanguage();
      // Mock language tokenizer splits by space by default
      final trie = PhraseTrie.fromPhrases(['IT IS FIVE'], language);

      expect(trie.roots.keys, ['IT']);
      final itNode = trie.roots['IT']!;
      expect(itNode.children.keys, ['IS']);
      final isNode = itNode.children['IS']!;
      expect(isNode.children.keys, ['FIVE']);
      final fiveNode = isNode.children['FIVE']!;
      expect(fiveNode.children, isEmpty);
    });

    test('deduplicates common prefixes', () {
      final language = createMockLanguage();
      final trie = PhraseTrie.fromPhrases([
        'IT IS FIVE',
        'IT IS TEN',
        'HALF PAST',
      ], language);

      expect(trie.roots.keys, containsAll(['IT', 'HALF']));

      final itNode = trie.roots['IT']!;
      expect(itNode.children.keys, ['IS']);

      final isNode = itNode.children['IS']!;
      expect(isNode.children.keys, containsAll(['FIVE', 'TEN']));

      final halfNode = trie.roots['HALF']!;
      expect(halfNode.children.keys, ['PAST']);
    });

    test('handles overlapping phrases of different lengths', () {
      final language = createMockLanguage();
      final trie = PhraseTrie.fromPhrases(['IT IS', 'IT IS FIVE'], language);

      final itNode = trie.roots['IT']!;
      final isNode = itNode.children['IS']!;
      expect(isNode.children.keys, ['FIVE']);
    });

    test('ignores empty phrases', () {
      final language = createMockLanguage();
      final trie = PhraseTrie.fromPhrases(['', '  '], language);
      expect(trie.roots, isEmpty);
    });

    test('handles atomizePhrases = true', () {
      final language = createMockLanguage(atomizePhrases: true);
      // 'IT IS' -> 'I', 'T', 'I', 'S'
      final trie = PhraseTrie.fromPhrases(['IT IS'], language);

      expect(trie.roots.keys, ['I']);
      final iNode = trie.roots['I']!;
      expect(iNode.children.keys, ['T']);
      final tNode = iNode.children['T']!;
      expect(tNode.children.keys, ['I']);
      final iNode2 = tNode.children['I']!;
      expect(iNode2.children.keys, ['S']);
    });
  });
}
