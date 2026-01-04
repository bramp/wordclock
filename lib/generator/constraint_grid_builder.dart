import 'dart:math';
import 'package:wordclock/generator/utils/word_clock_utils.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';

// ignore_for_file: library_private_types_in_public_api

/// A constraint-based grid builder that supports word overlap.
///
/// This builder places words on a 2D grid while respecting:
/// - Word order within phrases (time sentences)
/// - Required spacing/newlines between words in phrases
/// - Word overlap when characters match
/// - Preference for first word at top-left, last word at bottom-right
/// - Target grid dimensions
class ConstraintGridBuilder {
  final int width;
  final int height;
  final WordClockLanguage language;
  final Random random;

  // Grid state: [row][col] -> cell content
  final List<List<String?>> grid;

  // Track word placements: word -> list of positions
  final Map<String, List<_WordPlacement>> wordPlacements = {};

  // All phrases we need to support
  final List<_Phrase> phrases = [];

  // Padding alphabet
  final List<String> paddingCells;

  ConstraintGridBuilder({
    required this.width,
    required this.height,
    required this.language,
    required int seed,
  }) : random = Random(seed),
       paddingCells = WordGrid.splitIntoCells(language.paddingAlphabet),
       grid = List.generate(height, (_) => List.filled(width, null));

  /// Attempts to build a grid that satisfies all constraints.
  /// Returns the grid as a flat list of cells, or null if impossible.
  List<String>? build() {
    // 1. Collect all phrases
    _collectPhrases();

    // 2. Try to place all words
    if (!_placeAllWords()) {
      return null;
    }

    // 3. Fill remaining cells with padding
    _fillPadding();

    // 4. Convert to flat list
    return _gridToList();
  }

  void _collectPhrases() {
    WordClockUtils.forEachTime(language, (time, phrase) {
      final tokens = language.tokenize(phrase);
      if (tokens.isNotEmpty) {
        phrases.add(_Phrase(phrase, tokens));
      }
    });
  }

  bool _placeAllWords() {
    // Collect all unique words and their frequency
    final wordFrequency = <String, int>{};
    for (final phrase in phrases) {
      for (final word in phrase.words) {
        wordFrequency[word] = (wordFrequency[word] ?? 0) + 1;
      }
    }

    // Calculate average position in phrases (for ordering)
    final wordAvgPosition = <String, double>{};
    for (final word in wordFrequency.keys) {
      int totalPosition = 0;
      int count = 0;
      for (final phrase in phrases) {
        for (int i = 0; i < phrase.words.length; i++) {
          if (phrase.words[i] == word) {
            totalPosition += i;
            count++;
          }
        }
      }
      wordAvgPosition[word] = count > 0 ? totalPosition / count : 0;
    }

    // Sort words by:
    // 1. Average position in phrases (earlier words first to respect ordering)
    // 2. Length (longer first for better placement)
    // 3. Frequency (more common first)
    final uniqueWords = wordFrequency.keys.toList()
      ..sort((a, b) {
        // First, sort by average position in phrases
        final posCompare = wordAvgPosition[a]!.compareTo(wordAvgPosition[b]!);
        if (posCompare != 0) return posCompare;

        // Then by length (longer first)
        final lengthCompare = b.length.compareTo(a.length);
        if (lengthCompare != 0) return lengthCompare;

        // Finally by frequency (more common first)
        return wordFrequency[b]!.compareTo(wordFrequency[a]!);
      });

    // Try to place each word (may place multiple instances)
    for (final word in uniqueWords) {
      final cells = WordGrid.splitIntoCells(word);

      // Determine how many instances we need
      int needed = 0;
      for (final phrase in phrases) {
        int count = 0;
        for (final w in phrase.words) {
          if (w == word) count++;
        }
        needed = max(needed, count);
      }

      // Place this many instances
      for (int instance = 0; instance < needed; instance++) {
        if (!_placeWord(word, cells, instance)) {
          return false;
        }
      }
    }

    return true;
  }

  bool _placeWord(String word, List<String> cells, int instanceIndex) {
    // Find best position for this word
    final candidates = _findCandidatePositions(word, cells, instanceIndex);

    for (final candidate in candidates) {
      if (_tryPlaceAt(
        word,
        cells,
        candidate.row,
        candidate.col,
        instanceIndex,
      )) {
        return true;
      }
    }

    return false;
  }

  List<_Position> _findCandidatePositions(
    String word,
    List<String> cells,
    int instanceIndex,
  ) {
    final candidates = <_Position>[];

    // Special case: first word - prefer top-left
    if (wordPlacements.isEmpty && instanceIndex == 0) {
      candidates.add(_Position(0, 0, 1000)); // High score for first word
    }

    // Try all positions
    for (int row = 0; row < height; row++) {
      for (int col = 0; col <= width - cells.length; col++) {
        final score = _scorePosition(word, cells, row, col, instanceIndex);
        if (score > 0) {
          candidates.add(_Position(row, col, score));
        }
      }
    }

    // Sort by score descending
    candidates.sort((a, b) => b.score.compareTo(a.score));

    return candidates;
  }

