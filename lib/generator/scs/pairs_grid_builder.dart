// ignore_for_file: avoid_print
import 'dart:math';

import 'package:wordclock/generator/model/grid_build_result.dart';
import 'package:wordclock/generator/model/word_placement.dart' as public;
import 'package:wordclock/generator/utils/grid_validator.dart';
import 'package:wordclock/generator/utils/word_clock_utils.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/types.dart';
import 'package:wordclock/generator/backtracking/graph/graph_builder.dart';
import 'package:wordclock/model/word_grid.dart';

/// A grid builder that uses the "Hierarchical Merge" (Pairs) algorithm for solving
/// the Shortest Common Supersequence (SCS) problem.
///
/// It treats every time phrase as a sequence of words (sentence).
/// It iteratively merges the pair of sentences with the most overlap (LCS)
/// until a single long sequence of words remains.
/// Then it wraps this sequence onto the grid.
///
/// WARNING: This builder currently does not work. It never seems to find a solution.
class PairsGridBuilder {
  final int width;
  final int height;
  final WordClockLanguage language;

  // SCS ignores the random seed as it is a deterministic algorithm (mostly),
  // unless we want to break ties randomly.
  final Random random;

  final String? paddingAlphabet;

  PairsGridBuilder({
    required this.width,
    required this.height,
    required this.language,
    required int seed,
    this.paddingAlphabet,
  }) : random = Random(seed);

