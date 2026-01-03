class Node {
  final String char;
  final String word;
  final int charIndex; // Index within the word
  final int index; // 0-based occurrence index for uniqueness

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

typedef Graph = Map<Node, Set<Node>>;
