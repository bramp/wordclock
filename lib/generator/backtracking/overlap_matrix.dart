import 'dart:typed_data';
import 'package:wordclock/generator/backtracking/graph/word_node.dart';

/// Pre-computed matrix tracking which word pairs can potentially overlap.
///
/// Two words can overlap if there exists some alignment where all overlapping
/// characters match. For example:
/// - "AA" and "BB" cannot overlap (no common characters)
/// - "AB" and "BC" can overlap (B matches B)
/// - "ABC" and "BCD" can overlap at multiple alignments
///
/// This matrix enables O(1) lookup during placement search to skip words
/// that definitely cannot conflict with the word being placed.
class OverlapMatrix {
  /// Number of nodes in the matrix
  final int _nodeCount;

  /// Packed bit matrix: canOverlap[i * stride + (j ~/ 64)] & (1 << (j % 64))
  /// If bit is set, nodes i and j CAN overlap (share compatible characters).
  /// If bit is clear, they CANNOT overlap (guaranteed no conflict).
  final Uint64List _bits;

  /// Number of 64-bit words per row
  final int _stride;

  OverlapMatrix._({
    required int nodeCount,
    required Uint64List bits,
    required int stride,
  }) : _nodeCount = nodeCount,
       _bits = bits,
       _stride = stride;

  /// Build the overlap matrix for a list of word nodes.
  ///
  /// Sets node.matrixIndex on each node for O(1) lookup during placement search.
  factory OverlapMatrix.build(List<WordNode> nodes) {
    final n = nodes.length;
    final stride = (n + 63) ~/ 64; // Round up to 64-bit words
    final bits = Uint64List(n * stride);

    // Set matrixIndex on each node for O(1) lookup
    for (int i = 0; i < n; i++) {
      nodes[i].matrixIndex = i;
    }

    // For each pair, check if they can overlap
    for (int i = 0; i < n; i++) {
      final codesI = nodes[i].cellCodes;
      for (int j = i; j < n; j++) {
        final codesJ = nodes[j].cellCodes;
        if (_canWordsOverlap(codesI, codesJ)) {
          // Set bits for both (i,j) and (j,i) - matrix is symmetric
          _setBit(bits, stride, i, j);
          _setBit(bits, stride, j, i);
        }
      }
    }

    return OverlapMatrix._(nodeCount: n, bits: bits, stride: stride);
  }

  /// Check if two words can possibly overlap at any alignment.
  ///
  /// Words can overlap if for some relative offset, all overlapping
  /// positions have matching cell codes.
  static bool _canWordsOverlap(List<int> codesA, List<int> codesB) {
    final lenA = codesA.length;
    final lenB = codesB.length;

    // Try all possible alignments where they overlap
    // Offset is how far B is shifted right relative to A
    // Range: -(lenB-1) to (lenA-1) for any overlap
    for (int offset = -(lenB - 1); offset < lenA; offset++) {
      // Calculate overlap region
      final overlapStart = offset < 0 ? 0 : offset;
      final overlapEnd = offset + lenB < lenA ? offset + lenB : lenA;

      if (overlapStart >= overlapEnd) continue; // No overlap at this offset

      // Check if all overlapping positions match
      bool allMatch = true;
      for (int posA = overlapStart; posA < overlapEnd; posA++) {
        final posB = posA - offset;
        if (codesA[posA] != codesB[posB]) {
          allMatch = false;
          break;
        }
      }

      if (allMatch) {
        return true; // Found a valid overlap alignment
      }
    }

    return false; // No alignment works
  }

  static void _setBit(Uint64List bits, int stride, int i, int j) {
    bits[i * stride + (j ~/ 64)] |= (1 << (j % 64));
  }

  /// Check if two nodes can potentially overlap (share cells).
  ///
  /// Returns true if they might conflict, false if they definitely cannot.
  /// Uses node.matrixIndex for O(1) lookup.
  bool canOverlap(WordNode a, WordNode b) {
    final i = a.matrixIndex;
    final j = b.matrixIndex;
    if (i < 0 || j < 0) return true; // Unknown nodes: assume yes

    return (_bits[i * _stride + (j ~/ 64)] & (1 << (j % 64))) != 0;
  }

  /// Check if node at index i can overlap with node at index j.
  /// Prefer using [canOverlap] with WordNode directly for clarity.
  bool canOverlapByIndex(int i, int j) {
    return (_bits[i * _stride + (j ~/ 64)] & (1 << (j % 64))) != 0;
  }

  /// Number of nodes in the matrix
  int get length => _nodeCount;

  /// Debug: count how many pairs can overlap
  int countOverlapPairs() {
    int count = 0;
    for (int i = 0; i < _nodeCount; i++) {
      for (int j = i + 1; j < _nodeCount; j++) {
        if (canOverlapByIndex(i, j)) count++;
      }
    }
    return count;
  }

  /// Debug: get overlap statistics
  String getStats() {
    final totalPairs = _nodeCount * (_nodeCount - 1) ~/ 2;
    final overlapPairs = countOverlapPairs();
    final pct = totalPairs > 0 ? (overlapPairs * 100.0 / totalPairs) : 0;
    return 'OverlapMatrix: $overlapPairs/$totalPairs pairs can overlap (${pct.toStringAsFixed(1)}%)';
  }
}
