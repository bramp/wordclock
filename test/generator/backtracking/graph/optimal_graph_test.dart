import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/backtracking/graph/graph_builder.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/logic/time_to_words.dart';

void main() {
  group('WordDependencyGraphBuilder Optimal Node Count', () {
    test('simple phrases with no shared words should have optimal nodes', () {
      // 3 phrases, no shared words = 9 unique words = 9 nodes
      final language = _createMockLanguage([
        'A B C',
        'D E F',
        'G H I',
      ]);

      final graph = WordDependencyGraphBuilder.build(language: language);
      final nodeCount = graph.nodes.values.fold(0, (s, l) => s + l.length);

      expect(nodeCount, equals(9), reason: 'Should have exactly 9 nodes');
    });

    test('phrases with shared prefix should reuse nodes', () {
      // "IT IS ONE" and "IT IS TWO" share "IT IS"
      // Optimal: IT, IS, ONE, TWO = 4 nodes
      final language = _createMockLanguage([
        'IT IS ONE',
        'IT IS TWO',
      ]);

      final graph = WordDependencyGraphBuilder.build(language: language);
      final nodeCount = graph.nodes.values.fold(0, (s, l) => s + l.length);

      expect(nodeCount, equals(4), reason: 'Should reuse IT and IS');
    });

    test('phrases with shared suffix should reuse nodes', () {
      // "ONE OCLOCK" and "TWO OCLOCK" share "OCLOCK"
      // Optimal: ONE, TWO, OCLOCK = 3 nodes
      final language = _createMockLanguage([
        'ONE OCLOCK',
        'TWO OCLOCK',
      ]);

      final graph = WordDependencyGraphBuilder.build(language: language);
      final nodeCount = graph.nodes.values.fold(0, (s, l) => s + l.length);

      expect(nodeCount, equals(3), reason: 'Should reuse OCLOCK');
    });

    test('word appearing twice in same phrase needs two nodes', () {
      // "FIVE PAST FIVE" has FIVE twice
      // Optimal: FIVE, PAST, FIVE#1 = 3 nodes (2 for FIVE)
      final language = _createMockLanguage([
        'FIVE PAST FIVE',
      ]);

      final graph = WordDependencyGraphBuilder.build(language: language);
      final nodeCount = graph.nodes.values.fold(0, (s, l) => s + l.length);

      expect(nodeCount, equals(3));
      expect(graph.nodes['FIVE']?.length, equals(2));
    });

    test('diamond pattern should not create extra nodes', () {
      // A -> B -> D
      // A -> C -> D
      // Optimal: A, B, C, D = 4 nodes
      final language = _createMockLanguage([
        'A B D',
        'A C D',
      ]);

      final graph = WordDependencyGraphBuilder.build(language: language);
      final nodeCount = graph.nodes.values.fold(0, (s, l) => s + l.length);

      expect(nodeCount, equals(4), reason: 'Diamond pattern should reuse A and D');
    });

    test('cycle-inducing pattern requires extra node', () {
      // A -> B and B -> A would create cycle
      // But "A B" and "B A" need: A, B, A#1 or A, B, B#1 = 3 nodes minimum
      final language = _createMockLanguage([
        'A B',
        'B A',
      ]);

      final graph = WordDependencyGraphBuilder.build(language: language);
      final nodeCount = graph.nodes.values.fold(0, (s, l) => s + l.length);

      // Theoretical optimal is 2 (A appears once per phrase, B appears once per phrase)
      // But cycle constraint requires 3 nodes
      expect(nodeCount, equals(3), reason: 'Cycle prevention needs extra node');
    });

    test('Czech-like pattern with duplicate word in phrase', () {
      // Similar to CZ: "JE PĚT" and "JE PĚT NULA PĚT"
      // PĚT appears twice in second phrase
      // Optimal: JE, PĚT, NULA, PĚT#1 = 4 nodes
      final language = _createMockLanguage([
        'JE PET',
        'JE PET NULA PET',
      ]);

      final graph = WordDependencyGraphBuilder.build(language: language);
      final nodeCount = graph.nodes.values.fold(0, (s, l) => s + l.length);

      expect(nodeCount, equals(4));
      expect(graph.nodes['PET']?.length, equals(2));
    });

    test('complex shared middle should be optimal', () {
      // A -> X -> B
      // C -> X -> D
      // Optimal: A, X, B, C, D = 5 nodes (X shared)
      final language = _createMockLanguage([
        'A X B',
        'C X D',
      ]);

      final graph = WordDependencyGraphBuilder.build(language: language);
      final nodeCount = graph.nodes.values.fold(0, (s, l) => s + l.length);

      expect(nodeCount, equals(5), reason: 'X should be shared');
      expect(graph.nodes['X']?.length, equals(1));
    });

    test('Catalan-like pattern with CINC appearing in different positions', () {
      // Simplified CA pattern:
      // "SON LES CINC" - CINC at end
      // "CINC DE SET" - CINC at start  
      // "SON LES CINC I CINC" - CINC twice
      final language = _createMockLanguage([
        'SON LES CINC',
        'CINC DE SET',
        'SON LES CINC I CINC',
      ]);

      final graph = WordDependencyGraphBuilder.build(language: language);
      final nodeCount = graph.nodes.values.fold(0, (s, l) => s + l.length);

      // Words: SON, LES, CINC, DE, SET, I, CINC#1 = 7 minimum
      // But cycle constraint: LES->CINC and CINC->DE means we can't have CINC->I->CINC
      // So we need CINC#1 for the second occurrence = 7 nodes
      expect(nodeCount, lessThanOrEqualTo(8));
      expect(graph.nodes['CINC']?.length, equals(2));
    });
  });
}

/// Helper to create a mock language with specific phrases
// TODO We have _createMockLanguage in a few tests now. Dedup and put in a utils.
WordClockLanguage _createMockLanguage(List<String> phrases) {
  return WordClockLanguage(
    id: 'TEST',
    languageCode: 'test',
    displayName: 'Test',
    englishName: 'Test',
    timeToWords: _SimpleConverter(phrases),
    paddingAlphabet: 'X',
    minuteIncrement: 5,
    atomizePhrases: false,
    requiresPadding: true,
  );
}

// TODO We have _SimpleConverter in a few tests now. Dedup and put in a utils.
class _SimpleConverter implements TimeToWords {
  final List<String> phrases;
  const _SimpleConverter(this.phrases);

  @override
  String convert(DateTime time) {
    // Use the time to pick a phrase so each phrase gets used
    int idx = (time.hour * 60 + time.minute) ~/ 5;
    if (phrases.isEmpty) return '';
    return phrases[idx % phrases.length];
  }
}
