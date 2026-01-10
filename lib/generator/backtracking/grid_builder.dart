import 'dart:math';
import 'package:wordclock/generator/backtracking/grid_state.dart';
import 'package:wordclock/generator/backtracking/graph/dependency_graph.dart';
import 'package:wordclock/generator/backtracking/graph/graph_builder.dart';
import 'package:wordclock/generator/backtracking/graph/word_node.dart';
import 'package:wordclock/generator/backtracking/graph/phrase_trie.dart';
import 'package:wordclock/generator/backtracking/overlap_matrix.dart';
import 'package:wordclock/generator/backtracking/indexed_word_list.dart';
import 'package:wordclock/generator/utils/grid_build_result.dart';
import 'package:wordclock/generator/utils/grid_validator.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/types.dart';
import 'package:wordclock/model/word_grid.dart';

/// Progress information during grid building.
class GridBuildProgress {
  /// Best number of words placed so far
  final int bestWords;

  /// Total words to place
  final int totalWords;

  /// Grid width
  final int width;

  /// Current grid cells (for colored display)
  final List<String> cells;

  /// Word placement info (for colored display)
  final List<PlacedWordInfo> wordPlacements;

  /// Number of iterations (recursive calls) so far
  final int iterationCount;

  /// When the search started
  final DateTime startTime;

  /// Words placed in current search path
  int get currentWords => wordPlacements.length;

  GridBuildProgress({
    required this.bestWords,
    required this.totalWords,
    required this.width,
    required this.cells,
    required this.wordPlacements,
    required this.iterationCount,
    required this.startTime,
  });
}

/// Callback for progress updates during grid building.
/// Return true to continue, false to stop the search.
typedef ProgressCallback = bool Function(GridBuildProgress progress);

/// A backtracking-based grid builder that finds optimal word placements.
///
/// ## Performance Optimizations
///
/// This solver includes several optimizations for the hot path:
///
/// ### 1. Inline Placement Check (`_findFirstValidPlacement`)
/// The placement validity check is inlined rather than calling a separate
/// method. This eliminates function call overhead in the innermost loop,
/// which runs millions of times during search.
///
/// ### 2. Row-Skip Optimization
/// When a word doesn't fit on the current row (column + length > width),
/// we jump directly to the start of the next row instead of incrementing
/// by 1. This avoids checking impossible positions.
///
/// ### 3. Unchecked Placement (`placeWordUnchecked`)
/// Since [findEarliestPlacementByPhrase] already validates the placement,
/// we use [GridState.placeWordUnchecked] to skip redundant validation.
///
/// ### 4. Sorted Node Order
/// Nodes are sorted by (rank, length descending) so that:
/// - Lower-rank words (fewer dependencies) are tried first
/// - Within each rank, longer words are placed first for better packing
///
/// ### 5. Bitset Frontier Tracking
/// Uses a 64-bit integer as a bitset to track eligible nodes, enabling
/// O(1) updates when placing/removing words. Bit manipulation is faster
/// than set operations.
class BacktrackingGridBuilder {
  final int width;
  final int height;
  final WordClockLanguage language;
  final Random random;

  /// The word dependency graph
  late final WordDependencyGraph graph;

  /// Cell codec for encoding/decoding cells to integers
  late final CellCodec codec;

  /// Pre-computed overlap compatibility matrix for word pairs
  late final OverlapMatrix overlapMatrix;

  /// Padding alphabet cells
  final List<Cell> paddingCells;

  /// Padding cell codes (pre-encoded for efficiency)
  late final List<int> paddingCellCodes;

  /// If true, stop after finding the first valid grid (all words placed).
  /// If false (default), continue searching for optimal (minimum height) grid.
  final bool findFirstValid;

  /// If true (default), use frontier-based solving where words become eligible
  /// as soon as their dependencies are satisfied.
  /// If false, use rank-based solving where all words in a rank must complete
  /// before moving to the next rank.
  final bool useFrontier;

  /// Optional callback for progress updates (called at most once per second).
  /// Return true to continue, false to stop the search.
  final ProgressCallback? onProgress;

