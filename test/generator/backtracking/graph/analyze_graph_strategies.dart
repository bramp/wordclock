import 'package:wordclock/generator/backtracking/graph/graph_builder.dart';
import 'package:wordclock/generator/utils/word_clock_utils.dart';
import 'package:wordclock/languages/all.dart';
import 'package:wordclock/languages/language.dart';

void main() {
  // ignore: avoid_print
  print('ID\tOptimal\tAsc\tDesc\tTrie\tBest');

  for (final language in WordClockLanguages.all) {
    final allPhrases = WordClockUtils.getAllPhrases(language).toList();
    final optimal = _calculateOptimalNodeCount(language);

    final ascPhrases = List<String>.from(allPhrases)
      ..sort((a, b) => a.length.compareTo(b.length));
    final descPhrases = List<String>.from(allPhrases)
      ..sort((a, b) => b.length.compareTo(a.length));

    final graphAsc = WordDependencyGraphBuilder.buildByPhrases(
      orderedPhrases: ascPhrases,
      language: language,
    );
    final countAsc = _nodeCount(graphAsc);

    final graphDesc = WordDependencyGraphBuilder.buildByPhrases(
      orderedPhrases: descPhrases,
      language: language,
    );
    final countDesc = _nodeCount(graphDesc);

    final graphTrie = WordDependencyGraphBuilder.buildWithTrie(
      language: language,
      phrases: allPhrases,
    );
    final countTrie = _nodeCount(graphTrie);

    final bestVal = [
      countAsc,
      countDesc,
      countTrie,
    ].reduce((a, b) => a < b ? a : b);

    String bestStrategy = '';
    if (countAsc == bestVal) bestStrategy += 'Asc ';
    if (countDesc == bestVal) bestStrategy += 'Desc ';
    if (countTrie == bestVal) bestStrategy += 'Trie';

    // ignore: avoid_print
    print(
      '${language.id}\t$optimal\t$countAsc\t$countDesc\t$countTrie\t$bestStrategy',
    );
  }
}

int _nodeCount(dynamic graph) {
  return (graph.nodes.values as Iterable).fold<int>(
    0,
    (int s, dynamic l) => s + (l as List).length,
  );
}

int _calculateOptimalNodeCount(WordClockLanguage language) {
  final phrases = WordClockUtils.getAllPhrases(language).toList();
  final maxOccurrences = <String, int>{};
  for (final phraseText in phrases) {
    final words = language.tokenize(phraseText);
    final counts = <String, int>{};
    for (final word in words) {
      counts[word] = (counts[word] ?? 0) + 1;
    }
    for (final entry in counts.entries) {
      final current = maxOccurrences[entry.key] ?? 0;
      if (entry.value > current) {
        maxOccurrences[entry.key] = entry.value;
      }
    }
  }
  return maxOccurrences.values.fold(0, (sum, count) => sum + count);
}
