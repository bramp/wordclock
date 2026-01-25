import 'dart:math';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'package:wordclock/generator/backtracking/indexed_word_list.dart';
import 'package:wordclock/generator/backtracking/graph/cell_codec.dart';
import 'package:wordclock/generator/backtracking/graph/graph_builder.dart';
import 'package:wordclock/generator/backtracking/graph/word_node.dart';
import 'package:wordclock/generator/backtracking/grid_post_processor.dart';
import 'package:wordclock/generator/backtracking/grid_state.dart';
import 'package:wordclock/generator/model/grid_build_progress.dart';
import 'package:wordclock/generator/model/grid_build_result.dart';
import 'package:wordclock/generator/utils/grid_validator.dart';
import 'package:wordclock/generator/utils/word_clock_utils.dart';
import 'package:wordclock/generator/model/word_placement.dart' as public;
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/types.dart';
import 'package:wordclock/model/word_grid.dart';

/// Callback for progress updates during search.
typedef ProgressCallback = bool Function(GridBuildProgress progress);

/// A trie-based grid builder that discovers word instances dynamically.
///
/// ## Key Difference from BacktrackingGridBuilder
///
/// Instead of pre-computing word instances (CINCI vs CINCI#1) and using a
/// dependency graph with inDegree constraints, this solver:
///
/// 1. **Tracks trie paths independently** - Each phrase has its own progress
///    through the trie, and paths are independent of each other.
///
/// 2. **Discovers instances dynamically** - When placing "CINCI", we don't
///    pre-decide if it's CINCI or CINCI#1. Instead, we place it and see
///    which trie paths it satisfies.
///
/// 3. **Allows flexible word reuse** - The same physical word position can
///    satisfy multiple trie paths that happen to need that word after
///    compatible predecessors.
///
/// ## Optimization Roadmap
///
/// 1. [x] **Pruning: Unique Word Space**
///    Calculate the minimum number of cells each unique word *must* contribute
///    (length - max_possible_overlap). Track the sum of these for unplaced
///    unique words. Prune if `needed_space > available_cells`.
///    *Note: This provides massive early exit potential.*
///
/// 2. [x] **Structure: Bitset Frontier**
///    Replace `Map<String, List<_TrieNode>>` with a fixed-size `List<List<_TrieNode>>`
///    indexed by word ID, and a bitset (`Uint32List`) for active word tracking.
///    *Note: Aiming to remove Map.iteration and Map.[] overhead (current ~11% CPU).*
///
/// 4. [ ] **Logic: Greedy Node Sharing**
///    When placing a word at an offset, satisfy ALL frontier nodes for that word
///    that are compatible with that offset.
///    *Note: This reduces search depth and branching factor significantly.*
///
/// 5. [ ] **Heuristic: Least Constrained Variable**
///    Sort candidates by how many valid slots they have left. Early placement of
///    "hard" words prevents deep backtracking.
///
/// 6. [ ] **Heuristic: Unlock Potential**
///    Prioritize words that are precursors to many other words in the trie.
///
class TrieGridBuilder {
  final int width;
  final int height;
  final WordClockLanguage language;
  final Random random;

  /// Cell codec for encoding/decoding cells to integers
  late final CellCodec codec;

  /// The alphabet used for random padding
  final String paddingAlphabet;

  /// Padding alphabet cells
  final List<Cell> paddingCells;

  /// If true, stop after finding the first valid grid.
  final bool findFirstValid;

  /// Optional callback for progress updates.
  final ProgressCallback? onProgress;

  // Internal state
  _SimpleGrid? _bestState;
  int _minHeightFound;
  int _maxAllowedOffset;
  int _maxWordsPlaced = -1;
  int _maxPhrasesCompleted = 0;
  int _totalUniqueWords = 0;
  int _totalPhrases = 0;
  bool _stopRequested = false;
  DateTime _lastProgressReport = DateTime.now();
  int _iterationCount = 0;
  late DateTime _startTime;
  StopReason _stopReason = StopReason.completed;
  bool _allComplete = false;

