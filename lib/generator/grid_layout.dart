import 'dart:math';
import 'package:wordclock/generator/graph_types.dart';

class GridLayout {
  static String generateString(
    int width,
    List<Node> orderedResult,
    Graph graph,
    Random random,
  ) {
    final buffer = StringBuffer();
    // We accumulate words for a single line, then flush them with distributed padding.
    List<String> currentLineWords = [];
    int currentLineLength = 0;

    // Track previous node to determine required padding betweeen words
    Node? prevNode;

    // Identify special "pinned" nodes
    // Note: We assume the first node is top-left and last is bottom-right based on topological sort/input
    final Node firstNode = orderedResult.first;
    final Node lastNode = orderedResult.last;

    void flushLine({required bool isLastLine}) {
      if (currentLineWords.isEmpty) return;
      final int paddingTotal = width - currentLineLength;
      String line = "";

      // 1. PIN TOP-LEFT: If this line contains the very first node (IT), padding goes at the END.
      if (currentLineWords.contains(firstNode.word) &&
          currentLineWords.first == firstNode.word) {
        line = currentLineWords.join("");
        line += _generatePadding(paddingTotal, random);
      }
      // 2. PIN BOTTOM-RIGHT: If this is the LAST line and contains the last node, padding goes at the START.
      else if (isLastLine && currentLineWords.contains(lastNode.word)) {
        line = _generatePadding(paddingTotal, random);
        line += currentLineWords.join("");
      }
      // 3. RANDOM SCATTER: Randomly split padding before and after
      else {
        // Split padding randomly
        final int paddingBefore = random.nextInt(paddingTotal + 1);
        final int paddingAfter = paddingTotal - paddingBefore;
        line += _generatePadding(paddingBefore, random);
        line += currentLineWords.join("");
        line += _generatePadding(paddingAfter, random);
      }
      buffer.write(line);

      // Clear for next line
      currentLineWords = [];
      currentLineLength = 0;
    }

    for (int i = 0; i < orderedResult.length; i++) {
      final node = orderedResult[i];
      final wordStr = node.word;

      // Determine if padding is required due to direct dependency
      // If A->B, we need at least 1 padding char if they are on the same line?
      bool needsSeparator = false;
      if (prevNode != null && graph[prevNode]?.contains(node) == true) {
        needsSeparator = true;
      }

      // Calculate space needed (Word + separator)
      int spaceNeeded = wordStr.length + (needsSeparator ? 1 : 0);

      // Check fit
      if (currentLineLength + spaceNeeded > width) {
        flushLine(isLastLine: false);
      }

      // Add separator if needed and not start of line
      if (currentLineWords.isNotEmpty && needsSeparator) {
        currentLineWords.add(_generatePadding(1, random));
        currentLineLength += 1;
      }
      currentLineWords.add(wordStr);
      currentLineLength += wordStr.length;
      prevNode = node;
    }
    // Flush remaining
    flushLine(isLastLine: true);
    return buffer.toString();
  }

  static String _generatePadding(int length, Random random) {
    // English Letter Frequency (Roughly)
    const String frequencyString =
        "EEEEEEEEEEE" // 11
        "AAAAAAAA" // 8
        "RRRRRR" // 6
        "IIIIII" // 6
        "OOOOOO" // 6
        "TTTTTT" // 6
        "NNNNN" // 5
        "SSSS" // 4
        "LLLL" // 4
        "CCCC" // 3
        "UUU" // 3
        "DDD" // 3
        "PPP" // 3
        "MMM" // 3
        "HHH" // 3
        "G"
        "B"
        "F"
        "Y"
        "W"
        "K"
        "V"
        "X"
        "Z"
        "J"
        "Q";
    return List.generate(
      length,
      (index) => frequencyString[random.nextInt(frequencyString.length)],
    ).join();
  }
}
