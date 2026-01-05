/// Represents a single character node within a word, used in the word clock graph.
///
/// Each [Node] uniquely identifies a character in a word, including its position
/// and occurrence.
///
/// Example:
/// ```dart
/// // For the word "HELLO", the second 'L' would have:
/// final node = Node(char: 'L', word: 'HELLO', charIndex: 3, index: 1);
/// ```
class Node {
  /// The character this node represents.
  ///
  /// Example: For the word "TIME", the first node would have `char = 'T'`.
  final String char;

  /// The word this character belongs to.
  ///
  /// Example: For the character 'I' in "TIME", `word = 'TIME'`.
  final String word;

  /// The index of this character within the word (0-based).
  ///
  /// Example: For the word "TIME", the 'M' has `charIndex = 2`.
  final int charIndex;

  /// The 0-based occurrence index of this character in the environment,
  /// used to keep Node indices unique but stable.
  final int index;

  const Node(this.char, this.word, this.charIndex, this.index);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Node &&
          runtimeType == other.runtimeType &&
          char == other.char &&
          word == other.word &&
          charIndex == other.charIndex &&
          index == other.index;

  @override
  int get hashCode =>
      char.hashCode ^ word.hashCode ^ charIndex.hashCode ^ index.hashCode;

  @override
  String toString() =>
      '${char == ' ' ? '(gap)' : char}_${word}_${charIndex}_$index';
}

/// A directed graph where nodes are [Node]s and edges represent dependencies.
typedef Graph = Map<Node, Set<Node>>;