  /// Internal state for the best grid found
  GridState? _bestState;
  int _minHeightFound;
  int _maxAllowedOffset;
  int _maxWordsPlaced = -1;
  int _totalWords = 0;
  bool _stopRequested = false;
  DateTime _lastProgressReport = DateTime.now();
  int _iterationCount = 0;
  late DateTime _startTime;
  StopReason _stopReason = StopReason.completed;

  BacktrackingGridBuilder({
    required this.width,
    required this.height,
    required this.language,
    required int seed,
    this.findFirstValid = true,
    this.useFrontier = true,
    this.onProgress,
  }) : random = Random(seed),
       paddingCells = WordGrid.splitIntoCells(language.paddingAlphabet),
       _minHeightFound = height,
       _maxAllowedOffset = height * width;

  /// Attempts to build a grid that satisfies all constraints.
  GridBuildResult build() {
    // 1. Build word dependency graph (this also creates the CellCodec)
    graph = WordDependencyGraphBuilder.build(language: language);
    codec = graph.codec;

    // Pre-encode padding cells
    paddingCellCodes = codec.encodeAll(paddingCells);

    // 2. Initialize search state
    final state = GridState(width: width, height: height, codec: codec);
    _minHeightFound = height;
    _maxAllowedOffset = height * width;
    _maxWordsPlaced = -1;
    _bestState = null;
    _stopRequested = false;
    _iterationCount = 0;
    _startTime = DateTime.now();
    _stopReason = StopReason.completed;

    // 3. Get all nodes and build overlap matrix
    final allNodes = graph.nodes.values.expand((i) => i).toList();
    _totalWords = allNodes.length;
    overlapMatrix = OverlapMatrix.build(allNodes);

    // 4. Solve using selected approach
    if (useFrontier) {
      _solveWithFrontier(state, allNodes);
    } else {
      _solveWithRanks(state, allNodes);
    }

    // 5. Build Result
    final finalState = _bestState;
    int placedWords = 0;
    List<String> gridCells;
    List<PlacedWordInfo> wordPlacements = [];

    if (finalState != null) {
      placedWords = finalState.placementCount;
      wordPlacements = _extractPlacements(finalState);
      _fillPadding(finalState);
      gridCells = finalState.toFlatList();
    } else {
      // Fallback: Empty grid if failed
      gridCells = List.filled(width * height, ' ');
    }

    final gridToValidate = WordGrid(width: width, cells: gridCells);
    final validationIssues = GridValidator.validate(gridToValidate, language);

    return GridBuildResult(
      grid: gridCells,
      validationIssues: validationIssues,
      totalWords: _totalWords,
      placedWords: placedWords,
      wordPlacements: wordPlacements,
      iterationCount: _iterationCount,
      startTime: _startTime,
      stopReason: _stopReason,
    );
  }

  void _reportProgress(DateTime now, GridState state) {
    if (now.difference(_lastProgressReport).inSeconds < 1) return;
    if (onProgress == null) return;

    _lastProgressReport = now;
    final shouldContinue = onProgress!(
      GridBuildProgress(
        bestWords: _maxWordsPlaced,
        totalWords: _totalWords,
        width: width,
        cells: state.toFlatList(),
        wordPlacements: _extractPlacements(state),
        iterationCount: _iterationCount,
        startTime: _startTime,
      ),
    );
    if (!shouldContinue) {
      _stopRequested = true;
      _stopReason = StopReason.userStopped;
    }
  }

  /// Extracts word placement info from a GridState
  List<PlacedWordInfo> _extractPlacements(GridState state) {
    return state.placements.map((placement) {
      return PlacedWordInfo(
        word: placement.node.word,
        row: placement.row,
        startCol: placement.startCol,
        endCol: placement.endCol,
      );
    }).toList();
  }

  /// Returns true if search should stop
  bool get _shouldStop =>
      _stopRequested || (findFirstValid && _maxWordsPlaced == _totalWords);

