// ignore_for_file: avoid_print
import 'dart:math';
import 'dart:typed_data';

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

  /// Attempts to build a grid that satisfies all constraints.
  GridBuildResult build() {
    codec = CellCodec();

    // 1. Build the phrase trie and collect unique words
    final trieData = _buildPhraseTrie();
    final trie = trieData.trie;
    final uniqueWords = trieData.uniqueWords; // List of unique words
    final wordCells =
        trieData.wordCells; // Maping of Word -> List of Cell codes
    final uniqueWordIndex = trieData.uniqueWordIndex; // Word -> Index

    _totalUniqueWords = uniqueWords.length;
    _totalPhrases = trie.phraseCount;

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
    final frontier = _createInitialFrontier(trie);

    // 4. Run the solver
    // Calculate initial min space needed (sum of all unique words)
    int totalUniqueSpace = 0;
    for (final word in uniqueWords) {
      totalUniqueSpace += trieData.minContribution[word] ?? 0;
    }

    _solveTrie(
      grid,
      trie,
      frontier,
      wordCells,
      trieData.minContribution,
      uniqueWordIndex,
      _SimpleBitSet(_totalUniqueWords),
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
    final uniqueWords = <String>{};
    final wordCells = <String, List<int>>{};

    WordClockUtils.forEachTime(language, (time, phrase) {
      final words = language.tokenize(phrase);
      if (words.isEmpty) return;

      // Add to trie
      trie.addPhrase(phrase, words);

      // Collect unique words
      for (int i = 0; i < words.length; i++) {
        final word = words[i];
        if (!uniqueWords.contains(word)) {
          uniqueWords.add(word);
          final cells = WordGrid.splitIntoCells(word);
          wordCells[word] = codec.encodeAll(cells);
        }
      }
    });

    // Build dependency graph and compute ranks
    final graph = WordDependencyGraphBuilder.build(language: language);
    final nodeRanks = graph.computeRanks();

    // Convert node ranks to word ranks (use minimum rank across all instances)
    final wordRank = <String, int>{};
    for (final entry in nodeRanks.entries) {
      final word = entry.key.word;
      final rank = entry.value;
      wordRank[word] = min(wordRank[word] ?? rank, rank);
    }

    final uniqueWordsList = uniqueWords.toList();
    final minContributions = _computeMinContributions(
      uniqueWordsList,
      wordCells,
    );

    // Assign ranks and compute min contributions
    _annotateTrie(trie, wordRank, minContributions);

    // Map unique words to indices for bitset
    final uniqueWordIndex = <String, int>{};
    for (int i = 0; i < uniqueWordsList.length; i++) {
      uniqueWordIndex[uniqueWordsList[i]] = i;
    }

    return _TrieData(
      trie: trie,
      uniqueWords: uniqueWordsList,
      wordCells: wordCells,
      wordRank: wordRank,
      minContribution: minContributions,
      uniqueWordIndex: uniqueWordIndex,
    );
  }

  /// Compute minimum contribution for each unique word.
  ///
  /// For word i, this is length - maxIncomingOverlap.
  /// maxIncomingOverlap = max overlap with any other word j.
  Map<String, int> _computeMinContributions(
    List<String> uniqueWords,
    Map<String, List<int>> wordCells,
  ) {
    final contributions = <String, int>{};
    final n = uniqueWords.length;

    for (int i = 0; i < n; i++) {
      final wordI = uniqueWords[i];
      final codesI = wordCells[wordI]!;
      final lenI = codesI.length;
      int maxOverlapForI = 0;

      // Check against all other words j
      for (int j = 0; j < n; j++) {
        if (i == j) continue;

        final codesJ = wordCells[uniqueWords[j]]!;
        final lenJ = codesJ.length;

        // Find longest suffix of j that matches prefix of i
        final maxPossible = lenI < lenJ ? lenI : lenJ;
        for (int overlap = maxPossible; overlap > maxOverlapForI; overlap--) {
          bool matches = true;
          for (int k = 0; k < overlap; k++) {
            if (codesJ[lenJ - overlap + k] != codesI[k]) {
              matches = false;
              break;
            }
          }
          if (matches) {
            maxOverlapForI = overlap;
            break;
          }
        }
      }
      contributions[wordI] = lenI - maxOverlapForI;
    }
    return contributions;
  }

  /// Create initial frontier with all root nodes.
  /// Returns a map of word -> list of nodes needing that word.
  Map<String, List<_TrieNode>> _createInitialFrontier(_PhraseTrie trie) {
    final frontier = <String, List<_TrieNode>>{};
    for (final node in trie.roots.values) {
      frontier.putIfAbsent(node.word, () => []).add(node);
    }
    return frontier;
  }

  /// Main recursive solver using trie-based frontier.
  ///
  /// The frontier is a map of word -> list of trie nodes needing that word.
  /// Each node tracks its own parentEndOffset.
  /// When a node is terminal and satisfied, we remove it from frontier.
  /// Solution found when frontier is empty.
  void _solveTrie(
    _SimpleGrid grid,
    _PhraseTrie trie,

    // Set of words needing to be placed, and the TrieNodes that they would advance
    Map<String, List<_TrieNode>> frontier,

    // Mapping of word -> list of cell codes
    Map<String, List<int>> wordCells,

    // Map of word -> minimum cell contribution (length - maxOverlap)
    Map<String, int> minContribution,

    // Map of word -> unique index (for bitset)
    Map<String, int> uniqueWordIndex,

    // Bitset of placed unique words
    _SimpleBitSet placedWordsMask,

    // Current sum of minContribution for all UNPLACED unique words
    int neededUniqueSpace,
  ) {
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

    // Build sorted candidate list.
    // For each word in the frontier, we find the earliest valid placement
    // considering each distinct parent constraint.
    final wordCandidates = <String, Map<int, List<_TrieNode>>>{};
    for (final entry in frontier.entries) {
      final word = entry.key;
      final nodes = entry.value;
      final cellCodes = wordCells[word]!;

      // Identify all distinct minimum offsets required by parents
      final requiredMinOffsets = nodes
          .map((n) => _computeMinOffsetAfter(n.parentEndOffset))
          .toSet();

      for (final minOffset in requiredMinOffsets) {
        final offset = _findValidPlacement(grid, cellCodes, minOffset);
        if (offset != null) {
          // Identify ALL nodes for this word satisfied by this placement
          final satisfied = nodes
              .where((n) => offset >= _computeMinOffsetAfter(n.parentEndOffset))
              .toList();

          // If multiple triggers lead to the same offset, store the most satisfied nodes
          final existing = wordCandidates.putIfAbsent(word, () => {})[offset];
          if (existing == null || satisfied.length > existing.length) {
            wordCandidates[word]![offset] = satisfied;
          }
        }
      }
    }

    final candidates = <_FrontierCandidate>[];
    for (final wordEntry in wordCandidates.entries) {
      final word = wordEntry.key;
      for (final offsetEntry in wordEntry.value.entries) {
        final offset = offsetEntry.key;
        final nodes = offsetEntry.value;
        candidates.add(
          _FrontierCandidate(word, nodes, nodes.first.rank, offset),
        );
      }
    }

    // Sort candidates:
    // 1. Lower rank first (logical dependency)
    // 2. More nodes satisfied first (efficient sharing)
    // 3. Longer words first (packing)
    // 4. Earlier offset first (compactness)
    candidates.sort((a, b) {
      if (a.rank != b.rank) return a.rank.compareTo(b.rank);
      if (a.nodes.length != b.nodes.length) {
        return b.nodes.length.compareTo(a.nodes.length);
      }
      if (a.word.length != b.word.length) {
        return b.word.length.compareTo(a.word.length);
      }
      return a.offset.compareTo(b.offset);
    });

    for (final candidate in candidates) {
      final word = candidate.word;
      final nodes = candidate.nodes;
      final offset = candidate.offset;
      final cellCodes = wordCells[word]!;

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

      // Advance frontier and capture undo info
      // Also calculate change in needed unique space
      final trieUndo = _advanceFrontierWithUndo(frontier, nodes, endOffset);

      // Unique Word Space Tracking
      int spaceDelta = 0;
      final wordIdx = uniqueWordIndex[word]!;
      final wasUnplaced = !placedWordsMask.isSet(wordIdx);
      if (wasUnplaced) {
        placedWordsMask.set(wordIdx);
        spaceDelta = minContribution[word] ?? 0;
      }

      // Recurse with updated frontier
      _solveTrie(
        grid,
        trie,
        frontier,
        wordCells,
        minContribution,
        uniqueWordIndex,
        placedWordsMask,
        neededUniqueSpace - spaceDelta,
      );

      // Backtrack: undo frontier changes and node offsets
      _undoFrontierAdvance(frontier, trieUndo);
      _removeWord(grid, placement, savedMaxEndOffset);

      // Undo Unique Word Space Tracking
      if (wasUnplaced) {
        placedWordsMask.clear(wordIdx);
      }

      if (_shouldStop) return;
    }
  }

  /// Assign ranks and min contributions to all trie nodes.
  void _annotateTrie(
    _PhraseTrie trie,
    Map<String, int> wordRank,
    Map<String, int> minContribution,
  ) {
    void annotateRecursive(_TrieNode node) {
      node.rank = wordRank[node.word] ?? 0;
      node.minContribution = minContribution[node.word] ?? 0;

      for (final child in node.children.values) {
        annotateRecursive(child);
      }
    }

    for (final root in trie.roots.values) {
      annotateRecursive(root);
    }
  }

  /// Advance frontier and return undo information.
  /// This avoids copying the entire frontier for backtracking.
  _FrontierUndoInfo _advanceFrontierWithUndo(
    Map<String, List<_TrieNode>> frontier,
    List<_TrieNode> nodes,
    int placementEndOffset,
  ) {
    final word = nodes.first.word;
    final removedNodes = List<_TrieNode>.of(nodes);

    // Save node offsets and track children added
    final savedOffsets = <(_TrieNode, int, int)>[];
    final addedChildren = <(_TrieNode, String)>[]; // (child, wordKey)

    // 1. Remove ONLY the specific nodes we are advancing from the frontier
    final list = frontier[word]!;
    for (final node in nodes) {
      list.remove(node);
    }
    if (list.isEmpty) {
      frontier.remove(word);
    }

    for (final node in nodes) {
      savedOffsets.add((node, node.parentEndOffset, node.endOffset));
      node.endOffset = placementEndOffset;

      for (final child in node.children.values) {
        savedOffsets.add((child, child.parentEndOffset, child.endOffset));
        child.parentEndOffset = placementEndOffset;

        // Track if we're adding to existing list or creating new entry
        frontier.putIfAbsent(child.word, () => []).add(child);
        addedChildren.add((child, child.word));
      }
    }

    return _FrontierUndoInfo(
      removedWord: word,
      removedNodes: removedNodes,
      savedOffsets: savedOffsets,
      addedChildren: addedChildren,
    );
  }

  /// Undo frontier advance using saved undo info.
  void _undoFrontierAdvance(
    Map<String, List<_TrieNode>> frontier,
    _FrontierUndoInfo undoInfo,
  ) {
    // Restore node offsets
    for (final (node, parentEnd, end) in undoInfo.savedOffsets) {
      node.parentEndOffset = parentEnd;
      node.endOffset = end;
    }

    // Remove added children (in reverse order)
    for (int i = undoInfo.addedChildren.length - 1; i >= 0; i--) {
      final (child, wordKey) = undoInfo.addedChildren[i];
      final list = frontier[wordKey]!;
      list.remove(child);
      if (list.isEmpty) {
        frontier.remove(wordKey);
      }
    }

    // Restore removed word's nodes
    frontier
        .putIfAbsent(undoInfo.removedWord, () => [])
        .addAll(undoInfo.removedNodes);
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
    while (offset <= maxOffset) {
      final col = offset % width;
      if (col > maxCol) {
        offset = (offset ~/ width + 1) * width;
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
    Map<String, List<_TrieNode>> frontier,
  ) {
    if (now.difference(_lastProgressReport).inSeconds < 1) return;
    if (onProgress == null) return;

    _lastProgressReport = now;

    // Count phrases remaining (terminal nodes still in frontier)
    final allNodes = frontier.values.expand((list) => list).toList();
    final phrasesRemaining = allNodes.where((n) => n.isTerminal).length;
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

    // Debug: show frontier status
    print(
      'DEBUG: ${allNodes.length} frontier nodes in ${frontier.length} words ($phrasesRemaining phrases remaining)',
    );
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
  final Map<String, List<int>> wordCells;
  final Map<String, int>
  wordRank; // Topological rank of word (lower = earlier in phrases)
  final Map<String, int> minContribution; // Min space contribution
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
      node = node.children.putIfAbsent(
        words[i],
        () => _TrieNode(word: words[i], depth: i + 1),
      );
    }

    // Mark terminal
    node.isTerminal = true;
    node.terminalPhrases.add(phrase);
    phraseCount++;
  }
}

/// A node in the phrase trie.
class _TrieNode {
  /// The word at this node
  final String word;

  /// Depth in trie (1 for first word, etc.)
  final int depth;

  /// Min contribution of this word to grid space
  int minContribution = 0;

  /// Pre-computed topological rank for sorting
  int rank = 0;

  /// Children: word -> child node
  final Map<String, _TrieNode> children = {};

  /// True if this node is the end of at least one phrase
  bool isTerminal = false;

  /// Which phrases end at this node
  final List<String> terminalPhrases = [];

  /// The end offset of the parent/predecessor word.
  int parentEndOffset = -1;

  /// The end offset where this node's word was placed.
  int endOffset = -1;

  _TrieNode({required this.word, required this.depth});

  @override
  String toString() =>
      'TrieNode($word, depth=$depth, terminal=$isTerminal, parentEnd=$parentEndOffset)';
}

/// A simple bitset implementation using Uint32List.
class _SimpleBitSet {
  final Uint32List _data;

  _SimpleBitSet(int length) : _data = Uint32List((length + 31) ~/ 32);

  bool isSet(int index) {
    final i = index ~/ 32;
    final mask = 1 << (index % 32);
    return (_data[i] & mask) != 0;
  }

  void set(int index) {
    final i = index ~/ 32;
    final mask = 1 << (index % 32);
    _data[i] |= mask;
  }

  void clear(int index) {
    final i = index ~/ 32;
    final mask = 1 << (index % 32);
    _data[i] &= ~mask;
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

/// Candidate for frontier iteration.
class _FrontierCandidate {
  final String word;
  final List<_TrieNode> nodes;
  final int rank;
  final int offset;

  _FrontierCandidate(this.word, this.nodes, this.rank, this.offset);
}

/// Undo information for frontier advancement.
class _FrontierUndoInfo {
  final String removedWord;
  final List<_TrieNode> removedNodes;
  final List<(_TrieNode, int, int)> savedOffsets;
  final List<(_TrieNode, String)> addedChildren;

  _FrontierUndoInfo({
    required this.removedWord,
    required this.removedNodes,
    required this.savedOffsets,
    required this.addedChildren,
  });
}
