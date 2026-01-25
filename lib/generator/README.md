# Generators

We have tried a few different approaches to solving the word clock puzzle.

## Backtracking

This is the original approach that was used to solve the puzzle. It is a brute force approach that tries every possible combination of words to solve the puzzle. It is guaranteed to find a solution if one exists, but it is very slow.

There are two implementiations, backtracking/grid_builder.dart (`-a backtracking`), and backtracking/trie_grid_builder.dart (`-a trie`).

The grid builder combines all phrases into a graph of words, and tries to solve for all paths though that graph. This has the problem, that there are possibly multiple graphs for the same phrases, and if a poor graph is chosen, the grid_builder can not solve.

The trie builder uses a trie of words across all phrases, advancing a frountier of next possible word. Because the same word can appear in multiple places in the trie, the search space is a lot larger than the grid builder.

### Results: grid_builder.dart (`-a backtracking`)
```
============================================================
SUMMARY
============================================================

Results: 25 languages
  ✓ Optimal:    22
  ⚠ Solved:     0 (not optimal)
  ⏱ Timeout:    3
  ✗ Failed:     0
  ❌ Error:      0

Language  Status              Words     Time       Iterations
------------------------------------------------------------
CH        ✓ Optimal           21/21     0.01s       22
CA        ✓ Optimal           28/28     0.01s       29
CS        ✓ Optimal           28/28     0.00s       29
CT        ✓ Optimal           28/28     0.00s       29
CZ        ✓ Optimal           22/22     2.97s       13375078
DK        ✓ Optimal           23/23     0.00s       24
NL        ✓ Optimal           21/21     0.00s       22
D4        ✓ Optimal           23/23     0.00s       248
E2        ✓ Optimal           23/23     0.00s       24
EN        ✓ Optimal           22/22     0.00s       23
FR        ✓ Optimal           27/27     0.87s       3675519
D2        ✓ Optimal           23/23     0.00s       248
DE        ✓ Optimal           24/24     0.00s       27
GR        ✓ Optimal           22/22     0.01s       23
IT        ✓ Optimal           24/24     0.00s       25
JP        ✓ Optimal           32/32     0.00s       33
NO        ✓ Optimal           20/20     0.00s       21
PL        ⏱ Timeout           27/30     60.01s      520702976
PE        ✓ Optimal           28/28     0.01s       29
RO        ⏱ Timeout           22/23     60.01s      408893440
RU        ⏱ Timeout           27/29     60.02s      371707904
ES        ✓ Optimal           24/24     0.00s       25
D3        ✓ Optimal           21/21     0.01s       5377
SE        ✓ Optimal           22/22     0.00s       23
TR        ✓ Optimal           29/29     36.78s      191404284

Timeout: PL, RO, RU
```

### Results trie_grid_builder.dart (`-a trie`)
```
============================================================
SUMMARY
============================================================

Results: 25 languages
  ✓ Optimal:    13
  ⚠ Solved:     0 (not optimal)
  ⏱ Timeout:    10
  ✗ Failed:     0
  ❌ Error:      2

Language  Status              Words     Time       Iterations
------------------------------------------------------------
CH        ✓ Optimal           21/21     0.01s       22
CA        ⏱ Timeout           36/24     60.41s      1011712
CS        ✓ Optimal           31/31     0.00s       32
CT        ✓ Optimal           31/31     0.00s       32
CZ        ❌ Error             -         -           -
DK        ✓ Optimal           26/26     0.01s       27
NL        ⏱ Timeout           27/19     60.03s      76615680
D4        ⏱ Timeout           25/21     60.83s      1799168
E2        ✓ Optimal           25/25     0.00s       26
EN        ✓ Optimal           24/24     0.00s       25
FR        ⏱ Timeout           33/25     61.53s      198656
D2        ⏱ Timeout           25/21     60.77s      1820672
DE        ⏱ Timeout           29/21     60.46s      8486912
GR        ✓ Optimal           23/23     0.01s       550
IT        ✓ Optimal           25/25     0.01s       938
JP        ✓ Optimal           65/65     0.00s       66
NO        ✓ Optimal           24/24     0.00s       25
PL        ⏱ Timeout           535/26    60.57s      3818496
PE        ❌ Error             -         -           -
RO        ✓ Optimal           23/23     2.20s       166517
RU        ⏱ Timeout           413/25    64.88s      21504
ES        ✓ Optimal           24/24     0.01s       685
D3        ⏱ Timeout           21/21     60.64s      47471616
SE        ✓ Optimal           25/25     0.00s       26
TR        ⏱ Timeout           624/28    63.91s      119808

Timeout: CA, NL, D4, FR, D2, DE, PL, RU, D3, TR

Errors: CZ, PE
```

## SCS

This is a new approach that uses the Shortest Common Supersequence algorithm to solve the puzzle. It is a greedy algorithm that tries to find the best solution by merging the most overlapping words together. The current implementation performs poorly.

## Greedy

TODO Delete this.