  GridBuildResult build() {
    final startTime = DateTime.now();

    // 1. Collect all phrases as word sequences
    final uniquePhrases = <List<String>>[];
    final seen = <String>{};

    WordClockUtils.forEachTime(language, (time, phrase) {
      if (seen.contains(phrase)) return;
      seen.add(phrase);
      final words = language.tokenize(phrase);
      if (words.isNotEmpty) {
        uniquePhrases.add(words);
      }
    });

    if (uniquePhrases.isEmpty) {
      return GridBuildResult(
        grid: WordGrid(width: width, cells: List.filled(width * height, ' ')),
        validationIssues: [],
        totalWords: 0,
        wordPlacements: [],
        iterationCount: 0,
        startTime: startTime,
        stopReason: StopReason.completed,
      );
    }

    // Collect forbidden pairs first so we can use them in grid measurement
    final forbiddenPairs = <String>{};
    for (final phrase in uniquePhrases) {
      for (int i = 0; i < phrase.length - 1; i++) {
        forbiddenPairs.add('${phrase[i]}|${phrase[i + 1]}');
      }
    }

    // Compute topological ranks to guide SCS merge
    // Higher rank = later in the phrase (e.g. O'CLOCK)
    final graph = WordDependencyGraphBuilder.build(language: language);
    final nodeRanks = graph.computeRanks();
    final wordRanks = <String, int>{};
    for (final entry in nodeRanks.entries) {
      final word = entry.key.word;
      final rank = entry.value;
      if (rank > (wordRanks[word] ?? -1)) {
        wordRanks[word] = rank;
      }
    }

    // Note: forbiddenPairs was locally defined here in previous code, removing duplicate/local def
    // references below will use the one defined above.

    // 2. Hierarchical Merge (SCS)
    int iterationCount = 0;

    // We maintain a list of current sequences.
    // Optimization: Cache LCS scores between pairs?
    // Given N might be ~200, N^2 = 40,000.
    // In each step we reduce N by 1. Total N steps.
    // If we recompute all pairs: N * N^2 = N^3. 200^3 = 8,000,000.
    // Check if N is small enough. 8M strict ops is fine, but string comparisons and DP table...
    // DP table size average words 5x5 = 25 ints.
    // 8M * 25 ops = 200M ops. Might be 1-2 seconds. Acceptable.
    // Let's implement the naive verification first (recompute all or recompute relevant).
    // Actually, maintaining a cache is better.

    // For simplicity of implementation in first pass, I'll recompute the "row"
    // of the new merged string against all others.

    // Distance matrix: cache[i][j] = saving
    // Since list changes (remove j, replace i), indices shift.
    // Maybe use a Set or map of ID to sequence?

    // Let's use a wrapper class to track sequences
    var pool = uniquePhrases.map((p) {
      final len = _measureGridUsage(p, forbiddenPairs);
      return _Sequence(p, len);
    }).toList();

    // Initialize cache
    // Map<int, Map<int, int>> savingsCache = {}; // id -> id -> saving
    // IDs are unique.

    // Precompute all pairs
    // To identify best pair efficiently, maybe a PriorityQueue?
    // Or just scan the cache.
    // Let's just do full scan for simplicity first, optimize if slow.
    // Wait, N^3 might be too slow if N is large.
    // Actually, we only need to update entries involving the merged sequence.

    // Let's assign IDs to sequences to manage the cache.
    int nextId = 0;
    for (var s in pool) {
      s.id = nextId++;
    }

    // cache: key is (id1 << 32 | id2) -> saving
    // Using simple map string key "id1-id2" or just iterate.

    final savingsCache = <String, int>{};

    String getKey(int id1, int id2) => id1 < id2 ? '$id1-$id2' : '$id2-$id1';

    int computeSaving(_Sequence a, _Sequence b) {
      final key = getKey(a.id, b.id);
      if (savingsCache.containsKey(key)) {
        return savingsCache[key]!;
      }

      // We want to maximize "Grid Savings".
      // Saving = Cost(A) + Cost(B) - Cost(Merge(A, B))
      // Where Cost is the number of grid cells used (including fragmentation/padding).

      final mergedWords = _computeSCS(a.words, b.words, wordRanks);
      final mergedCost = _measureGridUsage(mergedWords, forbiddenPairs);

      final saving = a.gridLength + b.gridLength - mergedCost;
      savingsCache[key] = saving;
      return saving;
    }

    while (pool.length > 1) {
      iterationCount++;

      int bestSaving = -9999999; // Can be negative
      _Sequence? bestA;
      _Sequence? bestB;

      // Find best pair
      // checking all pairs is O(N^2).
      // We can optimize this by only checking pairs involving the new guy and existing guys.
      // But preserving the "best global pair" requires checking everyone.
      // If we cache, we just look up.

      // Since we are iterating, we can just track the max in the cache?
      // But the cache contains stale entries if we remove items.

      // Strategy:
      // 1. Initial pass: Compute all pairs, populate cache.
      // 2. Loop:
      //    a. Find max in cache (filtering out removed IDs).
      //    b. Merge.
      //    c. Remove old IDs from cache (or ignore them).
      //    d. Compute savings for NewID vs All Remaining IDs. Add to cache.

      // Correct.

      // Initial population
      if (iterationCount == 1) {
        for (int i = 0; i < pool.length; i++) {
          for (int j = i + 1; j < pool.length; j++) {
            computeSaving(pool[i], pool[j]); // Populate cache
          }
        }
      }

      // Find best
      // To avoid iterating the whole map (which grows with stale entries),
      // we might want to clean up or just iterate the active pool.
      // Iterating active pool O(N^2) is fast enough if looking up in cache is O(1).

      for (int i = 0; i < pool.length; i++) {
        for (int j = i + 1; j < pool.length; j++) {
          final s = computeSaving(pool[i], pool[j]); // lookup or compute
          if (s > bestSaving) {
            bestSaving = s;
            bestA = pool[i];
            bestB = pool[j];
          }
        }
      }

      if (bestA == null || bestB == null) {
        break; // Should not happen
      }

      // Merge
      // Note: we recompute SCS here, but it's cheap relative to the loop.
      // Optimization: computeSaving could cache the result string too?
      final newWords = _computeSCS(bestA.words, bestB.words, wordRanks);
      final newCost = _measureGridUsage(newWords, forbiddenPairs);
      final newSeq = _Sequence(newWords, newCost)..id = nextId++;

      // Remove old
      pool.remove(bestA);
      pool.remove(bestB);

      // Add new
      pool.add(newSeq);

      // We don't strictly need to clear cache entries for A and B, we just won't index them anymore.
      // But we must ensure computeSaving computes for (New, X).
    }

    final finalSequence = pool.first.words;

    // 3. Wrap onto grid
    return _placeOnGrid(
      finalSequence,
      forbiddenPairs,
      iterationCount,
      startTime,
    );
  }