  TrieGridBuilder({
    required this.width,
    required this.height,
    required this.language,
    required int seed,
    String? paddingAlphabet,
    this.findFirstValid = true,
    this.onProgress,
  }) : random = Random(seed),
       paddingAlphabet =
           paddingAlphabet ?? language.defaultGridRef!.paddingAlphabet,
       paddingCells = WordGrid.splitIntoCells(
         paddingAlphabet ?? language.defaultGridRef!.paddingAlphabet,
       ),
       _minHeightFound = height,
       _maxAllowedOffset = height * width;

  /// Calculates statistics for the phrase trie for a given language.
  /// (topologicalSorts, totalNodes)
  @visibleForTesting
  static (BigInt, int) calculateStats(WordClockLanguage language) {
    final builder = TrieGridBuilder(
      width: 11,
      height: 10,
      language: language,
      seed: 0,
    );
    builder.codec = CellCodec();
    final trieData = builder._buildPhraseTrie();
    return (trieData.trie.countTopologicalSorts(), trieData.trie.countNodes());
  }

  /// Attempts to build a grid that satisfies all constraints.
  GridBuildResult build() {
    codec = CellCodec();

    // 1. Build the phrase trie and collect unique words
    final trieData = _buildPhraseTrie();
    final trie = trieData.trie;
    final uniqueWords = trieData.uniqueWords; // List of unique words

    _totalUniqueWords = uniqueWords.length;
    _totalPhrases = trie.phraseCount;

    assert(
      _totalUniqueWords <= 64,
      'Trie solver supports up to 64 unique words',
    );

    // 2. Initialize search state - simple grid
    final grid = _SimpleGrid(width: width, height: height);
    _minHeightFound = height;
    _maxAllowedOffset = height * width;
    _maxWordsPlaced = -1;
    _bestState = null;
    _stopRequested = false;
    _iterationCount = 0;
    _startTime = DateTime.now();
    _stopReason = StopReason.completed;
    _allComplete = false;

    // 3. Initialize frontier - one entry per phrase (starting at root nodes)
    // Each phrase path needs its own entry even if they share the first word
    final frontier = _createInitialFrontier(trie, trieData.uniqueWordIndex);

    // 4. Run the solver
    // Calculate initial min space needed (sum of all unique words)
    int totalUniqueSpace = 0;
    for (int i = 0; i < _totalUniqueWords; i++) {
      totalUniqueSpace += trieData.minContribution[i];
    }

    _solveTrie(
      grid,
      trie,
      frontier,
      uniqueWords,
      trieData.wordCells,
      trieData.minContribution,
      trieData.uniqueWordIndex,
      _SimpleBitSet(),
      totalUniqueSpace,
    );

    // 6. Build result
    final finalState = _bestState;
    late final List<Cell> gridCells;
    late final List<public.WordPlacement> wordPlacements;

    if (finalState != null) {
      // Use GridPostProcessor for alignment and padding
      final processor = GridPostProcessor(
        width: width,
        height: height,
        language: language,
        paddingAlphabet: paddingAlphabet,
        random: random,
        codec: codec,
      );

      // Convert _SimpleGrid placements to GridPostProcessor placements
      final processorPlacements = finalState.placements.map((p) {
        return Placement(
          node: WordNode(
            word: p.word,
            instance: 0,
            cellCodes: p.cellCodes,
            phrases: {},
          ),
          startOffset: p.startOffset,
          width: width,
        );
      }).toList();

      final postResult = processor.process(processorPlacements);
      gridCells = postResult.grid;

      // Extract final word placements
      wordPlacements = [for (final p in postResult.placements) p.toPublic()];
    } else {
      gridCells = List.filled(width * height, ' ');
      wordPlacements = [];
    }

    final resultGrid = WordGrid(width: width, cells: gridCells);
    final validationIssues = GridValidator.validate(resultGrid, language);

    // For trie solver: if all phrases are complete, set totalWords to match
    // placedWords so isOptimal (which checks placedWords == totalWords)
    // will be true. Otherwise use unique words count as the target.
    final totalWords = _allComplete ? wordPlacements.length : _totalUniqueWords;

    return GridBuildResult(
      grid: resultGrid,
      validationIssues: validationIssues,
      totalWords: totalWords,
      wordPlacements: wordPlacements,
      iterationCount: _iterationCount,
      startTime: _startTime,
      stopReason: _stopReason,
    );
  }

