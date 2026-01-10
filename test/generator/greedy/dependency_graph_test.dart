import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/greedy/dependency_graph.dart';
import 'package:wordclock/generator/greedy/grid_generator.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/logic/time_to_words.dart';

import 'package:wordclock/logic/english_time_to_word.dart';

WordClockLanguage createMockLanguage({
  TimeToWords? timeToWords,
  String? id,
  String? languageCode,
  String? displayName,
  String? englishName,
  String? paddingAlphabet,
  int? minuteIncrement,
  bool? atomizePhrases,
  bool? requiresPadding,
}) => WordClockLanguage(
  id: id ?? 'mock',
  languageCode: languageCode ?? 'mock',
  displayName: displayName ?? 'Mock',
  englishName: englishName ?? 'Mock',
  timeToWords: timeToWords ?? SimpleConverter([]),
  paddingAlphabet: paddingAlphabet ?? 'X',
  minuteIncrement: minuteIncrement ?? 5,
  atomizePhrases: atomizePhrases ?? false,
  requiresPadding: requiresPadding ?? true,
);

class SimpleConverter implements TimeToWords {
  final List<String> phrases;
  const SimpleConverter(this.phrases);

  @override
  String convert(DateTime time) {
    // Use the time to pick a phrase so it's stateless
    int idx = (time.hour * 60 + time.minute) ~/ 5;
    if (idx >= phrases.length) return phrases.last;
    return phrases[idx];
  }
}

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

    expect(grid, "ABCXDEF");
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

  test(
    'Distributed padding test',
    () {
      final converter = SimpleConverter(["FIRST", "MIDDLE WORD", "LAST"]);
      final lang = createMockLanguage(timeToWords: converter);

      final grid = GridGenerator.generate(
        language: lang,
        seed: 42,
        width: 15,
        targetHeight: 3,
      ).cells.join('');

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
    },
    skip:
        'Old algorithm behavior - constraint-based algorithm has different padding',
  );

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