  /// Sets up and runs frontier-based solving using bitset for eligible tracking
  void _solveWithFrontier(GridState state, List<WordNode> allNodes) {
    // Bitset is limited to 64 bits (Dart int is 64-bit)
    assert(
      allNodes.length <= 64,
      'Frontier solver limited to 64 nodes, got ${allNodes.length}. '
      'Use --use-ranks flag for languages with more words.',
    );

    // Build indexed word list (sorts words, computes metadata)
    final wordList = IndexedWordList.build(graph);

    // Create mutable copy of in-degree for tracking during search
    final inDegree = List<int>.of(wordList.initialInDegree);

    // Initial unplaced mask: all words are unplaced
    final allWordsMask = (1 << wordList.length) - 1;

    _solveFrontier(
      state,
      wordList,
      inDegree,
      wordList.initialEligibleMask,
      allWordsMask, // initially all words are unplaced
    );
  }

  /// Sets up and runs rank-based solving
  void _solveWithRanks(GridState state, List<WordNode> allNodes) {
    // Group nodes by rank (topological level)
    final ranks = computeRanks(graph);
    final maxRank = ranks.values.fold(0, (a, b) => a > b ? a : b);

    final rankNodes = List.generate(maxRank + 1, (_) => <WordNode>[]);
    for (final node in allNodes) {
      rankNodes[ranks[node]!].add(node);
    }

    // Sort each rank by word length (longest first for better packing)
    for (final rank in rankNodes) {
      rank.sort((a, b) => b.cellCodes.length.compareTo(a.cellCodes.length));
    }

    // Start with all words in rank 0 as remaining
    final initialMask = rankNodes.isNotEmpty
        ? (1 << rankNodes[0].length) - 1
        : 0;
    _solve(state, rankNodes, 0, initialMask);
  }

  /// Frontier-based recursive solve function using bitset.
  ///
  /// Words become eligible when all their dependencies (predecessors) are placed.
  ///
  /// ## Parameters
  /// - [wordList]: Pre-computed word metadata with words sorted by (rank, length)
  ///   and successor indices for O(1) lookup.
  /// - [eligibleMask]: Bitmask where bit i set means word i is eligible for placement.
  ///   Bits are ordered by (rank, length) so iterating LSB-first processes
  ///   lower-rank, longer words first.
  /// - [unplacedMask]: Bitmask where bit i set means word i has NOT been placed yet.
  /// - [inDegree]: Tracks how many unplaced predecessors each word has.
  ///   When a word's in-degree reaches 0, it becomes eligible.
  ///
  /// ## Algorithm
  /// 1. For each eligible word (iterating bits LSB-first):
  ///    a. Find earliest valid placement
  ///    b. If valid placement found, place word and update eligible mask
  ///    c. Recurse with updated state
  ///    d. Backtrack: remove word, restore in-degrees
  void _solveFrontier(
    GridState state,
    IndexedWordList wordList,
    List<int> inDegree,
    int eligibleMask,
    int unplacedMask,
  ) {
    _iterationCount++;
    final placedWords = state.placementCount;
    final allNodes = wordList.nodes;
    final successorIndices = wordList.successorIndices;

    // Periodically report progress
    if (_iterationCount % 1000 == 0) {
      final now = DateTime.now();
      _reportProgress(now, state);
      if (_shouldStop) return;
    }

    // Update best found so far
    if (placedWords > _maxWordsPlaced) {
      _maxWordsPlaced = placedWords;
      _bestState = state.clone();
    }

    // Pruning: if we've reached or exceeded the best height, backtrack
    if (state.maxEndOffset >= _maxAllowedOffset) return;

    // All words placed?
    if (placedWords == allNodes.length) {
      final currentHeight = state.maxEndOffset ~/ width + 1;
      if (currentHeight <= _minHeightFound) {
        _minHeightFound = currentHeight;
        _maxAllowedOffset = currentHeight * width;
        _bestState = state.clone();
      }
      return;
    }

    // No eligible words but not all placed - dead end
    if (eligibleMask == 0) return;

    // Try each eligible word (iterate over set bits in order)
    // Due to sorting by (rank, length), lower bits = lower rank, longer words
    int mask = eligibleMask;
    while (mask != 0) {
      // Get index of lowest set bit
      final lowestBit = mask & -mask;
      final nodeIdx = lowestBit.bitLength - 1;
      mask &= mask - 1; // Clear lowest bit for next iteration

      final node = allNodes[nodeIdx];

      // Find earliest valid placement for this word
      final offset = findEarliestPlacementByPhrase(state, node);

      if (offset != -1) {
        // Place word (skip validation since findEarliestPlacementByPhrase already checked)
        final p = state.placeWordUnchecked(node, offset);

        // Update trie cache with end offset and placement index
        final endOffset = offset + p.length - 1;
        final placementIndex = state.placementCount - 1;
        for (final trieNode in node.ownedTrieNodes) {
          trieNode.cachedEndOffset = endOffset;
          trieNode.cachedPlacementIndex = placementIndex;
        }

        // Update eligible mask: remove placed node
        int newEligibleMask = eligibleMask & ~lowestBit;
        int newUnplacedMask = unplacedMask & ~lowestBit;

        // Update in-degree for successors and mark newly eligible
        for (final succIdx in successorIndices[nodeIdx]) {
          inDegree[succIdx]--;
          if (inDegree[succIdx] == 0) {
            newEligibleMask |= (1 << succIdx);
          }
        }

        // Only recurse if remaining space can fit remaining words
        if (_canFitRemainingWords(state, wordList, newUnplacedMask)) {
          _solveFrontier(
            state,
            wordList,
            inDegree,
            newEligibleMask,
            newUnplacedMask,
          );
        }

        // Restore in-degrees for successors
        for (final succIdx in successorIndices[nodeIdx]) {
          inDegree[succIdx]++;
        }

        // Clear trie cache and remove placement
        for (final trieNode in node.ownedTrieNodes) {
          trieNode.cachedEndOffset = -1;
          trieNode.cachedPlacementIndex = -1;
        }
        state.removePlacement(p);
      }

      if (_shouldStop) return;
    }
  }

