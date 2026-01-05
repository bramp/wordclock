# BacktrackingGridBuilder Design Document

## Problem Statement

Build a Qlocktwo-style word clock grid that displays times by lighting up consecutive letters to form words. The grid must be compact (11x10) and efficiently represent all possible time phrases.

## Grid Constraints

### Hard Constraints (Must Satisfy)
1. **Grid Dimensions**: 11 columns × 10 rows (110 cells total)
2. **Word Consecutiveness**: Each word must be made of consecutive letters (horizontal, left-to-right)
3. **Word Order**: Words in a phrase must appear in reading order (row-major: left-to-right, top-to-bottom)
4. **Word Separation**: Between lit-up words in the same phrase:
   - Must have at least one cell of separation (if `requiresPadding=true`)
   - Separation can be: padding characters, other words from different phrases, or newline (different row)
   - If on same row: at least 1 cell gap
   - If on different rows: no gap needed (newline acts as separator)
5. **No Conflicts**: A cell can only contain one character
6. **Character Matching**: When words overlap, characters must match exactly

### Soft Constraints (Optimization Goals)
1. **Compactness**: Minimize empty/padding cells
2. **Overlap Maximization**: Reuse cells between words when possible
3. **Reading Flow**: Prefer top-left to bottom-right diagonal placement
4. **Density**: Keep words close together while respecting separation rules

## Data Structures

### 1. Word-Level Dependency Graph (New)

Unlike the existing character-level DAG in `dependency_graph.dart`, we need a **word-level DAG**:

```dart
class WordNode {
  final String word;           // The actual word text
  final List<String> cells;    // Word split into cells
  final Set<String> phrases;   // Which phrases use this word
  final Map<String, int> phrasePositions; // Position in each phrase

  WordNode(this.word, this.cells, this.phrases, this.phrasePositions);
}

class WordDependencyGraph {
  // word -> WordNode
  Map<String, WordNode> nodes;

  // word -> list of words that must come AFTER it (in any phrase)
  Map<String, Set<String>> edges;

  // phrase -> ordered list of words
  Map<String, List<String>> phrases;
}
```

**Key Differences from Character DAG**:
- Nodes represent entire **words**, not individual characters
- Edges represent word ordering within phrases
- Graph captures "word A must come before word B in phrase X"
- Multiple instances of same word in different phrases are tracked

### 2. Grid State

```dart
class GridState {
  final List<List<String?>> grid;  // [row][col] -> cell or null

  // Track word placements
  Map<String, List<WordPlacement>> wordPlacements;

  // Track which phrases are satisfied
  Set<String> satisfiedPhrases;

  // Metrics for optimization
  int filledCells;
  int overlapCells;
  double compactness;
}

class WordPlacement {
  final String word;
  final int row;
  final int startCol;
  final int endCol;
  final List<int> overlappedCells; // Which cells overlapped with existing words

  WordPlacement(this.word, this.row, this.startCol, this.endCol, this.overlappedCells);
}
```

## Algorithm: Backtracking with Pruning

### Phase 1: Build Word Dependency Graph

```
1. For each time phrase in language:
   a. Tokenize into words
   b. Create WordNode for each unique word (if not exists)
   c. Record phrase membership and position
   d. Create edges: word[i] -> word[i+1] for each phrase

2. Compute metadata:
   a. Word frequencies (how many phrases use each word)
   b. Average positions in phrases
   c. Critical words (high frequency or unique to phrase)
```

### Phase 2: Determine Word Placement Order

Sort words by priority:
```
Priority = (frequency * 10) + (1 / avgPosition) + (length / 10)
```

Rationale:
- High frequency words → placed first (appear in many phrases)
- Earlier position words → placed higher/left
- Longer words → placed first (harder to fit)

### Phase 3: Backtracking Search

```
function backtrack(state, remainingWords):
  if remainingWords is empty:
    if all phrases satisfied:
      return state  // Success!
    return null

  word = remainingWords[0]

  // Generate candidate positions for this word
  candidates = generateCandidates(state, word)

  // Sort by score (higher = better)
  candidates.sort(by score descending)

  for each candidate in candidates:
    if not violatesConstraints(state, word, candidate):
      newState = placeWord(state, word, candidate)

      // Prune if clearly suboptimal
      if shouldPrune(newState, remainingWords):
        continue

      result = backtrack(newState, remainingWords[1:])
      if result != null:
        return result

  return null  // No solution with this path
```

### Phase 4: Candidate Generation

For each word, generate candidate positions:

```
function generateCandidates(state, word):
  candidates = []

  for row in 0..height-1:
    for col in 0..width-word.length:
      // Try to place word starting at (row, col)

      // Check if cells are available or overlappable
      overlaps = computeOverlaps(state, word, row, col)

      if overlaps.hasConflict:
        continue  // Skip this position

      score = scorePosition(state, word, row, col, overlaps)

      if score > 0:
        candidates.add(Candidate(row, col, score, overlaps))

  // Special: Try to overlap with existing words
  for each existingWord in state.wordPlacements:
    overlapCandidates = findOverlapPositions(word, existingWord)
    candidates.addAll(overlapCandidates)

  return candidates
```

### Phase 5: Constraint Checking

**Note**: We reuse the existing validation logic from `bin/grid_builder.dart`, now extracted into `lib/generator/utils/grid_validator.dart`.

