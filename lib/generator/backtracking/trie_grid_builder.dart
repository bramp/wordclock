import 'dart:math';

import 'package:meta/meta.dart';
import 'package:wordclock/generator/backtracking/graph/cell_codec.dart';
import 'package:wordclock/generator/backtracking/graph/graph_builder.dart';
import 'package:wordclock/generator/backtracking/graph/phrase_trie.dart';
import 'package:wordclock/generator/backtracking/grid_post_processor.dart';
import 'package:wordclock/generator/backtracking/grid_state.dart';
import 'package:wordclock/generator/backtracking/indexed_word_list.dart';
import 'package:wordclock/generator/model/grid_build_progress.dart';
import 'package:wordclock/generator/model/grid_build_result.dart';
import 'package:wordclock/generator/grid_solver.dart';
import 'package:wordclock/generator/model/word_placement.dart' as public;
import 'package:wordclock/generator/utils/grid_validator.dart';
import 'package:wordclock/generator/utils/word_clock_utils.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/types.dart';
import 'package:wordclock/model/word_grid.dart';

/// Callback for progress updates during search.
typedef ProgressCallback = bool Function(GridBuildProgress progress);

/// A trie-based grid builder that discovers word instances dynamically.
class TrieGridBuilder implements GridSolver {
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
  GridState? _bestState;
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
    return (BigInt.from(trieData.trie.phraseCount), trieData.trie.roots.length);
  }

  /// Attempts to build a grid that satisfies all constraints.
  @override
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

    // 2. Initialize search state - use GridState
    final grid = GridState(width: width, height: height, codec: codec);
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

      final postResult = processor.process(finalState.placements);
      gridCells = postResult.grid;
      wordPlacements = [for (final p in postResult.placements) p.toPublic()];
    } else {
      gridCells = List.filled(width * height, ' ');
      wordPlacements = [];
    }

    final resultGrid = WordGrid(width: width, cells: gridCells);
    final validationIssues = GridValidator.validate(resultGrid, language);

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
    final trie = PhraseTrie();
    final uniqueWords = <String>[];
    final uniqueWordIndex = <String, int>{};
    final wordCells = <List<int>>[];

    final phrases = WordClockUtils.getAllPhrases(language);
    for (final phrase in phrases) {
      final words = language.tokenize(phrase);
      if (words.isEmpty) continue;

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
    PhraseTrie trie,
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
  void _solveTrie(
    GridState grid,
    PhraseTrie trie,
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

      // Add to grid using generic API
      final placement = grid.placeGenericWord(
        word: word,
        cellCodes: cellCodes,
        offset: offset,
      );

      if (placement == null) {
        continue; // Should not happen if _findValidPlacement is correct
      }

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
      grid.removePlacement(placement);

      // Undo Unique Word Space Tracking
      if (wasUnplaced) {
        placedWordsMask.clear(wordId);
      }

      if (_shouldStop) return;
    }
  }

  void _annotateTrie(
    PhraseTrie trie,
    List<int> wordRank,
    Map<String, int> uniqueWordIndex,
  ) {
    void annotateRecursive(PhraseTrieNode node) {
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
    List<PhraseTrieNode> nodes,
    SolverPlacement placement,
  ) {
    final removedNodes = List<PhraseTrieNode>.of(nodes);
    final wordId = nodes.first.wordId;

    final savedOffsets = <(PhraseTrieNode, int, int)>[];
    final addedChildren = <(PhraseTrieNode, int)>[];

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

    frontier.removeWord(wordId);

    return _FrontierUndoInfo(
      removedWordId: wordId,
      removedNodes: removedNodes,
      savedOffsets: savedOffsets,
      addedChildren: addedChildren,
    );
  }

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
  int? _findValidPlacement(GridState grid, List<int> cellCodes, int minOffset) {
    final wordLen = cellCodes.length;
    final maxCol = width - wordLen;
    final maxOffset = _maxAllowedOffset - wordLen;
    final cells = grid.grid; // Access Int8List directly for speed

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
        if (existing != -1 && existing != cellCodes[i]) {
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

  void _reportProgressFromFrontier(
    DateTime now,
    GridState grid,
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

    final shouldContinue = onProgress!(
      GridBuildProgress(
        bestWords: _maxWordsPlaced,
        totalWords: _totalUniqueWords,
        phrasesCompleted: phrasesCompleted,
        bestPhrases: _maxPhrasesCompleted,
        totalPhrases: _totalPhrases,
        width: width,
        cells: grid.toFlatList(),
        wordPlacements: [for (final p in grid.placements) p.toPublic()],
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

  void _updateBestState(GridState grid) {
    final totalPlacements = grid.placements.length;
    if (totalPlacements > _maxWordsPlaced) {
      _maxWordsPlaced = totalPlacements;
      _bestState = grid.clone();
    }
  }

  void _recordCompletedState(GridState grid) {
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
  final PhraseTrie trie;
  final List<String> uniqueWords;
  final List<List<int>> wordCells;
  final List<int> wordRank;
  final List<int> minContribution;
  final Map<String, int> uniqueWordIndex;

  _TrieData({
    required this.trie,
    required this.uniqueWords,
    required this.wordCells,
    required this.wordRank,
    required this.minContribution,
    required this.uniqueWordIndex,
  });
}

class _Frontier {
  final List<List<PhraseTrieNode>> wordLists;
  final _SimpleBitSet activeWords;

  _Frontier(int totalWords)
    : wordLists = List.generate(totalWords, (_) => <PhraseTrieNode>[]),
      activeWords = _SimpleBitSet() {
    assert(totalWords <= 64);
  }

  bool get isEmpty => activeWords.isEmpty;

  void addNode(int wordId, PhraseTrieNode node) {
    wordLists[wordId].add(node);
    activeWords.set(wordId);
  }

  void removeNode(int wordId, PhraseTrieNode node) {
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

  void restoreNodes(int wordId, List<PhraseTrieNode> nodes) {
    wordLists[wordId] = nodes;
    activeWords.set(wordId);
  }
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

class _FrontierCandidate {
  final int wordId;
  final List<PhraseTrieNode> nodes;
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
  final List<PhraseTrieNode> removedNodes;
  final List<(PhraseTrieNode, int, int)> savedOffsets;
  final List<(PhraseTrieNode, int)> addedChildren;

  _FrontierUndoInfo({
    required this.removedWordId,
    required this.removedNodes,
    required this.savedOffsets,
    required this.addedChildren,
  });
}