  GridBuildResult _placeOnGrid(
    List<String> words,
    Set<String> forbiddenPairs,
    int iterations,
    DateTime startTime,
  ) {
    // We treat the grid as a continuous flow of cells.
    // "Wrapping correctly at word boundaries" -> standard text wrapping.

    final cells = List<Cell>.filled(width * height, ' '); // or padding
    final placements = <public.WordPlacement>[];

    int currentRow = 0;
    int currentCol = 0;
    String? lastWordOnRow;

    // We need to verify if the words fit.

    // Helper to check if a word matches the grid content ending at endCol
    bool matchesGridSuffix(String word, int endCol, int length) {
      final startOffset = currentRow * width + (endCol - length);
      for (int i = 0; i < length; i++) {
        if (cells[startOffset + i] != word[i]) return false;
      }
      return true;
    }

    // Helper to write a word
    bool placeWord(String word) {
      final len = word.length;
      int bestOverlap = 0;

      // Check for overlap if allowed
      if (!language.requiresPadding && currentCol > 0) {
        // Can only overlap if not forbidden
        final pairKey = '${lastWordOnRow ?? ""}|$word';
        if (!forbiddenPairs.contains(pairKey)) {
          // Find max valid overlap k
          final maxPossible = min(currentCol, len);
          // We can overlap fully (len) if the word is already there?
          // Yes, that's valid reuse.
          for (int k = maxPossible; k >= 1; k--) {
            if (matchesGridSuffix(word, currentCol, k)) {
              bestOverlap = k;
              break;
            }
          }
        }
      }

      // Effective column if we overlap
      // If we overlap by k, we start at currentCol - k.
      // But we must check if the REST of the word fits on the line.
      final effectiveStartCol = currentCol - bestOverlap;
      final effectiveEndCol = effectiveStartCol + len;

      if (effectiveEndCol <= width) {
        // Fits on current line with overlap
        final startOffset = currentRow * width + effectiveStartCol;

        for (int i = 0; i < len; i++) {
          cells[startOffset + i] = word[i];
        }

        placements.add(
          public.WordPlacement(
            word: word,
            startOffset: startOffset,
            width: width,
            length: len,
          ),
        );

        currentCol = effectiveEndCol;
        lastWordOnRow = word;
        return true;
      }

      // Did not fit (even with overlap), so we must start fresh, possibly with padding.
      // Reset overlap logic.
      final padding = (currentCol > 0 && language.requiresPadding) ? 1 : 0;

      if (currentCol + padding + len <= width) {
        // Fits on current line (appended)
        currentCol += padding;
        final startOffset = currentRow * width + currentCol;

        for (int i = 0; i < len; i++) {
          cells[startOffset + i] = word[i];
        }

        placements.add(
          public.WordPlacement(
            word: word,
            startOffset: startOffset,
            width: width,
            length: len,
          ),
        );

        currentCol += len;
        lastWordOnRow = word;
        return true;
      } else {
        // Wrap to next line
        currentRow++;
        currentCol = 0;
        lastWordOnRow = null; // New row, can't overlap with previous

        if (currentRow >= height) {
          return false; // Grid full
        }

        // No padding at start of line
        if (currentCol + len <= width) {
          final startOffset = currentRow * width + currentCol;

          for (int i = 0; i < len; i++) {
            cells[startOffset + i] = word[i];
          }

          placements.add(
            public.WordPlacement(
              word: word,
              startOffset: startOffset,
              width: width,
              length: len,
            ),
          );

          currentCol += len;
          lastWordOnRow = word;
          return true;
        } else {
          return false; // Word wider than grid width?
        }
      }
    }

    for (final word in words) {
      if (!placeWord(word)) {
        print('\n--- FAILURE REPORT ---');
        print('Grid full! Could not place "$word"');
        print('SCS Sequence (${words.length} words):');
        print(words.join(' '));
        print('\nGrid State:');
        for (int row = 0; row < height; row++) {
          final rowCells = cells.sublist(row * width, (row + 1) * width);
          print(rowCells.map((c) => c == ' ' ? '.' : c).join(''));
        }
        print('----------------------\n');
        break;
      }
    }

    // Fill remaining with random padding if needed
    if (paddingAlphabet != null) {
      final paddingList = WordGrid.splitIntoCells(paddingAlphabet!);
      for (int i = 0; i < cells.length; i++) {
        if (cells[i] == ' ') {
          cells[i] = paddingList[random.nextInt(paddingList.length)];
        }
      }
    }

    final grid = WordGrid(width: width, cells: cells);
    final validationIssues = GridValidator.validate(grid, language);

    // Determine status
    // SCS goal is usually just to make it fit.
    final totalWords = words.length; // Or total unique words?
    // In this "wrapping" model, we preserve every instance of the SCS.
    // The "Total Words" metric for Word Clock usually refers to unique capability.
    // But here we built a specific text.
    // Let's use wordsPlaced.

    return GridBuildResult(
      grid: grid,
      validationIssues: validationIssues,
      totalWords: totalWords,
      wordPlacements: placements,
      iterationCount: iterations,
      startTime: startTime,
      stopReason: StopReason.completed,
    );
  }

  // --- SCS Helpers ---

