# Word Clock Grid Generation Algorithm (Greedy)

**Note: This algorithm has been superseded by the backtracking algorithm as the default.**

This document describes the requirements and the algorithm used to generate the word clock grid using the greedy DAG-based approach.

## Requirements

1.  **Input**: A set of phrases $P = \{p_1, p_2, \dots, p_n\}$. Each phrase $p_i$ is a sequence of words $w_{i,1}, w_{i,2}, \dots, w_{i,m_i}$.
2.  **Word Continuity**: Each word $w_{i,j}$ must appear as a contiguous sequence of characters in the grid.
3.  **Phrase Order**: For any phrase $p_i$, the words $w_{i,1}, w_{i,2}, \dots, w_{i,m_i}$ must appear in the grid in that specific order.
4.  **Mandatory Gaps**: Between any two consecutive words $w_{i,j}$ and $w_{i,j+1}$ in a phrase, there must be at least one non-word character (a "gap") or a line break.
5.  **No Row Spanning**: A word cannot start on one row and end on another.
6.  **Character Reuse**: To keep the grid small, characters are reused across different words and phrases as long as it does not violate the DAG (Directed Acyclic Graph) property or the continuity/order requirements.
    - **Sub-string Reuse**: If a word $W_1$ is a contiguous sub-string of another word $W_2$, $W_1$ will reuse the corresponding nodes of $W_2$ (e.g., "A" can reuse the first node of "ABC").
    - **Phrase Reuse**: If a word appears in multiple phrases, it will reuse the same nodes unless doing so would create a cycle.

## Algorithm

### 1. Graph Construction

The goal is to build a Directed Acyclic Graph (DAG) where nodes represent characters and edges represent "must appear before" constraints.

- **Nodes**: A node is uniquely identified by `(char, word, index)`.
    - `char`: The character (e.g., 'A').
    - `word`: The word it belongs to (e.g., 'TWENTY'). This prevents interleaving of unrelated words.
    - `index`: A unique identifier for this specific character instance.
- **Edges**:
    - For each word, edges are added between consecutive characters: $c_k \to c_{k+1}$.
    - For each phrase, an edge is added from the last character of one word to the first character of the next: $w_{i,j} \to w_{i,j+1}$.
- **Cycle Detection**: Before adding an edge $u \to v$, we check if a path $v \to u$ already exists. If it does, we create a new version of the word (with new nodes) to ensure the graph remains a DAG.

### 2. Greedy Topological Sort

We use a modified Kahn's algorithm to order the nodes:

1.  Initialize `inDegree` for all nodes.
2.  Collect all nodes with `inDegree == 0` into a `readyNodes` list.
3.  While `readyNodes` is not empty:
    a. Pick a node `u` (optionally with randomness for different grid layouts).
    b. Append `u` to the result.
    c. For each child `v` of `u`:
        - Decrement `inDegree[v]`.
        - If `inDegree[v] == 0`, add `v` to a `newlyReady` list.
    d. **Greedy Step**: Insert `newlyReady` nodes at the **front** of `readyNodes`. This ensures that if a word's character is placed, its next character (which is now ready) is placed immediately after, keeping words contiguous.

### 3. Grid Layout

The sorted nodes are placed into a 2D grid:

1.  Iterate through the sorted nodes.
2.  **Word Grouping**: Identify "blocks" of consecutive nodes that belong to the same word and have direct dependencies.
3.  **Conditional Gaps**:
    - If there is a direct dependency between the last node of the previous block and the first node of the current block (meaning they appeared together in a phrase), insert a padding character (a "gap") if they are on the same line.
4.  **Row Fitting**:
    - If the current word block fits in the remaining space of the current row, place it.
    - Otherwise, "flush" the current row (fill with padding) and place the word at the start of the next row.
5.  **Padding**: Fill any remaining empty cells in the grid with random characters from the language's alphabet.