```
function violatesConstraints(state, word, candidate):
  // Use GridValidator.canPlaceAfter() and GridValidator.hasSeparation()
  // to check constraints consistently with existing code

  // 1. Check phrase ordering constraints
  for phrase in word.phrases:
    if not checkPhraseOrdering(state, phrase, word, candidate):
      return true

  return false

function checkPhraseOrdering(state, phrase, word, candidate):
  wordsInPhrase = graph.phrases[phrase]
  wordIndex = wordsInPhrase.indexOf(word)

  // Check previous words in phrase
  for i in 0..wordIndex-1:
    prevWord = wordsInPhrase[i]
    if prevWord not placed in state:
      continue

    prevPlacement = state.wordPlacements[prevWord]

    // Use GridValidator.canPlaceAfter() to check reading order and separation
    if not GridValidator.canPlaceAfter(
      prevEndRow: prevPlacement.row,
      prevEndCol: prevPlacement.endCol,
      currStartRow: candidate.row,
      currStartCol: candidate.col,
      requiresPadding: language.requiresPadding
    ):
      return false

  // Check next words in phrase (similar logic)
  ...

  return true
```

### Phase 6: Scoring Positions

```
function scorePosition(state, word, row, col, overlaps):
  score = 100.0

  // Heavily reward overlap (cell reuse)
  score += overlaps.count * 50

  // Prefer positions near existing words (compactness)
  if state.wordPlacements.notEmpty:
    distance = distanceToNearestWord(row, col)
    score -= distance * 2

  // Prefer top-left to bottom-right diagonal
  diagonalDistance = row + col
  score -= diagonalDistance * 0.3

  // Penalty for being far right (prefer compact left)
  score -= (col / width) * 10

  // Bonus for first row (common clock design)
  if row == 0:
    score += 15

  // Penalty for wasted space (cells between this and previous words)
  if state.wordPlacements.notEmpty:
    wastedCells = computeWastedCells(state, row, col)
    score -= wastedCells * 5

  return score
```

### Phase 7: Pruning Strategies

```
function shouldPrune(state, remainingWords):
  // 1. Grid overflow check
  estimatedCells = state.filledCells + estimateRemainingCells(remainingWords)
  if estimatedCells > width * height:
    return true

  // 2. Impossible phrase check
  for phrase in remainingPhrases:
    if not canSatisfyPhrase(state, phrase):
      return true

  // 3. Compactness threshold
  if state.filledCells > 0:
    compactness = state.overlapCells / state.filledCells
    if compactness < minCompactnessThreshold:
      return true

  // 4. Search depth limit (prevent infinite recursion)
  if searchDepth > maxDepth:
    return true

  return false
```

## Implementation Plan

### Step 0: Extract Shared Validation Code (✓ Done)
File: `lib/generator/utils/grid_validator.dart`
- Extract validation logic from `bin/grid_builder.dart`
- Create reusable `GridValidator` class
- Methods: `validate()`, `canPlaceAfter()`, `hasSeparation()`

### Step 1: Create WordDependencyGraph Builder (✓ Done)
File: `lib/generator/word_dependency_graph.dart`
- Build word-level graph from language
- Compute word priorities
- Track phrase memberships

### Step 2: Create GridState and WordPlacement classes (✓ Done)
File: `lib/generator/backtracking_grid_state.dart`
- Grid state management
- Word placement tracking (uses `GridValidator` for constraint checking)
- Phrase satisfaction checking

### Step 3: Implement Core Backtracking Algorithm (✓ Done)
File: `lib/generator/backtracking_grid_builder.dart`
- Main backtracking search
- Candidate generation
- Constraint checking (delegates to `GridValidator`)
- Final grid validation

### Step 4: Implement Scoring and Pruning (✓ Done)
In `backtracking_grid_builder.dart`:
- Position scoring
- Overlap detection
- Pruning heuristics

### Step 5: Testing and Optimization
- Test with multiple languages
- Tune scoring weights
- Add timeout/iteration limits

## Key Advantages Over ConstraintGridBuilder

1. **Exhaustive Search**: Backtracking explores more possibilities
2. **Better Overlap**: Explicitly tries overlap positions
3. **Phrase-Aware**: Directly models phrase constraints in graph
4. **Pruning**: Eliminates bad paths early
5. **Word-Level**: Works with words (not characters), more natural for this problem

## Design Decisions

1. **Iterative Deepening**: Not needed - we want ALL words placed, so increasing depth gradually doesn't help. We use pruning instead.

2. **Timeout**: 30-60 seconds is reasonable (configurable via `maxSearchTimeSeconds`)

3. **Vertical Words**: Not currently supported - Qlocktwo clocks use horizontal words only

4. **Multiple Solutions**: Return best N solutions ranked by compactness/density (TODO: implement solution ranking)

## Usage

### Command Line
```bash
# Use backtracking algorithm in grid_builder
dart run bin/grid_builder.dart --algorithm backtracking -l EN

# Or use short form
dart run bin/grid_builder.dart -a backtracking -l EN --seed 42

# See all options
dart run bin/grid_builder.dart --help
```

### Programmatic Usage
```dart
import 'package:wordclock/generator/backtracking_grid_builder.dart';
import 'package:wordclock/languages/all.dart';

// Create builder
final builder = BacktrackingGridBuilder(
  width: 11,
  height: 10,
  language: englishLanguage,
  seed: 42,
  maxSearchTimeSeconds: 30,      // Timeout
  maxNodesExplored: 500000,      // Node limit
  minCompactnessThreshold: 0.1,  // Quality threshold
);

// Build grid
final grid = builder.build();

if (grid != null) {
  // Success! grid is List<String> with 110 cells
  final wordGrid = WordGrid(width: 11, cells: grid);
  print(wordGrid.toString());
} else {
  print('Failed to find solution');
}
```

### Configuration Parameters

- `width`, `height`: Grid dimensions (typically 11×10)
- `seed`: Random seed for padding character selection
- `maxSearchTimeSeconds`: Maximum search time before giving up (default: 30s)
- `maxNodesExplored`: Maximum nodes to explore (default: 100,000)
- `minCompactnessThreshold`: Minimum overlap ratio to continue search (default: 0.1)