  List<String> _computeSCS(
    List<String> A,
    List<String> B,
    Map<String, int> ranks,
  ) {
    final n = A.length;
    final m = B.length;
    final dp = List.generate(n + 1, (_) => List.filled(m + 1, 0));

    // Fill DP table for LCS
    for (int i = 1; i <= n; i++) {
      for (int j = 1; j <= m; j++) {
        if (A[i - 1] == B[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
          dp[i][j] = max(dp[i - 1][j], dp[i][j - 1]);
        }
      }
    }

    // Backtrack to build SCS
    // SCS is formed by including characters from A and B, using common ones once.
    // We build from end (result is reversed at the end).

    final result = <String>[];
    int i = n;
    int j = m;

    while (i > 0 && j > 0) {
      if (A[i - 1] == B[j - 1]) {
        // Common character, include it once
        result.add(A[i - 1]);
        i--;
        j--;
      } else {
        // LCS choice logic
        // If dp[i-1][j] > dp[i][j-1], it means LCS length is better if we ignore A[i-1] (move up).
        // This implies A[i-1] is NOT part of the LCS overlap.
        // So we must include A[i-1] in the supersequence.
        // But since we are moving UP, we process A[i-1] now.
        // The choice is: do we process A[i-1] or B[j-1] now?

        if (dp[i - 1][j] > dp[i][j - 1]) {
          // LCS comes from up
          result.add(A[i - 1]);
          i--;
        } else if (dp[i][j - 1] > dp[i - 1][j]) {
          // LCS comes from left
          result.add(B[j - 1]);
          j--;
        } else {
          // Both paths equal LCS length. Tie-breaker needed.
          // We are adding to the END of the SCS (since we reverse later).
          // Roughly: result[0] is the very last word of the SCS.
          // So we prefer words with HIGHER rank to be added NOW.
          final rankA = ranks[A[i - 1]] ?? 0;
          final rankB = ranks[B[j - 1]] ?? 0;

          if (rankA >= rankB) {
            result.add(A[i - 1]);
            i--;
          } else {
            result.add(B[j - 1]);
            j--;
          }
        }
      }
    }

    // Add remaining
    while (i > 0) {
      result.add(A[i - 1]);
      i--;
    }
    while (j > 0) {
      result.add(B[j - 1]);
      j--;
    }

    return result.reversed.toList();
  }

  /// Simulates wrapping the words onto the grid and returns the 'cost'
  /// (last used cell index + 1).
  ///
  /// This mirrors the logic in [_placeOnGrid] but without side effects.
  int _measureGridUsage(List<String> words, Set<String> forbiddenPairs) {
    int currentRow = 0;
    int currentCol = 0;
    String? lastWordOnRow;

    for (final word in words) {
      final len = word.length;
      int bestOverlap = 0;

      // Check overlap
      if (!language.requiresPadding && currentCol > 0) {
        final pairKey = '${lastWordOnRow ?? ""}|$word';
        if (!forbiddenPairs.contains(pairKey)) {
          // Simplistic overlap check for simulation:
          // We assume perfect suffix/prefix matching is allowed if not forbidden.
          // BUT: We don't have the "Grid Cells" to check content against!
          // We only have the words.
          // If we want exact measurement, we need to verify character match.
          // In simulation, we don't have the grid filled.
          // However, we are building the SCS from 'words'.
          // The SCS construction GUARANTEES that if we merge, characters match.
          // But here 'words' is the LIST of words in the SCS.
          // If unique phrase words are "A" and "B", SCS is "A", "B".
          // Overlap depends on string content.
          // So we CAN check string content here.

          final maxPossible = min(currentCol, len);
          for (int k = maxPossible; k >= 1; k--) {
            // Check if lastWordOnRow ends with the prefix of word
            // lastWordOnRow might be far back?
            // "Stacking" words: "THE" at 0..3. "THEY" at 0..4.
            // If we placed "THE", grid has 'T', 'H', 'E'.
            // if we place "THEY", we check if "THEY" prefix matches grid.
            // Since we know what we placed (lastWordOnRow is NOT enough, we need the whole row content).
            // But maintaining row content is expensive?
            // Actually, for this simulation, we can just assume:
            // If we placed 'wordA', then 'wordB'.
            // They overlap if wordA.suffix(k) == wordB.prefix(k).
            // What if wordA was 'hello', and we placed it at 0.
            // And now we place 'lower' (overlap 'lo').
            // Yes, standard string overlap.
            if (lastWordOnRow != null) {
              // We only check against the immediately preceding word for now in simulation.
              // This is a lower-bound on capability (conservative).
              // Real grid builder checks against CELLs, so handles complex overlaps.
              // Checking just last word is a safe approximation.
              if (lastWordOnRow.endsWith(word.substring(0, k))) {
                bestOverlap = k;
                break;
              }
            }
          }
        }
      }

      final effectiveStartCol = currentCol - bestOverlap;
      final effectiveEndCol = effectiveStartCol + len;

      if (effectiveEndCol <= width) {
        // Fits
        currentCol = effectiveEndCol;
        lastWordOnRow = word;
      } else {
        // Wrap (retry logic from placeOnGrid)
        final padding = (currentCol > 0 && language.requiresPadding) ? 1 : 0;
        if (currentCol + padding + len <= width) {
          // Fits with padding
          currentCol += padding + len;
          lastWordOnRow = word;
        } else {
          // New line
          currentRow++;
          currentCol = len; // at start of line
          lastWordOnRow = word;
        }
      }
    }

    // Result is total cells "used" up to the last point
    // used = rows_full * width + last_col
    return currentRow * width + currentCol;
  }
}

class _Sequence {
  int id = -1;
  final List<String> words;
  final int gridLength;

  _Sequence(this.words, this.gridLength);
}