  /// Check if remaining words can potentially fit in remaining space.
  ///
  /// Uses precomputed minimum contributions:
  /// - Each word has a maxIncomingOverlap (best-case overlap with any other word)
  /// - minContribution[i] = wordLength[i] - maxIncomingOverlap[i]
  /// - Sum of minContributions gives a lower bound on space needed
  ///
  /// Returns true if it's still possible to place all remaining words.
  bool _canFitRemainingWords(
    GridState state,
    IndexedWordList wordList,
    int unplacedMask,
  ) {
    if (unplacedMask == 0) return true;

    final minContribution = wordList.minContribution;

    // Remaining space after current position
    final currentEndOffset = state.maxEndOffset;
    final remainingSpace = _maxAllowedOffset - currentEndOffset - 1;

    // Compute sum of minimum contributions.
    // Each word's minContribution = length - maxIncomingOverlap, representing
    // the minimum cells it must add beyond what it can overlap with predecessors.
    int totalMinContribution = 0;

    int mask = unplacedMask;
    while (mask != 0) {
      final lowestBit = mask & -mask;
      final nodeIdx = lowestBit.bitLength - 1;
      totalMinContribution += minContribution[nodeIdx];
      mask ^= lowestBit;
    }

    return totalMinContribution <= remainingSpace;
  }