  /// Build phrase trie from language.
  _TrieData _buildPhraseTrie() {
    final trie = _PhraseTrie();
    final uniqueWords = <String>[];
    final uniqueWordIndex = <String, int>{};
    final wordCells = <List<int>>[];

    final phrases = WordClockUtils.getAllPhrases(language);
    for (final phrase in phrases) {
      final words = language.tokenize(phrase);
      if (words.isEmpty) continue;

      // Add to trie
      trie.addPhrase(phrase, words);

      for (final word in words) {
        if (!uniqueWordIndex.containsKey(word)) {
          uniqueWordIndex[word] = uniqueWords.length;
          uniqueWords.add(word);
          wordCells.add(codec.encodeAll(WordGrid.splitIntoCells(word)));
        }
      }
    }

    final lengths = wordCells.map((c) => c.length).toList();
    final overlaps = IndexedWordList.computeMaxIncomingOverlaps(
      lengths,
      wordCells,
    );
    final minContributions = List<int>.generate(
      uniqueWords.length,
      (i) => lengths[i] - overlaps[i],
    );

    // Compute topological word ranks from the dependency graph
    final graph = WordDependencyGraphBuilder.build(language: language);
    final nodeRanks = graph.computeRanks();
    final wordRank = List<int>.filled(uniqueWords.length, 1 << 16);
    for (final entry in nodeRanks.entries) {
      final id = uniqueWordIndex[entry.key.word]!;
      wordRank[id] = min(wordRank[id], entry.value);
    }

    _annotateTrie(trie, wordRank, uniqueWordIndex);

    return _TrieData(
      trie: trie,
      uniqueWords: uniqueWords,
      wordCells: wordCells,
      wordRank: wordRank,
      minContribution: minContributions,
      uniqueWordIndex: uniqueWordIndex,
    );
  }

  _Frontier _createInitialFrontier(
    _PhraseTrie trie,
    Map<String, int> uniqueWordIndex,
  ) {
    final frontier = _Frontier(uniqueWordIndex.length);
    for (final node in trie.roots.values) {
      final wordId = uniqueWordIndex[node.word]!;
      frontier.addNode(wordId, node);
    }
    return frontier;
  }

