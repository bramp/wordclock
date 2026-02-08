import 'package:wordclock/logic/time_to_words.dart';
import 'package:wordclock/generator/utils/word_clock_utils.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';

/// Utilities for validating word clock grids against language constraints.
class GridValidator {
  /// Validates a grid against all language constraints.
  ///
  /// Returns a list of validation issues. Empty list means grid is valid.
  static List<String> validate(
    WordGrid grid,
    WordClockLanguage language, {
    int? expectedWidth,
    int? expectedHeight,
    TimeToWords? timeToWords,
    List<String> Function(String phrase)? customTokenizer,
  }) {
    final issues = <String>{};
    final cells = grid.cells;
    final width = grid.width;

    // Check grid structure
    if (cells.length % width != 0) {
      issues.add(
        'Grid cells length ${cells.length} is not a multiple of width $width.',
      );
    }

    if (expectedWidth != null && width != expectedWidth) {
      issues.add('Width $width != expected $expectedWidth.');
    }

    final height = cells.length ~/ width;
    if (expectedHeight != null && height != expectedHeight) {
      issues.add('Height $height != expected $expectedHeight.');
    }

    // Check phrase constraints
    final reportedMissingWords = <String>{};
    final reportedPaddingIssues = <String>{};

    WordClockUtils.forEachTime(language, (time, phrase) {
      final units = language.tokenize(phrase);

      // Use the official algorithm to find word sequences, enabling padding check if required
      final sequences = grid.getWordSequences(
        units,
        requiresPadding: language.requiresPadding,
      );

      // Verify the results
      int lastEndIndex =
          -1; // Track for re-verifying padding (redundant but safe)

      for (int i = 0; i < units.length; i++) {
        final unit = units[i];
        final indices = sequences[i];

        if (indices == null) {
          if (reportedMissingWords.add(unit)) {
            final timeStr =
                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
            issues.add(
              'Missing word "$unit" (in phrase "$phrase", at $timeStr)',
            );
          }
          // If we miss a word, we can't meaningfully check padding for subsequent words
          // relying on this one. But we continue to report other missing words.
          // Reset lastEndIndex? Or just break?
          // Original logic broke. Let's break.
          break;
        }

        if (i > 0 && lastEndIndex != -1) {
          if (indices.first <= lastEndIndex) {
            final pairKey = '${units[i - 1]}->$unit order';
            if (reportedPaddingIssues.add(pairKey)) {
              // Reuse set or create new one?
              final timeStr =
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
              issues.add(
                'Word "$unit" appears before or overlaps "${units[i - 1]}" in grid (for $phrase ($timeStr)). Strict reading order required.',
              );
            }
          }
        }

        // Check padding constraint to report specific error if the "best" found sequence still fails it
        if (language.requiresPadding && i > 0 && lastEndIndex != -1) {
          final matchIndex = indices.first;
          if (matchIndex == lastEndIndex + 1) {
            final prevRow = lastEndIndex ~/ width;
            final currRow = matchIndex ~/ width;
            if (prevRow == currRow) {
              final pairKey = '${units[i - 1]}->$unit';
              if (reportedPaddingIssues.add(pairKey)) {
                final timeStr =
                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                issues.add(
                  'No padding/newline between "${units[i - 1]}" and "$unit" in grid (at $timeStr). Phrase: "$phrase".',
                );
              }
            }
          }
        }

        lastEndIndex = indices.last;
      }
    }, timeToWords: timeToWords);

    return issues.toList();
  }

  /// Checks if a word can be placed after another word in the same phrase.
  ///
  /// Returns true if placement satisfies ordering and padding constraints.
  static bool canPlaceAfter({
    required int prevEndRow,
    required int prevEndCol,
    required int currStartRow,
    required int currStartCol,
    required bool requiresPadding,
  }) {
    // Check reading order (row-major)
    if (currStartRow < prevEndRow) {
      return false; // Current word is on earlier row
    }

    if (currStartRow == prevEndRow) {
      // Same row: current word must start after previous word ends
      if (currStartCol <= prevEndCol) {
        return false; // No reading order
      }

      // Check padding requirement (same row only)
      if (requiresPadding) {
        // Must have at least 1 cell gap
        if (currStartCol == prevEndCol + 1) {
          return false; // No gap!
        }
      }
    }

    // Different rows: reading order OK, newline acts as separator
    return true;
  }

  /// Checks if two word placements have proper separation.
  ///
  /// Returns true if they satisfy the padding constraint.
  static bool hasSeparation({
    required int word1Row,
    required int word1StartCol,
    required int word1EndCol,
    required int word2Row,
    required int word2StartCol,
    required int word2EndCol,
    required bool requiresPadding,
  }) {
    // Different rows: always OK (newline separation)
    if (word1Row != word2Row) {
      return true;
    }

    // No padding required: always OK
    if (!requiresPadding) {
      return true;
    }

    // Same row: check gap
    // word1 comes before word2
    if (word1EndCol < word2StartCol) {
      return word2StartCol - word1EndCol > 1; // At least 1 cell gap
    }

    // word2 comes before word1
    if (word2EndCol < word1StartCol) {
      return word1StartCol - word2EndCol > 1; // At least 1 cell gap
    }

    // They overlap or are adjacent - only OK if not padding required
    return false;
  }
}