  /// Rank-based recursive solve function.
  /// Processes words rank-by-rank (topological levels).
  /// [remainingMask] is a bitmask where bit i set means rankNodes[rankIndex][i]
  /// is still remaining to be placed.
  void _solve(
    GridState state,
    List<List<WordNode>> rankNodes,
    int rankIndex,
    int remainingMask,
  ) {
    _iterationCount++;
    final placedWords = state.placementCount;

    // Periodically report progress (check every 1000 iterations to avoid DateTime overhead)
    if (_iterationCount % 1000 == 0) {
      final now = DateTime.now();
      _reportProgress(now, state);
      if (_shouldStop) return;
    }

    // Update best found so far (even if partial)
    if (placedWords > _maxWordsPlaced) {
      _maxWordsPlaced = placedWords;
      _bestState = state.clone();
    }

    // Pruning: if we've reached or exceeded the best height, backtrack
    if (state.maxEndOffset >= _maxAllowedOffset) return;

    // Finished all ranks?
    if (rankIndex >= rankNodes.length) {
      final currentHeight = state.maxEndOffset ~/ width + 1;
      if (currentHeight <= _minHeightFound) {
        _minHeightFound = currentHeight;
        _maxAllowedOffset = currentHeight * width;
        _bestState = state.clone();
      }
      return;
    }

    // Finished current rank? Move to next.
    if (remainingMask == 0) {
      final nextRankIndex = rankIndex + 1;
      final nextMask = nextRankIndex < rankNodes.length
          ? (1 << rankNodes[nextRankIndex].length) - 1
          : 0;
      _solve(state, rankNodes, nextRankIndex, nextMask);
      return;
    }

    // Try each remaining word in this rank (iterate over set bits)
    final rankList = rankNodes[rankIndex];
    int mask = remainingMask;
    while (mask != 0) {
      // Get index of lowest set bit: (mask & -mask) isolates it,
      // then bitLength - 1 gives the 0-based index
      final lowestBit = mask & -mask;
      final i = lowestBit.bitLength - 1;
      mask &= mask - 1; // Clear the lowest set bit for next iteration

      final node = rankList[i];

      // Find EARLIEST valid placement for this word (returns 1D offset, -1 if not found)
      final offset = findEarliestPlacementByPhrase(state, node);

      if (offset != -1) {
        final p = state.placeWord(node, offset);
        if (p != null) {
          // Update trie cache with end offset and placement index
          final endOffset = offset + p.length - 1;
          final placementIndex = state.placementCount - 1;
          for (final trieNode in node.ownedTrieNodes) {
            trieNode.cachedEndOffset = endOffset;
            trieNode.cachedPlacementIndex = placementIndex;
          }

          // Recurse with this word removed from mask (no allocation needed!)
          _solve(state, rankNodes, rankIndex, remainingMask & ~lowestBit);

          // Clear trie cache before removal
          for (final trieNode in node.ownedTrieNodes) {
            trieNode.cachedEndOffset = -1;
            trieNode.cachedPlacementIndex = -1;
          }
          state.removePlacement(p);
        }
      }

      if (_shouldStop) return;
    }
  }

  /// Finds the earliest valid placement for a word by scanning phrases left-to-right.
  ///
  /// This method uses the pre-computed predecessor cells for each phrase and scans
  /// the grid to find placements for each predecessor word in reading order. The earliest
  /// valid position is after the MAX end position across all phrases.
  ///
  /// This differs from [findEarliestPlacement] which uses the pre-computed graph edges.
  /// The phrase-based approach correctly handles cases where duplicate words may
  /// already be satisfied by earlier placements.
  ///
  /// Uses a pre-computed trie of predecessor sequences to deduplicate work when
  /// multiple phrases share common prefixes.
  ///
  /// ## Hybrid Placement-Walk Optimization
  /// Instead of scanning cells one-by-one, we walk through the placement stack
  /// using the overlap matrix to skip words that definitely cannot conflict.
  /// When we find a word that COULD overlap, we fall back to cell-by-cell scan
  /// starting from that word's offset.
  ///
  /// Returns 1D offset (row * width + col), or -1 if not found.
  int findEarliestPlacementByPhrase(GridState state, WordNode node) {
    // If this word can be first in any phrase, it can start at offset 0
    if (node.hasEmptyPredecessor) {
      return findFirstValidPlacementHybrid(state, node, 0, 0);
    }

    // Try to find max end offset and placement index using the trie
    final (maxEndOffset, maxPlacementIndex) = _findMaxPredecessorInfo(
      node.phraseTrieNodes,
    );
    if (maxPlacementIndex == -1) {
      return -1; // No predecessor sequences satisfied yet
    }

    // Calculate the minimum starting offset after the max end position
    final padding = language.requiresPadding ? 2 : 1;
    int minOffset = maxEndOffset + padding;

    // Handle row wrap: if we'd go past end of row, move to next row
    final minCol = maxEndOffset % width + padding;
    if (minCol >= width) {
      final minRow = maxEndOffset ~/ width + 1;
      minOffset = minRow * width;
    }

    return findFirstValidPlacementHybrid(
      state,
      node,
      minOffset,
      maxPlacementIndex + 1,
    );
  }