  /// Main recursive solver using trie-based frontier.
  ///
  /// The frontier tracks which trie nodes are currently "blocked" awaiting a
  /// word placement.
  void _solveTrie(
    _SimpleGrid grid,
    _PhraseTrie trie,

    // Set of words needing to be placed, and the TrieNodes that they would advance
    _Frontier frontier,

    // List of unique words for ID -> String conversion
    List<String> uniqueWords,

    // List of cell codes (indexed by word ID)
    List<List<int>> wordCells,

    // List of minimum cell contribution (indexed by word ID)
    List<int> minContribution,

    // Map of word -> unique index (for bitset)
    Map<String, int> uniqueWordIndex,

    // Bitset of placed unique words
    _SimpleBitSet placedWordsMask,

    // Current sum of minContribution for all UNPLACED unique words
    int neededUniqueSpace,
  ) {
    // TODO Shouldn't this be global?
    _iterationCount++;

    // Progress reporting
    if (_iterationCount % 1024 == 0) {
      _reportProgressFromFrontier(DateTime.now(), grid, frontier);
      if (_shouldStop) return;
    }

    // Update best state
    _updateBestState(grid);

    // Pruning: exceeded allowed height
    if (grid.maxEndOffset >= _maxAllowedOffset) return;

    // Pruning: check if remaining words can fit in remaining space
    final remainingSpace = _maxAllowedOffset - grid.maxEndOffset - 1;
    if (neededUniqueSpace > remainingSpace) {
      return;
    }

    // Solution found when frontier is empty (all paths reached terminal)
    if (frontier.isEmpty) {
      _recordCompletedState(grid);
      return;
    }

    // Build sorted candidate list using pre-computed node ranks.
    // This avoids map lookups in the sort comparator.
    final candidates = <_FrontierCandidate>[];
    frontier.activeWords.forEachSetBit((wordId) {
      final nodes = frontier.wordLists[wordId];
      final rank = nodes.first.rank;

      // Compute max parent offset while iterating
      int maxParentEnd = nodes.first.parentEndOffset;
      for (int i = 1; i < nodes.length; i++) {
        final pEnd = nodes[i].parentEndOffset;
        if (pEnd > maxParentEnd) maxParentEnd = pEnd;
      }

      candidates.add(_FrontierCandidate(wordId, nodes, rank, maxParentEnd));
    });
    // TODO I wonder if we need to make a copy of _TrieNode to _FrontierCandidate. Or
    // we could just copy the _TrieNode directly, and sort that.
    // Sort by pre-computed rank
    if (candidates.length > 1) {
      candidates.sort((a, b) => a.rank.compareTo(b.rank));
    }

    for (final candidate in candidates) {
      final wordId = candidate.wordId;
      final nodes = candidate.nodes;
      final cellCodes = wordCells[wordId];
      final word = uniqueWords[wordId];
      final minOffset = _computeMinOffsetAfter(candidate.maxParentEndOffset);

      // Find valid grid placement for this word, starting from minOffset
      final offset = _findValidPlacement(grid, cellCodes, minOffset);
      if (offset == null) continue; // No valid placement, try next word

      final endOffset = offset + cellCodes.length - 1;
      final placement = _WordPlacement(
        word: word,
        cellCodes: cellCodes,
        startOffset: offset,
        endOffset: endOffset,
      );

      // Save maxEndOffset for fast restore during backtrack
      final savedMaxEndOffset = grid.maxEndOffset;

      // Add to grid
      _placeWord(grid, placement);

      // Advance frontier and capture undo info (avoids full copy)
      final undoInfo = _advanceFrontierWithUndo(frontier, nodes, placement);

      // Unique Word Space Tracking
      int spaceDelta = 0;
      final wasUnplaced = !placedWordsMask.isSet(wordId);
      if (wasUnplaced) {
        placedWordsMask.set(wordId);
        spaceDelta = minContribution[wordId];
      }

      // Recurse with updated frontier
      _solveTrie(
        grid,
        trie,
        frontier,
        uniqueWords,
        wordCells,
        minContribution,
        uniqueWordIndex,
        placedWordsMask,
        neededUniqueSpace - spaceDelta,
      );

      // Backtrack: undo frontier changes and node offsets
      _undoFrontierAdvance(frontier, undoInfo);
      _removeWord(grid, placement, savedMaxEndOffset);

      // Undo Unique Word Space Tracking
      if (wasUnplaced) {
        placedWordsMask.clear(wordId);
      }

      if (_shouldStop) return;
    }
  }

  /// Assign ranks and word IDs to all trie nodes.
  void _annotateTrie(
    _PhraseTrie trie,
    List<int> wordRank,
    Map<String, int> uniqueWordIndex,
  ) {
    void annotateRecursive(_TrieNode node) {
      final id = uniqueWordIndex[node.word]!;
      node.wordId = id;
      node.rank = wordRank[id];

      for (final child in node.children.values) {
        annotateRecursive(child);
      }
    }

    for (final root in trie.roots.values) {
      annotateRecursive(root);
    }
  }

