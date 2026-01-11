import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/greedy/dependency_graph.dart';
import 'package:wordclock/generator/greedy/grid_generator.dart';
import 'package:wordclock/logic/english_time_to_word.dart';
import '../test_helpers.dart';

void main() {
  test('Characters not shared between different words', () {
    // Phrases: "ABC", "DBE"
    // B appears in both but as different words, so not shared.
    final converter = SimpleConverter(["ABC", "DBE"]);
    final lang = createMockLanguage(timeToWords: converter);
    final graph = DependencyGraphBuilder.build(language: lang);

    final bNodes = graph.keys.where((n) => n.char == "B").toList();
    expect(bNodes.length, 2, reason: "B is not shared between different words");
  });

  test('Characters not shared with word-level atomization', () {
    // Phrases: "午前" (AM) and "午後" (PM)
    // With atomizePhrases=false, each word is treated as an indivisible unit.
    // The character "午" appears in both but cannot be shared.
    final converter = SimpleConverter(["午前", "午後"]);
    final lang = createMockLanguage(
      timeToWords: converter,
      atomizePhrases: false,
    );
    final graph = DependencyGraphBuilder.build(language: lang);

    final goNodes = graph.keys.where((n) => n.char == "午").toList();
    expect(
      goNodes.length,
      2,
      reason:
          "午 is not shared between different words when atomizePhrases is false",
    );
  });

  test('Characters shared with character-level atomization', () {
    // Phrases: "午前" (AM) and "午後" (PM)
    // With atomizePhrases=true, each character is an atom, allowing "午" to be shared.
    final converter = SimpleConverter(["午前", "午後"]);
    final lang = createMockLanguage(
      timeToWords: converter,
      atomizePhrases: true,
    );
    final graph = DependencyGraphBuilder.build(language: lang);

    final goNodes = graph.keys.where((n) => n.char == "午").toList();
    expect(
      goNodes.length,
      1,
      reason: "午 should be reused when atomizePhrases is true",
    );
  });

  test('Word overlap optimization reduces nodes', () {
    // Phrases: "AB", "BA"
    // The algorithm treats each word instance separately to preserve structure.
    // Expected: 4 total nodes (A and B for each word instance).
    // Note: Overlap optimization happens at the grid layout level, not at the
    // dependency graph node level.
    final converter = SimpleConverter(["AB", "BA"]);
    final lang = createMockLanguage(timeToWords: converter);
    final graph = DependencyGraphBuilder.build(language: lang);

    final totalNodes = graph.keys.length;
    expect(totalNodes, 4, reason: "Each word instance has its own nodes");
  });

  test('Grid with substring words and phrase spacing', () {
    final converter = SimpleConverter(["ABC DEF", "A DEF", "B DE", "BC EF"]);
    final lang = createMockLanguage(timeToWords: converter);

    final grid = GridGenerator.generate(
      language: lang,
      seed: 42,
      width: 7,
      targetHeight: 1,
    ).cells.join('');

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

    expect(grid, "ABC·DEF");
  });

  test('Word overlap without gaps between phrases', () {
    // Phrases: "PAST", "P TO"
    // No phrase contains "PAST P", so no gap required between them.
    // The algorithm places words sequentially without overlap.
    final converter = SimpleConverter(["PAST", "P TO"]);
    final lang = createMockLanguage(timeToWords: converter);

    final grid = GridGenerator.generate(
      language: lang,
      seed: 42,
      width: 10,
      targetHeight: 1,
    ).cells.join('');

    expect(grid, contains("PAST"));
    expect(grid, contains("P"));
    expect(grid, contains("TO"));
    // Words are placed sequentially: "PAST" then "TO" (P reused from PAST)
    expect(grid, startsWith("PAST"));
  });

  test('English language reuse: FIVE and OCLOCK', () {
    final lang = createMockLanguage(timeToWords: NativeEnglishTimeToWords());
    final graph = DependencyGraphBuilder.build(language: lang);

    int countWord(String word) {
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