  /// Find max predecessor info: returns (endOffset, placementIndex) pair.
  ///
  /// The placementIndex is the highest placement stack index among all
  /// predecessor sequences, used for placement-walk optimization.
  ///
  /// Returns (-1, -1) if no predecessors are placed yet.
  (int endOffset, int placementIndex) _findMaxPredecessorInfo(
    List<PhraseTrieNode> terminalNodes,
  ) {
    int maxEndOffset = -1;
    int maxPlacementIndex = -1;

    for (final node in terminalNodes) {
      final endOffset = node.cachedEndOffset;
      if (endOffset > maxEndOffset) {
        maxEndOffset = endOffset;
      }
      final placementIndex = node.cachedPlacementIndex;
      if (placementIndex > maxPlacementIndex) {
        maxPlacementIndex = placementIndex;
      }
    }

    return (maxEndOffset, maxPlacementIndex);
  }

  /// Find first valid placement starting from minOffset.
  ///
  /// The existing grid may contain existing words, and empty cells (emptyCell).
  /// A valid placement is one where the word fits without conflicts.
  ///
  /// The search scans in reading order (left-to-right, top-to-bottom)
  /// starting from [minOffset]. The minOffset is based on the last offset of
  /// the previous word in the phrase, and may be in the middle of a row,
  ///
  /// Returns 1D offset, or -1 if not found.
  ///
  /// **Performance optimizations:**
  /// 1. **Early termination:** The loop terminates when `offset > maxOffset`
  ///    (where `maxOffset = _maxAllowedOffset - wordLen`), since any later
  ///    position would extend past the allowed grid area.
  /// 2. **Row-skip:** When `col > maxCol`, the word can't fit on this row.
  ///    Instead of incrementing offset by 1 (checking impossible positions),
  ///    we jump directly to the start of the next row.
  /// 3. **Inline check:** The cell compatibility check is inlined rather than
  ///    calling [GridState.canPlaceWord]. This eliminates function call overhead
  ///    in what is often the hottest loop in the solver.
  /// 4. **Local variables:** Grid and cellCodes are cached in local variables
  ///    to avoid repeated field access.
  int findFirstValidPlacement(GridState state, WordNode node, int minOffset) {
    final wordLen = node.cellCodes.length;
    final maxCol = width - wordLen;
    final maxOffset = _maxAllowedOffset - wordLen;
    final cellCodes = node.cellCodes;
    final grid = state.grid;

    // Start from minOffset, scan in reading order
    int offset = minOffset;
    while (offset <= maxOffset) {
      final col = offset % width;
      // Row-skip optimization: jump to next row if word doesn't fit
      if (col > maxCol) {
        offset = (offset ~/ width + 1) * width;
        continue;
      }

      // Inline placement check (avoids function call overhead)
      bool valid = true;
      for (int i = 0; i < wordLen; i++) {
        final existing = grid[offset + i];
        if (existing != emptyCell && existing != cellCodes[i]) {
          valid = false;
          // Skip past this conflict - can't place anything starting here
          // that would include this position
          break;
        }
      }

      if (valid) {
        return offset;
      }
      offset++;
    }
    return -1;
  }

