// ignore_for_file: avoid_print
import 'dart:math';
import 'dart:typed_data';
import 'package:wordclock/generator/backtracking/graph/cell_codec.dart';
import 'package:wordclock/generator/backtracking/graph/graph_builder.dart';
import 'package:wordclock/generator/model/grid_build_result.dart';
import 'package:wordclock/generator/model/grid_build_progress.dart';
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
    this.findFirstValid = true,
    this.onProgress,
  }) : random = Random(seed),
       paddingCells = WordGrid.splitIntoCells(language.paddingAlphabet),
       _minHeightFound = height,
       _maxAllowedOffset = height * width;

  /// Attempts to build a grid that satisfies all constraints.
  GridBuildResult build() {
    codec = CellCodec();

    // 1. Build the phrase trie and collect unique words
    final trieData = _buildPhraseTrie();
    final trie = trieData.trie;
    final uniqueWords = trieData.uniqueWords;
    final wordCells = trieData.wordCells;

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
    final nodeCount = frontier.values.fold(0, (sum, list) => sum + list.length);

    // 4. Run the solver
    _solveTrie(grid, trie, frontier, wordCells, trieData.wordRank);

    // 6. Build result
    final finalState = _bestState;
    late final List<Cell> gridCells;
    late final List<public.WordPlacement> wordPlacements;

    if (finalState != null) {
      // Convert grid codes back to cells
      gridCells = List.generate(width * height, (i) {
        final code = finalState.cells[i];
        return code == _SimpleGrid.emptyCell ? ' ' : codec.decode(code);
      });
      // Build word placements
      wordPlacements = finalState.placements.map((p) {
        return public.WordPlacement(
          word: p.word,
          startOffset: p.startOffset,
          width: width,
          length: p.cellCodes.length,
        );
      }).toList();
    } else {
      gridCells = List.filled(width * height, ' ');
      wordPlacements = [];
    }

    final resultGrid = WordGrid(width: width, cells: gridCells);
    final validationIssues = GridValidator.validate(resultGrid, language);

    return GridBuildResult(
      grid: resultGrid,
      validationIssues: validationIssues,
      totalWords: _totalUniqueWords,
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

    return _TrieData(
      trie: trie,
      uniqueWords: uniqueWords.toList(),
      wordCells: wordCells,
      wordRank: wordRank,
    );
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
    Map<String, List<_TrieNode>> frontier,
    Map<String, List<int>> wordCells,
    Map<String, int> wordRank,
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

    // Solution found when frontier is empty (all paths reached terminal)
    if (frontier.isEmpty) {
      print('DEBUG: Frontier empty - all paths complete! Recording solution.');
      _recordCompletedState(grid);
      return;
    }

    // Sort frontier entries by topological rank from dependency graph.
    // Lower rank = fewer dependencies = should be placed earlier.
    final frontierEntries = frontier.entries.toList();
    frontierEntries.sort((a, b) {
      final rankA = wordRank[a.key] ?? 0;
      final rankB = wordRank[b.key] ?? 0;
      return rankA.compareTo(rankB);
    });

    for (final entry in frontierEntries) {
      final word = entry.key;
      final nodes = entry.value;
      final cellCodes = wordCells[word]!;

      // Find the MAXIMUM parentEndOffset among nodes needing this word.
      // A placement must be >= this to satisfy ALL nodes waiting for this word.
      int maxParentEndOffset = nodes.first.parentEndOffset;
      for (final node in nodes) {
        if (node.parentEndOffset > maxParentEndOffset) {
          maxParentEndOffset = node.parentEndOffset;
        }
      }
      final minOffset = _computeMinOffsetAfter(maxParentEndOffset);

      // Find valid grid placement for this word, starting from minOffset
      final offset = _findValidPlacement(grid, cellCodes, minOffset);
      if (offset == null) continue; // No valid placement, try next word

      final endOffset = offset + cellCodes.length - 1;
      final placement = _WordPlacement(
        word: word,
        startOffset: offset,
        endOffset: endOffset,
        cellCodes: cellCodes,
      );

      // Add to grid
      _placeWord(grid, placement);

      // Save frontier state for backtracking
      final savedFrontier = _copyFrontier(frontier);
      final savedOffsets = _saveNodeOffsets(nodes);

      // Advance the frontier: remove matched nodes, add their children
      _advanceFrontier(frontier, nodes, placement);
      
      // Debug: show frontier state after advancing
      if (_iterationCount < 20) {
        final nodeCount = frontier.values.fold(0, (sum, list) => sum + list.length);
        print('DEBUG: After placing "$word" at $offset: frontier=$nodeCount nodes in ${frontier.length} words');
        if (nodeCount < 10) {
          for (final nodes in frontier.values) {
            for (final node in nodes) {
              print('  - ${node.word} (terminal=${node.isTerminal}, parentEnd=${node.parentEndOffset})');
            }
          }
        }
      }

      // Recurse with updated frontier
      _solveTrie(grid, trie, frontier, wordCells, wordRank);

      // Backtrack: restore frontier and node offsets
      _restoreFrontier(frontier, savedFrontier);
      _restoreNodeOffsets(savedOffsets);
      _removeWord(grid, placement);

      if (_shouldStop) return;
    }
  }

  /// Advance frontier nodes that can use this placement.
  /// When a node's word is placed, it advances to its children.
  /// Mutates the frontier map and node offsets.
  void _advanceFrontier(
    Map<String, List<_TrieNode>> frontier,
    List<_TrieNode> nodes,
    _WordPlacement placement,
  ) {
    // Remove all nodes for this word from frontier upfront
    frontier.remove(placement.word);

    for (final node in nodes) {
      node.endOffset = placement.endOffset;
      
      // Add all children to frontier
      for (final child in node.children.values) {
        child.parentEndOffset = placement.endOffset;
        frontier.putIfAbsent(child.word, () => []).add(child);
      }
    }
  }

  /// Make a copy of the frontier for backtracking.
  Map<String, List<_TrieNode>> _copyFrontier(Map<String, List<_TrieNode>> frontier) {
    return {for (final e in frontier.entries) e.key: List.of(e.value)};
  }

  /// Restore frontier from a saved copy.
  void _restoreFrontier(Map<String, List<_TrieNode>> frontier, Map<String, List<_TrieNode>> saved) {
    frontier.clear();
    frontier.addAll(saved);
  }

  /// Save node offsets for backtracking.
  List<(_TrieNode, int, int)> _saveNodeOffsets(List<_TrieNode> nodes) {
    final saved = <(_TrieNode, int, int)>[];
    for (final node in nodes) {
      saved.add((node, node.parentEndOffset, node.endOffset));
      for (final child in node.children.values) {
        saved.add((child, child.parentEndOffset, child.endOffset));
      }
    }
    return saved;
  }

  /// Restore node offsets from saved state.
  void _restoreNodeOffsets(List<(_TrieNode, int, int)> saved) {
    for (final (node, parentEnd, end) in saved) {
      node.parentEndOffset = parentEnd;
      node.endOffset = end;
    }
  }

  /// Compute minimum offset after a given end offset.
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
  void _removeWord(_SimpleGrid grid, _WordPlacement placement) {
    for (int i = 0; i < placement.cellCodes.length; i++) {
      final idx = placement.startOffset + i;
      grid.usage[idx]--;
      if (grid.usage[idx] == 0) {
        grid.cells[idx] = _SimpleGrid.emptyCell;
      }
    }
    grid.placements.removeLast();
    // Recalculate maxEndOffset
    grid.maxEndOffset = -1;
    for (final p in grid.placements) {
      if (p.endOffset > grid.maxEndOffset) {
        grid.maxEndOffset = p.endOffset;
      }
    }
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
        .map((p) => public.WordPlacement(
              word: p.word,
              startOffset: p.startOffset,
              width: width,
              length: p.cellCodes.length,
            ))
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
    print('DEBUG: ${allNodes.length} frontier nodes in ${frontier.length} words ($phrasesRemaining phrases remaining)');
    
    // Show some phrases waiting for their final word (terminal nodes still in frontier)
    final waitingForFinalWord = allNodes.where((n) => n.isTerminal).take(3).toList();
    for (final node in waitingForFinalWord) {
      print('  Waiting for final word "${node.word}": ${node.terminalPhrases.first}');
    }
    
    // Show some phrases that need more than one word (non-terminal nodes)
    final needsMoreWords = allNodes.where((n) => !n.isTerminal).take(3).toList();
    for (final node in needsMoreWords) {
      final childWords = node.children.keys.toList();
      print('  Needs more words after "${node.word}": $childWords');
    }
  }

  bool get _shouldStop =>
      _stopRequested || (findFirstValid && _allComplete);

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
  final Map<String, int> wordRank; // Topological rank of word (lower = earlier in phrases)

  _TrieData({
    required this.trie,
    required this.uniqueWords,
    required this.wordCells,
    required this.wordRank,
  });
}

/// Simple phrase trie that stores phrases as word sequences.
/// 
/// Each path from root represents a phrase prefix. The trie has multiple
/// roots (one per unique first word).
class _PhraseTrie {
  /// Root-level children keyed by first word
  final Map<String, _TrieNode> roots = {};

  /// Count of phrases added
  int phraseCount = 0;

  void addPhrase(String phrase, List<String> words) {
    if (words.isEmpty) return;

    // Get or create root node for first word
    var node = roots.putIfAbsent(words[0], () => _TrieNode(word: words[0], depth: 1));

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
}

/// A node in the phrase trie.
class _TrieNode {
  /// The word at this node
  final String word;

  /// Depth in trie (1 for first word, etc.)
  final int depth;

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

  _TrieNode({required this.word, required this.depth}) : parentEndOffset = -1, endOffset = -1;

  @override
  String toString() => 'TrieNode($word, depth=$depth, terminal=$isTerminal, parentEnd=$parentEndOffset)';
}

/// A word placement with position info.
class _WordPlacement {
  final String word;
  final int startOffset;
  final int endOffset;
  final List<int> cellCodes;

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
  final Uint8List usage; // Reference count for each cell
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