  _FrontierUndoInfo _advanceFrontierWithUndo(
    _Frontier frontier,
    List<_TrieNode> nodes,
    _WordPlacement placement,
  ) {
    // TODO Do we need this complex save. There may be cheaper ways, using a stack for example.

    // Save the nodes being removed (for restore)
    final removedNodes = List<_TrieNode>.of(nodes);
    final wordId = nodes.first.wordId;

    // Save node offsets and track children added
    final savedOffsets = <(_TrieNode, int, int)>[];
    final addedChildren = <(_TrieNode, int)>[]; // (child, wordId)

    for (final node in nodes) {
      savedOffsets.add((node, node.parentEndOffset, node.endOffset));
      node.endOffset = placement.endOffset;

      for (final child in node.children.values) {
        savedOffsets.add((child, child.parentEndOffset, child.endOffset));
        child.parentEndOffset = placement.endOffset;

        frontier.addNode(child.wordId, child);
        addedChildren.add((child, child.wordId));
      }
    }

    // Remove the placed word's nodes from frontier
    frontier.removeWord(wordId);

    return _FrontierUndoInfo(
      removedWordId: wordId,
      removedNodes: removedNodes,
      savedOffsets: savedOffsets,
      addedChildren: addedChildren,
    );
  }

  /// Undo frontier advance using saved undo info.
  void _undoFrontierAdvance(_Frontier frontier, _FrontierUndoInfo undoInfo) {
    // Restore node offsets
    for (final (node, parentEnd, end) in undoInfo.savedOffsets) {
      node.parentEndOffset = parentEnd;
      node.endOffset = end;
    }

    // Remove added children (in reverse order)
    for (int i = undoInfo.addedChildren.length - 1; i >= 0; i--) {
      final (child, wordId) = undoInfo.addedChildren[i];
      frontier.removeNode(wordId, child);
    }

    // Restore removed word's nodes
    frontier.restoreNodes(undoInfo.removedWordId, undoInfo.removedNodes);
  }

  /// Compute minimum offset after a given end offset.
  ///
  /// This is determined by the previous end offset and the
  /// padding required, and wrapping onto the next row as needed.
  int _computeMinOffsetAfter(int prevEndOffset) {
    if (prevEndOffset == -1) return 0;

    final padding = language.requiresPadding ? 2 : 1;
    int minOffset = prevEndOffset + padding;

    // Handle row wrap
    final minCol = prevEndOffset % width + padding;
    if (minCol >= width) {
      final minRow = prevEndOffset ~/ width + 1;
      minOffset = minRow * width;
    }

    return minOffset;
  }

  /// Find the earliest valid placement for a word starting from minOffset.
  ///
  /// Conducts a simple linear search for the first valid placement.
  ///
  /// Returns null if no valid placement exists.
  int? _findValidPlacement(
    _SimpleGrid grid,
    List<int> cellCodes,
    int minOffset,
  ) {
    final wordLen = cellCodes.length;
    final maxCol = width - wordLen;
    final maxOffset = _maxAllowedOffset - wordLen;
    final cells = grid.cells;

    int offset = minOffset;
    int col = offset % width;
    int row = offset ~/ width;

    while (offset <= maxOffset) {
      if (col > maxCol) {
        row++;
        col = 0;
        offset = row * width;
        continue;
      }

      bool valid = true;
      for (int i = 0; i < wordLen; i++) {
        final existing = cells[offset + i];
        if (existing != _SimpleGrid.emptyCell && existing != cellCodes[i]) {
          valid = false;
          break;
        }
      }

      if (valid) {
        return offset;
      }

      offset++;
      col++;
      if (col >= width) {
        col = 0;
        row++;
      }
    }

    return null;
  }

  /// Place a word on the grid.
  void _placeWord(_SimpleGrid grid, _WordPlacement placement) {
    for (int i = 0; i < placement.cellCodes.length; i++) {
      final idx = placement.startOffset + i;
      grid.usage[idx]++;
      grid.cells[idx] = placement.cellCodes[i];
    }
    if (placement.endOffset > grid.maxEndOffset) {
      grid.maxEndOffset = placement.endOffset;
    }
    grid.placements.add(placement);
  }

