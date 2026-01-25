# Trie-Based Frontier Solver Design

## Current Approach: Graph-Based Eligibility

The current solver uses `WordDependencyGraph` where:

- Each word instance (CINCI, CINCI#1) is a fixed node
- Edges represent "must come before" relationships across ALL phrases
- A word is eligible when ALL predecessors are placed (inDegree = 0)

**Problem**: This conflates phrase constraints. CINCI#1 waits for ALL of:

- FĂRĂ (from "FĂRĂ CINCI" phrases)
- ŞI (from "ŞI CINCI" phrases)
- ŞI#1 (from "ŞI#1 CINCI" phrases)

Even though these are independent phrase paths!

## Proposed: Trie-Based Frontier

### Key Insight

The trie already represents phrase prefixes. Instead of pre-computing word instances,
we can explore trie paths independently and create word instances dynamically.

### Data Structures

```dart
/// A frontier of active trie positions
class TrieFrontier {
  /// For each word, track which trie positions need it next
  /// e.g., triePositions["CINCI"] = [node1, node2, node3]
  /// where each node is a different trie position waiting for CINCI
  Map<String, List<PhraseTrieNode>> pendingWords;

  /// Already placed word positions: word -> list of (offset, endOffset)
  /// Multiple positions allowed for same word!
  Map<String, List<(int start, int end)>> placedPositions;
}
```

### Algorithm Sketch

```
1. Initialize frontier with all phrase roots (first words)

2. Pick a word from frontier (any word that appears in pendingWords)

3. For this word:
   a. Find ALL valid placement positions in grid
   b. For each position:
      - Check which trie paths this placement satisfies
      - If ALL trie paths for this word are satisfied by existing placements
        of this word, we might be done with this word
      - Otherwise, place word here and recurse

4. On placement:
   - Mark this position in placedPositions
   - For each trie path waiting for this word at or before this position:
     - Advance that trie path to its children
     - Add children's words to pendingWords

5. Backtrack: remove position, revert trie paths
```

### Key Differences from Current Approach

| Current                                  | Trie-Based                                 |
| ---------------------------------------- | ------------------------------------------ |
| Word instances fixed at graph build      | Word instances discovered during search    |
| inDegree = ALL predecessors              | Each trie path independent                 |
| One placement per word instance          | Same word can satisfy multiple paths       |
| Explores one ordering of fixed instances | Explores different instance configurations |

### Example: Romanian CINCI

Current solver creates CINCI and CINCI#1 upfront. CINCI#1 must wait for
FĂRĂ AND ŞI AND ŞI#1.

Trie-based would:

1. Have trie paths ending at CINCI from different predecessors
2. First CINCI placement satisfies the first set of paths
3. If more paths need CINCI after already-placed words, search for another position
4. Naturally discovers how many instances are needed

### Challenges

1. **Phrase completion tracking**: Need to ensure ALL phrases are satisfiable
2. **Word reuse**: Same physical position might satisfy multiple trie paths
3. **Backtracking complexity**: More state to track/restore
4. **Space pruning**: How to compute minimum cells needed when instances are dynamic?

### Potential Benefits

1. **Different orderings**: Could find solutions current solver misses
2. **Fewer constraints**: Trie paths are independent, not conflated
3. **Natural instance discovery**: No need to pre-compute CINCI vs CINCI#1
4. **Better for duplicates**: Languages with many repeated words might benefit