  /// Find first valid placement using hybrid placement-walk + cell scan.
  ///
  /// ## Algorithm
  /// 1. Walk through placements starting from [minPlacementIndex]
  /// 2. Use overlap matrix to skip words that definitely cannot conflict
  /// 3. When we find a gap that could fit the word, fall back to cell-by-cell scan
  ///
  /// This hybrid approach skips over large regions of non-conflicting words
  /// quickly, but uses the proven cell-by-cell method for actual conflict checking.
  ///
  /// [minOffset] is the earliest offset where placement is valid (after predecessor).
  /// [minPlacementIndex] is the first placement index to check for conflicts.
  ///
  /// Returns 1D offset, or -1 if not found.
  int findFirstValidPlacementHybrid(
    GridState state,
    WordNode node,
    int minOffset,
    int minPlacementIndex,
  ) {
    final wordLen = node.cellCodes.length;
    final maxOffset = _maxAllowedOffset - wordLen;
    final placements = state.placements;
    final placementCount = placements.length;
    final nodeIdx = node.matrixIndex;

    // Start scanning from minOffset
    int scanStartOffset = minOffset;

    for (int i = minPlacementIndex; i < placementCount; i++) {
      final p = placements[i];

      // Skip placements that end before our scan start
      if (p.endOffset < scanStartOffset) {
        continue;
      }

      // Check if there's a gap before this placement that could fit our word
      // Gap size = p.startOffset - scanStartOffset
      // On the 2nd iterations of the loop, scanStartOffset is actually placement[-1].endOffset + 1
      if (p.startOffset - scanStartOffset >= wordLen) {
        // Gap is big enough - fall back to cell scan
        break;
      }

      // Check if this placement could overlap using the matrix
      final otherIdx = p.node.matrixIndex;
      if (nodeIdx >= 0 &&
          otherIdx >= 0 &&
          !overlapMatrix.canOverlapByIndex(nodeIdx, otherIdx)) {
        // Cannot overlap - skip past this word entirely
        scanStartOffset = p.endOffset + 1;
        continue;
      }

      // This placement COULD conflict - fall back to cell scan from here
      break;
    }

    // Debug: print how many cells we skipped
    //if (scanStartOffset > minOffset) {
    //  print('Skipped ${scanStartOffset - minOffset} cells (minOffset=$minOffset, scanStart=$scanStartOffset)');
    //}

    // Either we found a potential conflict or walked past all placements
    // Fall back to cell-by-cell scan for the remaining range
    if (scanStartOffset > maxOffset) {
      return -1;
    }

    return findFirstValidPlacement(state, node, scanStartOffset);
  }

  /// Fill remaining cells with padding characters
  void _fillPadding(GridState state) {
    for (int i = 0; i < state.grid.length; i++) {
      if (state.grid[i] == emptyCell) {
        assert(state.usage[i] == 0);
        state.grid[i] =
            paddingCellCodes[random.nextInt(paddingCellCodes.length)];
      }
    }
  }

  /// Compute topological ranks for all word instances
  static Map<WordNode, int> computeRanks(WordDependencyGraph graph) {
    final inDegree = <WordNode, int>{};
    final allNodes = graph.nodes.values.expand((i) => i).toList();

    for (final node in allNodes) {
      inDegree[node] = 0;
    }

    for (final entry in graph.edges.entries) {
      for (final succ in entry.value) {
        inDegree[succ] = (inDegree[succ] ?? 0) + 1;
      }
    }

    final ranks = <WordNode, int>{};
    var queue = inDegree.entries
        .where((e) => e.value == 0)
        .map((e) => e.key)
        .toList();

    queue.sort((a, b) => a.id.compareTo(b.id));

    int currentRank = 0;
    while (queue.isNotEmpty) {
      final nextQueue = <WordNode>[];
      for (final node in queue) {
        ranks[node] = currentRank;
        for (final succ in graph.edges[node] ?? {}) {
          inDegree[succ] = inDegree[succ]! - 1;
          if (inDegree[succ] == 0) nextQueue.add(succ);
        }
      }
      queue = nextQueue;
      queue.sort((a, b) => a.id.compareTo(b.id));
      currentRank++;
    }

    for (final node in allNodes) {
      if (!ranks.containsKey(node)) ranks[node] = currentRank;
    }
    return ranks;
  }
}