  /// Remove a word from the grid.
  /// Pass savedMaxEndOffset to avoid recomputing it.
  void _removeWord(
    _SimpleGrid grid,
    _WordPlacement placement,
    int savedMaxEndOffset,
  ) {
    for (int i = 0; i < placement.cellCodes.length; i++) {
      final idx = placement.startOffset + i;
      grid.usage[idx]--;
      if (grid.usage[idx] == 0) {
        grid.cells[idx] = _SimpleGrid.emptyCell;
      }
    }
    grid.placements.removeLast();
    // Restore maxEndOffset directly instead of recalculating
    grid.maxEndOffset = savedMaxEndOffset;
  }

  void _reportProgressFromFrontier(
    DateTime now,
    _SimpleGrid grid,
    _Frontier frontier,
  ) {
    if (now.difference(_lastProgressReport).inSeconds < 1) return;
    if (onProgress == null) return;

    _lastProgressReport = now;

    // Count phrases remaining (terminal nodes still in frontier)
    int phrasesRemaining = 0;
    frontier.activeWords.forEachSetBit((id) {
      final list = frontier.wordLists[id];
      for (final node in list) {
        if (node.isTerminal) phrasesRemaining++;
      }
    });

    final phrasesCompleted = _totalPhrases - phrasesRemaining;

    // Track best phrases completed
    if (phrasesCompleted > _maxPhrasesCompleted) {
      _maxPhrasesCompleted = phrasesCompleted;
    }

    // Convert placements to WordPlacement for progress
    final wordPlacements = grid.placements
        .map(
          (p) => public.WordPlacement(
            word: p.word,
            startOffset: p.startOffset,
            width: width,
            length: p.cellCodes.length,
          ),
        )
        .toList();

    final shouldContinue = onProgress!(
      GridBuildProgress(
        bestWords: _maxWordsPlaced,
        totalWords: _totalUniqueWords,
        phrasesCompleted: phrasesCompleted,
        bestPhrases: _maxPhrasesCompleted,
        totalPhrases: _totalPhrases,
        width: width,
        cells: List.generate(width * height, (i) {
          final code = grid.cells[i];
          return code == _SimpleGrid.emptyCell ? null : codec.decode(code);
        }),
        wordPlacements: wordPlacements,
        iterationCount: _iterationCount,
        startTime: _startTime,
      ),
    );
    if (!shouldContinue) {
      _stopRequested = true;
      _stopReason = StopReason.userStopped;
    }
  }

  bool get _shouldStop => _stopRequested || (findFirstValid && _allComplete);

  void _updateBestState(_SimpleGrid grid) {
    final totalPlacements = grid.placements.length;
    if (totalPlacements > _maxWordsPlaced) {
      _maxWordsPlaced = totalPlacements;
      _bestState = grid.clone();
    }
  }

  void _recordCompletedState(_SimpleGrid grid) {
    _allComplete = true;
    final currentHeight = grid.maxEndOffset ~/ width + 1;
    if (currentHeight <= _minHeightFound) {
      _minHeightFound = currentHeight;
      _maxAllowedOffset = currentHeight * width;
      _bestState = grid.clone();
    }
  }
}

/// Data returned from building the phrase trie.
class _TrieData {
  final _PhraseTrie trie;
  final List<String> uniqueWords;
  final List<List<int>> wordCells;
  final List<int> wordRank; // Topological rank of word (indexed by wordId)
  final List<int> minContribution; // Min space contribution (indexed by wordId)
  final Map<String, int> uniqueWordIndex; // Word -> Index

  _TrieData({
    required this.trie,
    required this.uniqueWords,
    required this.wordCells,
    required this.wordRank,
    required this.minContribution,
    required this.uniqueWordIndex,
  });
}

/// Simple phrase trie that stores phrases as word sequences.
class _PhraseTrie {
  /// Root-level children keyed by first word
  final Map<String, _TrieNode> roots = {};

  /// Count of phrases added
  int phraseCount = 0;

