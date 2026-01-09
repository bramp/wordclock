import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/backtracking/grid_builder.dart';
import 'package:wordclock/generator/backtracking/grid_state.dart';
import 'package:wordclock/generator/backtracking/graph/graph_builder.dart';
import 'package:wordclock/generator/backtracking/graph/word_node.dart';
import 'graph/test_helpers.dart';

/// Helper to place a word and update the trie cache (mimics what _solve does)
WordPlacement? placeWordWithCache(
  GridState state,
  WordNode node,
  int row,
  int col,
) {
  final placement = state.placeWord(node, row, col);
  if (placement != null) {
    // Update trie cache: set end offset on all trie nodes this word owns
    final endOffset = placement.row * state.width + placement.endCol;
    for (final trieNode in node.ownedTrieNodes) {
      trieNode.cachedEndOffset = endOffset;
    }
  }
  return placement;
}

/// Helper to convert 1D offset to (row, col)
(int row, int col) offsetToRowCol(int offset, int width) {
  if (offset == -1) return (-1, -1);
  return (offset ~/ width, offset % width);
}

void main() {
  group('_findEarliestPlacementByPhrase', () {
    group('single phrase scenarios', () {
      test('first word in phrase can start at (0,0)', () {
        // Phrase: "A B" - placing A (no predecessors)
        final language = createMockLanguage(
          id: 'T1',
          phrases: ['A B'],
          requiresPadding: false,
        );

        final builder = BacktrackingGridBuilder(
          width: 5,
          height: 3,
          language: language,
          seed: 0,
        );

        // Build graph to get the nodes
        final graph = WordDependencyGraphBuilder.build(language: language);
        builder.graph = graph;
        builder.codec = graph.codec;

        final state = GridState(width: 5, height: 3, codec: graph.codec);
        final nodeA = graph.nodes['A']!.first;

        final offset = builder.findEarliestPlacementByPhrase(state, nodeA);
        final (row, col) = offsetToRowCol(offset, 5);

        expect(row, 0);
        expect(col, 0);
      });

      test('second word must come after first word', () {
        // Phrase: "A B" - placing B after A is at (0, 0)
        final language = createMockLanguage(
          id: 'T2',
          phrases: ['A B'],
          requiresPadding: false,
        );

        final builder = BacktrackingGridBuilder(
          width: 5,
          height: 3,
          language: language,
          seed: 0,
        );

        final graph = WordDependencyGraphBuilder.build(language: language);
        builder.graph = graph;
        builder.codec = graph.codec;

        final state = GridState(width: 5, height: 3, codec: graph.codec);
        final nodeA = graph.nodes['A']!.first;
        final nodeB = graph.nodes['B']!.first;

        // Place A at (0, 0)
        placeWordWithCache(state, nodeA, 0, 0);

        final offset = builder.findEarliestPlacementByPhrase(state, nodeB);
        final (row, col) = offsetToRowCol(offset, 5);

        // B should come after A which ends at col 0
        expect(row, 0);
        expect(col, 1); // Immediately after A
      });

      test('respects padding requirement', () {
        // Phrase: "A B" - placing B after A with padding required
        final language = createMockLanguage(
          id: 'T3',
          phrases: ['A B'],
          requiresPadding: true,
        );

        final builder = BacktrackingGridBuilder(
          width: 5,
          height: 3,
          language: language,
          seed: 0,
        );

        final graph = WordDependencyGraphBuilder.build(language: language);
        builder.graph = graph;
        builder.codec = graph.codec;

        final state = GridState(width: 5, height: 3, codec: graph.codec);
        final nodeA = graph.nodes['A']!.first;
        final nodeB = graph.nodes['B']!.first;

        // Place A at (0, 0)
        placeWordWithCache(state, nodeA, 0, 0);

        final offset = builder.findEarliestPlacementByPhrase(state, nodeB);
        final (row, col) = offsetToRowCol(offset, 5);

        // B should come after A with 1 cell padding
        // A ends at col 0, so B starts at col 2 (col 1 is padding)
        expect(row, 0);
        expect(col, 2);
      });

      test('third word must come after second word', () {
        // Phrase: "A B C" - placing C after A and B
        final language = createMockLanguage(
          id: 'T4',
          phrases: ['A B C'],
          requiresPadding: false,
        );

        final builder = BacktrackingGridBuilder(
          width: 10,
          height: 3,
          language: language,
          seed: 0,
        );

        final graph = WordDependencyGraphBuilder.build(language: language);
        builder.graph = graph;
        builder.codec = graph.codec;

        final state = GridState(width: 10, height: 3, codec: graph.codec);
        final nodeA = graph.nodes['A']!.first;
        final nodeB = graph.nodes['B']!.first;
        final nodeC = graph.nodes['C']!.first;

        // Place A at (0, 0), B at (0, 2)
        placeWordWithCache(state, nodeA, 0, 0);
        placeWordWithCache(state, nodeB, 0, 2);

        final offset = builder.findEarliestPlacementByPhrase(state, nodeC);
        final (row, col) = offsetToRowCol(offset, 10);

        // C should come after B which ends at col 2
        expect(row, 0);
        expect(col, 3);
      });
    });

    group('duplicate word scenarios', () {
      test('second instance of word must come after first instance', () {
        // Phrase: "A A" - placing second A after first A
        final language = createMockLanguage(
          id: 'T5',
          phrases: ['A A'],
          requiresPadding: false,
        );

        final builder = BacktrackingGridBuilder(
          width: 5,
          height: 3,
          language: language,
          seed: 0,
        );

        final graph = WordDependencyGraphBuilder.build(language: language);
        builder.graph = graph;
        builder.codec = graph.codec;

        final state = GridState(width: 5, height: 3, codec: graph.codec);

        // Get both instances of A
        final nodesA = graph.nodes['A']!;
        expect(nodesA.length, 2);

        final nodeA0 = nodesA.firstWhere((n) => n.instance == 0);
        final nodeA1 = nodesA.firstWhere((n) => n.instance == 1);

        // Place first A at (0, 0)
        placeWordWithCache(state, nodeA0, 0, 0);

        final offset = builder.findEarliestPlacementByPhrase(state, nodeA1);
        final (row, col) = offsetToRowCol(offset, 5);

        // Second A should come after first A which ends at col 0
        expect(row, 0);
        expect(col, 1);
      });

      test('handles "JE DESET DESET" pattern', () {
        // Phrase: "JE DESET DESET" - placing second DESET
        final language = createMockLanguage(
          id: 'T6',
          phrases: ['JE DESET DESET'],
          requiresPadding: false,
        );

        final builder = BacktrackingGridBuilder(
          width: 20,
          height: 3,
          language: language,
          seed: 0,
        );

        final graph = WordDependencyGraphBuilder.build(language: language);
        builder.graph = graph;
        builder.codec = graph.codec;

        final state = GridState(width: 20, height: 3, codec: graph.codec);

        final nodeJE = graph.nodes['JE']!.first;
        final nodesDESET = graph.nodes['DESET']!;
        expect(nodesDESET.length, 2);

        final nodeDESET0 = nodesDESET.firstWhere((n) => n.instance == 0);
        final nodeDESET1 = nodesDESET.firstWhere((n) => n.instance == 1);

        // Place JE at (0, 0), first DESET at (0, 3)
        placeWordWithCache(state, nodeJE, 0, 0); // JE ends at col 1
        placeWordWithCache(state, nodeDESET0, 0, 3); // DESET ends at col 7

        final offset = builder.findEarliestPlacementByPhrase(state, nodeDESET1);
        final (row, col) = offsetToRowCol(offset, 20);

        // Second DESET should come after first DESET which ends at col 7
        expect(row, 0);
        expect(col, 8);
      });
    });

    group('multiple phrase scenarios', () {
      test('uses max end position across all phrases', () {
        // Phrases: "A B C", "D E C" - C appears in both
        // If B ends at col 2 and E ends at col 5, C should start after col 5
        final language = createMockLanguage(
          id: 'T7',
          phrases: ['A B C', 'D E C'],
          requiresPadding: false,
        );

        final builder = BacktrackingGridBuilder(
          width: 20,
          height: 3,
          language: language,
          seed: 0,
        );

        final graph = WordDependencyGraphBuilder.build(language: language);
        builder.graph = graph;
        builder.codec = graph.codec;

        final state = GridState(width: 20, height: 3, codec: graph.codec);

        final nodeA = graph.nodes['A']!.first;
        final nodeB = graph.nodes['B']!.first;
        final nodeD = graph.nodes['D']!.first;
        final nodeE = graph.nodes['E']!.first;
        final nodeC = graph.nodes['C']!.first;

        // Place words: A at 0, B at 2, D at 4, E at 6
        placeWordWithCache(state, nodeA, 0, 0); // A ends at 0
        placeWordWithCache(state, nodeB, 0, 2); // B ends at 2
        placeWordWithCache(state, nodeD, 0, 4); // D ends at 4
        placeWordWithCache(state, nodeE, 0, 6); // E ends at 6

        final offset = builder.findEarliestPlacementByPhrase(state, nodeC);
        final (row, col) = offsetToRowCol(offset, 20);

        // C should come after the MAX of (B's end=2, E's end=6) = 6
        expect(row, 0);
        expect(col, 7);
      });

      test('handles word on different rows across phrases', () {
        // If phrase 1 has predecessor ending at row 0, col 5
        // and phrase 2 has predecessor ending at row 1, col 2
        // The max is row 1, col 2 (reading order)
        final language = createMockLanguage(
          id: 'T8',
          phrases: ['A B C', 'D E C'],
          requiresPadding: false,
        );

        final builder = BacktrackingGridBuilder(
          width: 10,
          height: 5,
          language: language,
          seed: 0,
        );

        final graph = WordDependencyGraphBuilder.build(language: language);
        builder.graph = graph;
        builder.codec = graph.codec;

        final state = GridState(width: 10, height: 5, codec: graph.codec);

        final nodeA = graph.nodes['A']!.first;
        final nodeB = graph.nodes['B']!.first;
        final nodeD = graph.nodes['D']!.first;
        final nodeE = graph.nodes['E']!.first;
        final nodeC = graph.nodes['C']!.first;

        // Phrase 1: A at row 0, B at row 0 col 5
        placeWordWithCache(state, nodeA, 0, 0); // A ends at (0, 0)
        placeWordWithCache(state, nodeB, 0, 5); // B ends at (0, 5)

        // Phrase 2: D at row 1, E at row 1 col 2
        placeWordWithCache(state, nodeD, 1, 0); // D ends at (1, 0)
        placeWordWithCache(state, nodeE, 1, 2); // E ends at (1, 2)

        final offset = builder.findEarliestPlacementByPhrase(state, nodeC);
        final (row, col) = offsetToRowCol(offset, 10);

        // Max in reading order: (0, 5) vs (1, 2) -> (1, 2) is later
        expect(row, 1);
        expect(col, 3);
      });
    });

    group('edge cases', () {
      test('returns (-1, -1) if predecessor not found', () {
        // Phrase: "A B" - trying to place B but A is not on grid
        final language = createMockLanguage(
          id: 'T9',
          phrases: ['A B'],
          requiresPadding: false,
        );

        final builder = BacktrackingGridBuilder(
          width: 5,
          height: 3,
          language: language,
          seed: 0,
        );

        final graph = WordDependencyGraphBuilder.build(language: language);
        builder.graph = graph;
        builder.codec = graph.codec;

        final state = GridState(width: 5, height: 3, codec: graph.codec);
        final nodeB = graph.nodes['B']!.first;

        // Don't place A - B should not be placeable
        final offset = builder.findEarliestPlacementByPhrase(state, nodeB);
        final (row, col) = offsetToRowCol(offset, 5);

        expect(row, -1);
        expect(col, -1);
      });

      test('wraps to next row when no space on current row', () {
        // Grid width is 3, word B is 2 chars, A ends at col 1
        // B can't fit at col 2 (only 1 cell left), so goes to row 1
        final language = createMockLanguage(
          id: 'T10',
          phrases: ['A BB'],
          requiresPadding: false,
        );

        final builder = BacktrackingGridBuilder(
          width: 3,
          height: 5,
          language: language,
          seed: 0,
        );

        final graph = WordDependencyGraphBuilder.build(language: language);
        builder.graph = graph;
        builder.codec = graph.codec;

        final state = GridState(width: 3, height: 5, codec: graph.codec);
        final nodeA = graph.nodes['A']!.first;
        final nodeBB = graph.nodes['BB']!.first;

        // Place A at (0, 1) - A ends at col 1
        placeWordWithCache(state, nodeA, 0, 1);

        final offset = builder.findEarliestPlacementByPhrase(state, nodeBB);
        final (row, col) = offsetToRowCol(offset, 3);

        // BB needs to start after col 1, but only col 2 is available on row 0
        // BB needs 2 cells, so it wraps to row 1
        expect(row, 1);
        expect(col, 0);
      });
    });
  });
}
