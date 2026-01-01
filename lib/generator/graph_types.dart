class Node {
  final String char;
  final String word;
  final int index; // 0-based occurrence index

  const Node(this.char, this.word, this.index);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Node &&
          runtimeType == other.runtimeType &&
          char == other.char &&
          word == other.word &&
          index == other.index;

  @override
  int get hashCode => char.hashCode ^ word.hashCode ^ index.hashCode;

  @override
  String toString() => '${char == ' ' ? '(gap)' : char}_${word}_$index';
}

typedef Graph = Map<Node, Set<Node>>;