  void addPhrase(String phrase, List<String> words) {
    if (words.isEmpty) return;

    // Get or create root node for first word
    var node = roots.putIfAbsent(
      words[0],
      () => _TrieNode(word: words[0], depth: 1),
    );

    // Walk/create path for remaining words
    for (int i = 1; i < words.length; i++) {
      final word = words[i];
      var child = node.children[word];
      if (child == null) {
        child = _TrieNode(word: word, depth: i + 1);
        node.children[word] = child;
      }
      node = child;
    }

    // Mark terminal
    node.isTerminal = true;
    node.terminalPhrases.add(phrase);
    phraseCount++;
  }

  @override
  String toString() {
    int nodeCount = 0;
    void countNodes(_TrieNode node) {
      nodeCount++;
      for (final child in node.children.values) {
        countNodes(child);
      }
    }

    for (final root in roots.values) {
      countNodes(root);
    }

    final sorts = countTopologicalSorts();
    String sortsStr;
    if (sorts == BigInt.zero) {
      sortsStr = '0';
    } else {
      final s = sorts.toString();
      if (s.length <= 15) {
        sortsStr = s;
      } else {
        sortsStr = '${s[0]}.${s.substring(1, 4)}e+${s.length - 1}';
      }
    }

    return 'PhraseTrie:\n'
        '  ${roots.length} root words\n'
        '  $nodeCount total nodes\n'
        '  $phraseCount phrases ($sortsStr topological sorts)';
  }

  /// Returns the number of unique word sequences that can satisfy this trie.
  /// Since the trie is a tree/forest, we can use the Hook Length Formula:
  /// n! / PRODUCT(subtree_size(v)) for all v in V.
  BigInt countTopologicalSorts() {
    final subtreeSize = <_TrieNode, int>{};
    final allNodes = <_TrieNode>[];

    int computeSize(_TrieNode node) {
      allNodes.add(node);
      int size = 1;
      for (final child in node.children.values) {
        size += computeSize(child);
      }
      return subtreeSize[node] = size;
    }

    int totalNodes = 0;
    for (final root in roots.values) {
      totalNodes += computeSize(root);
    }

    if (totalNodes == 0) return BigInt.zero;

    // Hook length formula for forest: n! / PRODUCT(subtree_size(v))
    var numerator = BigInt.one;
    for (int i = 2; i <= totalNodes; i++) {
      numerator *= BigInt.from(i);
    }

    var denominator = BigInt.one;
    for (final node in allNodes) {
      denominator *= BigInt.from(subtreeSize[node]!);
    }

    return numerator ~/ denominator;
  }

  /// Returns the total number of nodes in the trie.
  int countNodes() {
    int count = 0;
    void traverse(_TrieNode node) {
      count++;
      for (final child in node.children.values) {
        traverse(child);
      }
    }

    for (final root in roots.values) {
      traverse(root);
    }
    return count;
  }
}

/// A node in the phrase trie.
class _TrieNode {
  /// The word at this node
  final String word;

  /// Depth in trie (1 for first word, etc.)
  final int depth;

  /// Word index in lexicon
  int wordId = -1;

  /// Pre-computed topological rank for sorting (lower = place earlier).
  /// Cached here to avoid map lookups in the hot path.
  int rank = 0;

  /// Children: word -> child node
  final Map<String, _TrieNode> children = {};

  /// True if this node is the end of at least one phrase
  bool isTerminal = false;

  /// Which phrases end at this node
  final List<String> terminalPhrases = [];

  /// The end offset of the parent/predecessor word.
  /// This node's word must be placed at position >= parentEndOffset.
  /// For root nodes, this is -1 (can be placed from offset 0).
  int parentEndOffset;

  /// The end offset where this node's word was placed.
  /// Only valid after the node has been satisfied.
  int endOffset;

  _TrieNode({required this.word, required this.depth})
    : parentEndOffset = -1,
      endOffset = -1;

  @override
  String toString() =>
      'TrieNode($word, depth=$depth, terminal=$isTerminal, parentEnd=$parentEndOffset)';
}