  double _scorePosition(
    String word,
    List<String> cells,
    int row,
    int col,
    int instanceIndex,
  ) {
    // Check if position is valid
    int overlapCount = 0;

    for (int i = 0; i < cells.length; i++) {
      final c = col + i;
      if (c >= width) return -1;

      final existing = grid[row][c];
      if (existing == null) {
        // Empty cell - OK
      } else if (existing == cells[i]) {
        overlapCount++;
      } else {
        // Conflict
        return -1;
      }
    }

    // Score: prefer positions with some overlap (reuse), but not too much
    double score = 100.0;

    // Bonus for overlap (reusing existing letters)
    score += overlapCount * 50.0;

    // Small penalty for being far from existing words (if not first word)
    if (wordPlacements.isNotEmpty) {
      final distance = _distanceToNearestWord(row, col);
      score -= distance * 2.0;
    }

    // Prefer compact placement (top-left to bottom-right diagonal)
    final diagonalDistance = row + col;
    score -= diagonalDistance * 0.5;

    // Last word should prefer bottom-right
    final isLastWord = wordPlacements.length == _countUniqueWords() - 1;
    if (isLastWord) {
      final bottomRightScore =
          (height - 1 - row) + (width - 1 - (col + cells.length - 1));
      score -=
          bottomRightScore * 5.0; // Penalty for not being near bottom-right
    }

    return score;
  }

  int _countUniqueWords() {
    final unique = <String>{};
    for (final phrase in phrases) {
      unique.addAll(phrase.words);
    }
    return unique.length;
  }

  double _distanceToNearestWord(int row, int col) {
    double minDist = double.infinity;

    for (final placements in wordPlacements.values) {
      for (final placement in placements) {
        final dist = sqrt(
          pow(row - placement.row, 2) + pow(col - placement.col, 2),
        );
        minDist = min(minDist, dist);
      }
    }

    return minDist;
  }

  bool _tryPlaceAt(
    String word,
    List<String> cells,
    int row,
    int col,
    int instanceIndex,
  ) {
    // Check if this placement would satisfy phrase constraints
    if (!_checkPhraseConstraints(word, row, col, instanceIndex)) {
      return false;
    }

    // Place the word
    for (int i = 0; i < cells.length; i++) {
      grid[row][col + i] = cells[i];
    }

    // Record placement
    wordPlacements.putIfAbsent(word, () => []);
    wordPlacements[word]!.add(_WordPlacement(row, col, cells.length));

    return true;
  }

  bool _checkPhraseConstraints(
    String word,
    int row,
    int col,
    int instanceIndex,
  ) {
    // For each phrase containing this word, check if placement is valid
    for (final phrase in phrases) {
      if (!phrase.words.contains(word)) continue;

      // Check word order and spacing constraints
      if (!_validatePhraseOrder(phrase, word, row, col, instanceIndex)) {
        return false;
      }
    }

    return true;
  }

  bool _validatePhraseOrder(
    _Phrase phrase,
    String word,
    int row,
    int col,
    int instanceIndex,
  ) {
    // Find all occurrences of this word in the phrase
    final wordIndices = <int>[];
    for (int i = 0; i < phrase.words.length; i++) {
      if (phrase.words[i] == word) {
        wordIndices.add(i);
      }
    }

    if (wordIndices.isEmpty) return true;

    // For each occurrence, check constraints
    for (final wordIdx in wordIndices) {
      // Check previous word (if exists)
      if (wordIdx > 0) {
        final prevWord = phrase.words[wordIdx - 1];
        final prevPlacements = wordPlacements[prevWord];

        if (prevPlacements != null && prevPlacements.isNotEmpty) {
          // Previous word is placed - check reading order and spacing constraint
          for (final prevPlacement in prevPlacements) {
            final prevEndRow = prevPlacement.row;
            final prevEndCol = prevPlacement.col + prevPlacement.length - 1;

            // Current word starts at (row, col)
            // Must appear AFTER previous word in reading order (row-major, left-to-right)
            if (row < prevEndRow || (row == prevEndRow && col <= prevEndCol)) {
              return false; // Current word doesn't come after previous word in reading order
            }

            // Must have at least one space or newline between them
            if (language.requiresPadding) {
              // Same row: must have gap
              if (row == prevEndRow && col == prevEndCol + 1) {
                return false; // No gap!
              }
              // Different row: OK (newline acts as separator)
            }
          }
        }
      }

      // Check next word (if exists and already placed)
      if (wordIdx < phrase.words.length - 1) {
        final nextWord = phrase.words[wordIdx + 1];
        final nextPlacements = wordPlacements[nextWord];

        if (nextPlacements != null && nextPlacements.isNotEmpty) {
          // Next word is already placed - check reading order and spacing constraint
          for (final nextPlacement in nextPlacements) {
            final currentEndCol =
                col + WordGrid.splitIntoCells(word).length - 1;

            // Next word must appear AFTER current word in reading order
            if (nextPlacement.row < row ||
                (nextPlacement.row == row &&
                    nextPlacement.col <= currentEndCol)) {
              return false; // Next word doesn't come after current word in reading order
            }

            // Next word starts at nextPlacement position
            // Must have at least one space or newline between them
            if (language.requiresPadding) {
              // Same row: must have gap
              if (row == nextPlacement.row &&
                  nextPlacement.col == currentEndCol + 1) {
                return false; // No gap!
              }
              // Different row: OK (newline acts as separator)
            }
          }
        }
      }
    }

    return true;
  }

  void _fillPadding() {
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        if (grid[row][col] == null) {
          grid[row][col] = paddingCells[random.nextInt(paddingCells.length)];
        }
      }
    }
  }

  List<String> _gridToList() {
    final result = <String>[];
    for (final row in grid) {
      result.addAll(row.map((cell) => cell ?? ' '));
    }
    return result;
  }
}

class _Phrase {
  final String text;
  final List<String> words;

  _Phrase(this.text, this.words);
}

class _WordPlacement {
  final int row;
  final int col;
  final int length;

  _WordPlacement(this.row, this.col, this.length);
}

class _Position {
  final int row;
  final int col;
  final double score;

  _Position(this.row, this.col, this.score);
}
