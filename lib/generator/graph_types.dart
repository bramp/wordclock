class Node {
  final String word;
  final int index; // 0-based occurrence index

  const Node(this.word, this.index);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Node &&
          runtimeType == other.runtimeType &&
          word == other.word &&
          index == other.index;

  @override
  int get hashCode => word.hashCode ^ index.hashCode;

  @override
  String toString() => '${word}_$index';
}

typedef Graph = Map<Node, Set<Node>>;
