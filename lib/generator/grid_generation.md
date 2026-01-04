# Word Clock Grid Generation Algorithm

This document describes the requirements and the algorithm used to generate the word clock grid.

## Requirements

1.  **Input**: A set of phrases $P = \{p_1, p_2, \dots, p_n\}$. Each phrase $p_i$ is a sequence of words $w_{i,1}, w_{i,2}, \dots, w_{i,m_i}$.
2.  **Word Continuity**: Each word $w_{i,j}$ must appear as a contiguous sequence of characters in the grid.
3.  **Phrase Order**: For any phrase $p_i$, the words $w_{i,1}, w_{i,2}, \dots, w_{i,m_i}$ must appear in the grid in that specific order.
4.  **Mandatory Gaps**: Between any two consecutive words $w_{i,j}$ and $w_{i,j+1}$ in a phrase, there must be at least one non-word character (a "gap") or a line break (different row).
5.  **No Row Spanning**: A word cannot start on one row and end on another.
6.  **Word Overlap**: Words can overlap (share cells) when they have matching characters at the overlap positions, as long as it doesn't violate phrase ordering constraints.
7.  **Positioning Preferences**:
    - First word should appear near the top-left corner
    - Last word should appear near the bottom-right corner
    - Grid should be as compact as possible

## Algorithm: Constraint-Based Grid Builder

The `ConstraintGridBuilder` uses a constraint satisfaction approach to place words on a 2D grid with overlap support.

### 1. Phrase Collection

Collect all time phrases from the language's time-to-words converter:
- Each phrase is a sequence of words (tokens)
- Store these for later constraint validation

### 2. Word Frequency Analysis

For each unique word across all phrases:
- Count how many times it appears simultaneously in any single phrase
- Determine the minimum number of instances needed
- Prioritize by: frequency (most common first), then length (longest first)

### 3. Greedy Placement with Scoring

For each word instance to place:

1. **Find Candidate Positions**: Scan the 2D grid for valid positions
2. **Score Each Position** based on:
   - **Overlap bonus** (+50 per matching character): Encourages reusing existing letters
   - **Proximity penalty** (-2 × distance): Prefer positions near existing words
   - **Diagonal penalty** (-0.5 × (row + col)): Prefer top-left to bottom-right diagonal
   - **Last word bonus**: Strong penalty for last word not being near bottom-right
   - **First word bonus**: High score (+1000) for first word at position (0,0)

3. **Validate Constraints**: Before placing, check:
   - No character conflicts (different characters at same position)
   - Phrase order is maintained (words appear in correct sequence)
   - Spacing requirements (gap or newline between consecutive words in phrases)
   - Word fits within grid bounds

4. **Place Word**: Update grid with the word's characters at the chosen position

### 4. Constraint Validation

For each phrase, validate that word placements respect:

- **Order**: Words appear in sequence (can be determined by checking if previous word is placed)
- **Spacing**: If `requiresPadding` is true, consecutive words on the same row must have at least one gap between them
- **Non-conflict**: Words can overlap only where characters match exactly

### 5. Padding

After all words are placed:
- Fill remaining empty cells with random characters from the language's padding alphabet

## Comparison to Legacy Algorithm

The previous algorithm used a DAG-based approach with topological sorting:
- Built a dependency graph of character nodes
- Used Kahn's algorithm for ordering
- Packed nodes linearly into rows without overlap

The new constraint-based algorithm:
- Places whole words instead of individual character nodes
- Supports word overlap for more compact grids
- Uses scoring heuristics instead of graph traversal
- Typically achieves the target grid dimensions (10 rows) more reliably

Both algorithms ensure phrase ordering and spacing constraints, but the constraint-based approach produces grids that are 1-3 rows shorter on average due to word overlap.