/// A simple bitset implementation using a single 64-bit integer.
class _SimpleBitSet {
  int _data = 0;

  bool isSet(int index) {
    assert(index >= 0 && index < 64);
    return (_data & (1 << index)) != 0;
  }

  void set(int index) {
    assert(index >= 0 && index < 64);
    _data |= (1 << index);
  }

  void clear(int index) {
    assert(index >= 0 && index < 64);
    _data &= ~(1 << index);
  }

  bool get isEmpty => _data == 0;

  void forEachSetBit(void Function(int index) action) {
    if (_data == 0) return;
    for (int i = 0; i < 64; i++) {
      if ((_data & (1 << i)) != 0) {
        action(i);
      }
    }
  }
}

/// Structure tracking the trie frontier during search.
class _Frontier {
  /// A list of trie nodes awaiting placement, indexed by word ID.
  /// Each entry contains all nodes in the trie that can be satisfied by the word.
  final List<List<_TrieNode>> wordLists;

  /// A bitset tracking which word IDs have at least one node in [wordLists].
  final _SimpleBitSet activeWords;

  _Frontier(int totalWords)
    : wordLists = List.generate(totalWords, (_) => <_TrieNode>[]),
      activeWords = _SimpleBitSet() {
    assert(totalWords <= 64);
  }

  bool get isEmpty => activeWords.isEmpty;

  void addNode(int wordId, _TrieNode node) {
    wordLists[wordId].add(node);
    activeWords.set(wordId);
  }

  void removeNode(int wordId, _TrieNode node) {
    final list = wordLists[wordId];
    list.remove(node);
    if (list.isEmpty) {
      activeWords.clear(wordId);
    }
  }

  void removeWord(int wordId) {
    wordLists[wordId] = [];
    activeWords.clear(wordId);
  }

  void restoreNodes(int wordId, List<_TrieNode> nodes) {
    wordLists[wordId] = nodes;
    activeWords.set(wordId);
  }
}

/// A word placement with position info.
class _WordPlacement {
  final String word;
  final List<int> cellCodes;
  final int startOffset;
  final int endOffset;

  _WordPlacement({
    required this.word,
    required this.startOffset,
    required this.endOffset,
    required this.cellCodes,
  });
}

/// Simple grid state for the trie solver.
class _SimpleGrid {
  static const int emptyCell = -1;

  final Int8List cells;
  final Uint8List usage;
  final int width;
  final int height;
  final List<_WordPlacement> placements;
  int maxEndOffset;

  _SimpleGrid({required this.width, required this.height})
    : cells = Int8List(width * height)..fillRange(0, width * height, emptyCell),
      usage = Uint8List(width * height),
      placements = [],
      maxEndOffset = -1;

  _SimpleGrid._clone({
    required this.cells,
    required this.usage,
    required this.width,
    required this.height,
    required this.placements,
    required this.maxEndOffset,
  });

  _SimpleGrid clone() {
    return _SimpleGrid._clone(
      cells: Int8List.fromList(cells),
      usage: Uint8List.fromList(usage),
      width: width,
      height: height,
      placements: List.of(placements),
      maxEndOffset: maxEndOffset,
    );
  }
}

/// Candidate for frontier iteration - avoids map lookups in hot path.
class _FrontierCandidate {
  final int wordId;
  final List<_TrieNode> nodes;
  final int rank;
  final int maxParentEndOffset;

  _FrontierCandidate(
    this.wordId,
    this.nodes,
    this.rank,
    this.maxParentEndOffset,
  );
}

/// Undo information for frontier advancement.
/// Allows restoring frontier state without copying the entire map.
class _FrontierUndoInfo {
  final int removedWordId;
  final List<_TrieNode> removedNodes;
  final List<(_TrieNode, int, int)> savedOffsets;
  final List<(_TrieNode, int)> addedChildren;

  _FrontierUndoInfo({
    required this.removedWordId,
    required this.removedNodes,
    required this.savedOffsets,
    required this.addedChildren,
  });
}
