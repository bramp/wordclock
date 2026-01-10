import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/generator/backtracking/grid_builder.dart';
import 'package:wordclock/generator/backtracking/grid_state.dart';
import 'package:wordclock/generator/backtracking/graph/dependency_graph.dart';
import 'package:wordclock/generator/backtracking/graph/graph_builder.dart';
import 'package:wordclock/generator/backtracking/graph/word_node.dart';
import 'graph/test_helpers.dart';

/// Helper to set up builder with graph
void setupBuilder(BacktrackingGridBuilder builder, WordDependencyGraph graph) {
  builder.graph = graph;
  builder.codec = graph.codec;
}

/// Helper to place a word and update the trie cache (mimics what _solve does)
WordPlacement? placeWordWithCache(GridState state, WordNode node, int offset) {
  final placement = state.placeWord(node, offset);
  if (placement != null) {
    // Update trie cache with end offset
    final endOffset = offset + placement.length - 1;
    for (final trieNode in node.ownedTrieNodes) {
      trieNode.endOffset = endOffset;
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
        setupBuilder(builder, graph);

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
        setupBuilder(builder, graph);

        final state = GridState(width: 5, height: 3, codec: graph.codec);
        final nodeA = graph.nodes['A']!.first;
        final nodeB = graph.nodes['B']!.first;

        // Place A at (0, 0)
        placeWordWithCache(state, nodeA, 0);

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
        setupBuilder(builder, graph);

        final state = GridState(width: 5, height: 3, codec: graph.codec);
        final nodeA = graph.nodes['A']!.first;
        final nodeB = graph.nodes['B']!.first;

        // Place A at (0, 0)
        placeWordWithCache(state, nodeA, 0);

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
        setupBuilder(builder, graph);

        final state = GridState(width: 10, height: 3, codec: graph.codec);
        final nodeA = graph.nodes['A']!.first;
        final nodeB = graph.nodes['B']!.first;
        final nodeC = graph.nodes['C']!.first;

        // Place A at (0, 0), B at (0, 2)
        placeWordWithCache(state, nodeA, 0);
        placeWordWithCache(state, nodeB, 2);

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
        setupBuilder(builder, graph);

        final state = GridState(width: 5, height: 3, codec: graph.codec);

        // Get both instances of A
        final nodesA = graph.nodes['A']!;
        expect(nodesA.length, 2);

        final nodeA0 = nodesA.firstWhere((n) => n.instance == 0);
        final nodeA1 = nodesA.firstWhere((n) => n.instance == 1);

        // Place first A at (0, 0)
        placeWordWithCache(state, nodeA0, 0);

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
        setupBuilder(builder, graph);

        final state = GridState(width: 20, height: 3, codec: graph.codec);

        final nodeJE = graph.nodes['JE']!.first;
        final nodesDESET = graph.nodes['DESET']!;
        expect(nodesDESET.length, 2);

        final nodeDESET0 = nodesDESET.firstWhere((n) => n.instance == 0);
        final nodeDESET1 = nodesDESET.firstWhere((n) => n.instance == 1);

        // Place JE at (0, 0), first DESET at (0, 3)
        placeWordWithCache(state, nodeJE, 0); // JE ends at col 1
        placeWordWithCache(state, nodeDESET0, 3); // DESET ends at col 7

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
        setupBuilder(builder, graph);

        final state = GridState(width: 20, height: 3, codec: graph.codec);

        final nodeA = graph.nodes['A']!.first;
        final nodeB = graph.nodes['B']!.first;
        final nodeD = graph.nodes['D']!.first;
        final nodeE = graph.nodes['E']!.first;
        final nodeC = graph.nodes['C']!.first;

        // Place words: A at 0, B at 2, D at 4, E at 6
        placeWordWithCache(state, nodeA, 0); // A ends at 0
        placeWordWithCache(state, nodeB, 2); // B ends at 2
        placeWordWithCache(state, nodeD, 4); // D ends at 4
        placeWordWithCache(state, nodeE, 6); // E ends at 6

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
        setupBuilder(builder, graph);

        final state = GridState(width: 10, height: 5, codec: graph.codec);

        final nodeA = graph.nodes['A']!.first;
        final nodeB = graph.nodes['B']!.first;
        final nodeD = graph.nodes['D']!.first;
        final nodeE = graph.nodes['E']!.first;
        final nodeC = graph.nodes['C']!.first;

        // Phrase 1: A at row 0, B at row 0 col 5
        placeWordWithCache(state, nodeA, 0); // A ends at (0, 0)
        placeWordWithCache(state, nodeB, 5); // B ends at (0, 5)

        // Phrase 2: D at row 1, E at row 1 col 2
        placeWordWithCache(state, nodeD, 10); // D ends at (1, 0)
        placeWordWithCache(state, nodeE, 12); // E ends at (1, 2)

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
        setupBuilder(builder, graph);

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
        setupBuilder(builder, graph);

        final state = GridState(width: 3, height: 5, codec: graph.codec);
        final nodeA = graph.nodes['A']!.first;
        final nodeBB = graph.nodes['BB']!.first;

        // Place A at (0, 1) - A ends at col 1
        placeWordWithCache(state, nodeA, 1);

        final offset = builder.findEarliestPlacementByPhrase(state, nodeBB);
        final (row, col) = offsetToRowCol(offset, 3);

        // BB needs to start after col 1, but only col 2 is available on row 0
        // BB needs 2 cells, so it wraps to row 1
        expect(row, 1);
        expect(col, 0);
      });
    });
  });

  group('findFirstValidPlacement', () {
    group('boundary conditions', () {
      test('returns -1 when word cannot fit in grid', () {
        // Grid is 3x2 = 6 cells, word is 4 chars - won't fit on any row
        final language = createMockLanguage(
          id: 'BND1',
          phrases: ['ABCD'],
          requiresPadding: false,
        );

        final builder = BacktrackingGridBuilder(
          width: 3,
          height: 2,
          language: language,
          seed: 0,
        );

        final graph = WordDependencyGraphBuilder.build(language: language);
        setupBuilder(builder, graph);

        final state = GridState(width: 3, height: 2, codec: graph.codec);
        final nodeABCD = graph.nodes['ABCD']!.first;

        final offset = builder.findFirstValidPlacement(state, nodeABCD, 0);
        expect(offset, -1);
      });

      test('returns -1 when minOffset is past valid placement area', () {
        // Grid is 5x2 = 10 cells, word is 3 chars
        // maxOffset = 10 - 3 = 7, so minOffset=8 should return -1
        final language = createMockLanguage(
          id: 'BND2',
          phrases: ['ABC'],
          requiresPadding: false,
        );

        final builder = BacktrackingGridBuilder(
          width: 5,
          height: 2,
          language: language,
          seed: 0,
        );

        final graph = WordDependencyGraphBuilder.build(language: language);
        setupBuilder(builder, graph);

        final state = GridState(width: 5, height: 2, codec: graph.codec);
        final nodeABC = graph.nodes['ABC']!.first;

        // minOffset=8 is past maxOffset=7
        final offset = builder.findFirstValidPlacement(state, nodeABC, 8);
        expect(offset, -1);
      });

      test('finds placement at exact maxOffset boundary', () {
        // Grid is 5x2 = 10 cells, word is 3 chars
        // maxOffset = 10 - 3 = 7
        // Position 7 = row 1, col 2. Word occupies cols 2,3,4 - valid!
        final language = createMockLanguage(
          id: 'BND3',
          phrases: ['ABC'],
          requiresPadding: false,
        );

        final builder = BacktrackingGridBuilder(
          width: 5,
          height: 2,
          language: language,
          seed: 0,
        );

        final graph = WordDependencyGraphBuilder.build(language: language);
        setupBuilder(builder, graph);

        final state = GridState(width: 5, height: 2, codec: graph.codec);
        final nodeABC = graph.nodes['ABC']!.first;

        // Start search from offset 7 - should find it exactly there
        final offset = builder.findFirstValidPlacement(state, nodeABC, 7);
        final (row, col) = offsetToRowCol(offset, 5);

        expect(offset, 7);
        expect(row, 1);
        expect(col, 2);
      });
    });

    group('row-skip optimization', () {
      test('skips to next row when word does not fit on current row', () {
        // Grid is 5 wide, word is 3 chars
        // At col 3, word would need cols 3,4,5 but col 5 doesn't exist
        // Should skip to next row
        final language = createMockLanguage(
          id: 'SKIP1',
          phrases: ['ABC'],
          requiresPadding: false,
        );

        final builder = BacktrackingGridBuilder(
          width: 5,
          height: 3,
          language: language,
          seed: 0,
        );

        final graph = WordDependencyGraphBuilder.build(language: language);
        setupBuilder(builder, graph);

        final state = GridState(width: 5, height: 3, codec: graph.codec);
        final nodeABC = graph.nodes['ABC']!.first;

        // Start at offset 3 (row 0, col 3) - word won't fit, should skip to row 1
        final offset = builder.findFirstValidPlacement(state, nodeABC, 3);
        final (row, col) = offsetToRowCol(offset, 5);

        expect(row, 1);
        expect(col, 0);
      });
    });

    group('conflict detection', () {
      test('finds valid placement after conflict', () {
        // Place "XY" at start, then try to place "AB" which conflicts
        final language = createMockLanguage(
          id: 'CONF1',
          phrases: ['XY', 'AB'],
          requiresPadding: false,
        );

        final builder = BacktrackingGridBuilder(
          width: 5,
          height: 2,
          language: language,
          seed: 0,
        );

        final graph = WordDependencyGraphBuilder.build(language: language);
        setupBuilder(builder, graph);

        final state = GridState(width: 5, height: 2, codec: graph.codec);
        final nodeXY = graph.nodes['XY']!.first;
        final nodeAB = graph.nodes['AB']!.first;

        // Place XY at offset 0
        state.placeWord(nodeXY, 0);

        // Try to place AB starting from 0 - should skip past conflict
        final offset = builder.findFirstValidPlacement(state, nodeAB, 0);
        final (row, col) = offsetToRowCol(offset, 5);

        expect(row, 0);
        expect(col, 2); // First position after XY
      });

      test('allows overlapping placement when cells match', () {
        // Place "AB" then try to place "BC" - the B should overlap
        final language = createMockLanguage(
          id: 'OVER1',
          phrases: ['AB BC'],
          requiresPadding: false,
        );

        final builder = BacktrackingGridBuilder(
          width: 5,
          height: 2,
          language: language,
          seed: 0,
        );

        final graph = WordDependencyGraphBuilder.build(language: language);
        setupBuilder(builder, graph);

        final state = GridState(width: 5, height: 2, codec: graph.codec);
        final nodeAB = graph.nodes['AB']!.first;
        final nodeBC = graph.nodes['BC']!.first;

        // Place AB at offset 0 (cells 0=A, 1=B)
        state.placeWord(nodeAB, 0);

        // Try to place BC starting from 0 - should find offset 1 where B overlaps
        final offset = builder.findFirstValidPlacement(state, nodeBC, 0);
        final (row, col) = offsetToRowCol(offset, 5);

        expect(row, 0);
        expect(col, 1); // BC overlaps with AB's B
      });

      test('handles conflict at various positions in word', () {
        // Grid: "AAAAB" (5 chars)
        // Try to place "AB" - should work at offset 3 (A at pos 3, B at pos 4)
        final language = createMockLanguage(
          id: 'CONF2',
          phrases: ['AAAAB', 'AB'],
          requiresPadding: false,
        );

        final builder = BacktrackingGridBuilder(
          width: 5,
          height: 2,
          language: language,
          seed: 0,
        );

        final graph = WordDependencyGraphBuilder.build(language: language);
        setupBuilder(builder, graph);

        final state = GridState(width: 5, height: 2, codec: graph.codec);
        final nodeAAAAB = graph.nodes['AAAAB']!.first;
        final nodeAB = graph.nodes['AB']!.first;

        // Place AAAAB at offset 0 (fills entire first row)
        state.placeWord(nodeAAAAB, 0);

        // Try to place AB starting from 0
        // offset 0: A matches, but B conflicts with A at pos 1
        // offset 1: A matches, but B conflicts with A at pos 2
        // offset 2: A matches, but B conflicts with A at pos 3
        // offset 3: A matches, B matches! Found it.
        final offset = builder.findFirstValidPlacement(state, nodeAB, 0);
        final (row, col) = offsetToRowCol(offset, 5);

        expect(row, 0);
        expect(col, 3);
      });
    });
  });
}
