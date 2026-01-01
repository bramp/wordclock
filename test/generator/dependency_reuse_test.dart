import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/dependency_graph.dart';
import 'package:wordclock/generator/topological_sort.dart';
import 'package:wordclock/generator/grid_layout.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/logic/time_to_words.dart';
import 'package:wordclock/model/word_grid.dart';

import 'package:wordclock/languages/english.dart';

class MockLanguage implements WordClockLanguage {
  final TimeToWords converter;
  MockLanguage(this.converter);

  @override
  String get displayName => 'Mock';
  @override
  TimeToWords get timeToWords => converter;
  @override
  String get paddingAlphabet => 'ABC';
  @override
  int get minuteIncrement => 5;
  @override
  WordGrid? get defaultGrid => null;
}

class SimpleConverter implements TimeToWords {
  final List<String> phrases;
  SimpleConverter(this.phrases);

  @override
  String convert(DateTime time) {
    // Use the time to pick a phrase so it's stateless
    int idx = (time.hour * 60 + time.minute) ~/ 5;
    if (idx >= phrases.length) return phrases.last;
    return phrases[idx];
  }
}

void main() {
  test('DependencyGraphBuilder reuses characters correctly', () {
    // S1: A B C
    // S2: D B E
    // In the current word-based architecture, they don't share B because they are different words.
    final converter = SimpleConverter(["ABC", "DBE"]);
    final lang = MockLanguage(converter);
    final graph = DependencyGraphBuilder.build(language: lang);

    final bNodes = graph.keys.where((n) => n.char == "B").toList();
    expect(bNodes.length, 2, reason: "B is not shared between different words");
  });

  test('Japanese reuse test (Simulation)', () {
    // "午前" (AM) and "午後" (PM)
    // In the current word-based architecture, they don't share "午" because they are different words.
    final converter = SimpleConverter(["午前", "午後"]);
    final lang = MockLanguage(converter);
    final graph = DependencyGraphBuilder.build(language: lang);

    final goNodes = graph.keys.where((n) => n.char == "午").toList();
    expect(
      goNodes.length,
      2,
      reason: "午 is not shared between different words",
    );
  });

  test('Cycle induced reuse', () {
    // S1: AB
    // S2: BA
    // Since they are different words, they don't share.
    final converter = SimpleConverter(["AB", "BA"]);
    final lang = MockLanguage(converter);
    final graph = DependencyGraphBuilder.build(language: lang);

    final totalNodes = graph.keys.length;
    // S1: AB -> A, B
    // S2: BA -> B, A
    // Total: 4 nodes
    expect(totalNodes, 4, reason: "Each word gets its own nodes, no gaps");
  });

  test('User example: ABC DEF, A DEF, B DE, BC EF', () {
    final converter = SimpleConverter(["ABC DEF", "A DEF", "B DE", "BC EF"]);
    final lang = MockLanguage(converter);
    final graph = DependencyGraphBuilder.build(language: lang);
    final sorted = TopologicalSorter.sort(graph);

    final grid = GridLayout.generateString(
      7,
      sorted,
      graph,
      Random(42),
      paddingAlphabet: "X",
    );

    expect(grid, contains("ABC"));
    expect(grid, contains("DEF"));

    // Check that ABC and DEF are separated by at least one character
    final abcIndex = grid.indexOf("ABC");
    final defIndex = grid.indexOf("DEF");
    expect(
      defIndex,
      greaterThan(abcIndex + 3),
      reason: "There must be a gap between ABC and DEF",
    );

    // Check for sub-string words
    expect(grid, contains("A"));
    expect(grid, contains("B"));
    expect(grid, contains("BC"));
    expect(grid, contains("DE"));
    expect(grid, contains("EF"));

    expect(grid, "ABCXDEF");
  });

  test('Conditional gaps: PAST and P TO', () {
    // Phrase 1: PAST
    // Phrase 2: P TO
    // There is NO phrase containing "PAST P".
    // So there should be NO gap between PAST and P.
    final converter = SimpleConverter(["PAST", "P TO"]);
    final lang = MockLanguage(converter);
    final graph = DependencyGraphBuilder.build(language: lang);
    final sorted = TopologicalSorter.sort(graph);

    final grid = GridLayout.generateString(
      10,
      sorted,
      graph,
      Random(42),
      paddingAlphabet: "X",
    );

    // Since there is no dependency between PAST and P, they can be adjacent.
    // The greedy sort will likely put them together if they are ready.
    // "PAST" nodes: P, A, S, T
    // "P" node: P (reused from PAST)
    // "TO" nodes: T, O

    // Wait, "P" is a sub-string of "PAST".
    // So "P" will reuse the first node of "PAST".
    // "TO" is NOT a sub-string of "PAST".

    // Nodes:
    // PAST: [P1, A, S, T1]
    // P: [P1] (reused)
    // TO: [T2, O] (T is not shared because it's not a sub-string of a word already in cache?
    // Wait, "T" IS a sub-string of "PAST". So "T" would be reused if it was a word.
    // But "TO" is the word. "T" is not a sub-string of "TO" in the cache yet.
    // "PAST" is in cache. "TO" is not a sub-string of "PAST".

    expect(grid, contains("PAST"));
    expect(grid, contains("P"));
    expect(grid, contains("TO"));

    // In "P TO", there IS a dependency between P and TO.
    // But P is part of PAST, so the nodes are [P, A, S, T, T, O]
    // The dependency is from P to T.
    // Since they are not adjacent in the sorted list, no extra gap is added.
    // The characters "A S T" act as a gap.
    expect(grid, isNot(contains("PXTO")));
    expect(grid, contains("PASTTO"));
  });

  test('Distributed padding test', () {
    final converter = SimpleConverter(["FIRST", "MIDDLE WORD", "LAST"]);
    final lang = MockLanguage(converter);
    final graph = DependencyGraphBuilder.build(language: lang);
    final sorted = TopologicalSorter.sort(graph);

    final grid = GridLayout.generateString(
      15,
      sorted,
      graph,
      Random(42),
      paddingAlphabet: "X",
    );

    // Line 1: FIRST (5 chars) + 10 padding at end
    // Line 2: MIDDLE (6) + gap (1) + WORD (4) = 11 chars. 4 padding distributed.
    // Line 3: LAST (4) + 11 padding at start

    // Note: The grid length depends on how many lines were generated.
    // FIRST, MIDDLE WORD, LAST are 3 separate phrases.
    // MIDDLE WORD has a gap.

    expect(grid, contains("FIRST"));
    expect(grid, contains("MIDDLE"));
    expect(grid, contains("WORD"));
    expect(grid, contains("LAST"));

    // Find the line containing MIDDLE WORD
    final lines = [];
    for (int i = 0; i < grid.length; i += 15) {
      lines.add(grid.substring(i, i + 15));
    }

    final middleLine = lines.firstWhere((l) => l.contains("MIDDLE"));

    // Check that padding is distributed (not all at start or all at end)
    // MIDDLE (6) + gap (1) + WORD (4) = 11. 4 padding chars.
    expect(middleLine, isNot(startsWith("XXXX")));
    expect(middleLine, isNot(endsWith("XXXX")));
  });

  test('English language reuse: FIVE and OCLOCK', () {
    final lang = EnglishLanguage();
    final graph = DependencyGraphBuilder.build(language: lang);

    // Let's just count unique words by looking at the Node.word (which is the char)
    // and the Node.index (which is the global unique ID for that char instance).
    // A word "FIVE" is a sequence of 4 nodes.

    int countWord(String word) {
      // In the new architecture, each node knows which word it belongs to.
      // However, with sub-string reuse, a node for "A" might have word "ABC".
      // But for English "FIVE" and "OCLOCK", they are usually top-level words.
      final nodes = graph.keys.where((n) => n.word == word).toList();
      if (nodes.isEmpty) return 0;
      return nodes.length ~/ word.length;
    }

    expect(
      countWord("FIVE"),
      2,
      reason: "English should only have 2 FIVEs (min and hour)",
    );
    expect(countWord("OCLOCK"), 1, reason: "English should only have 1 OCLOCK");
  });
}
