import 'package:wordclock/logic/time_to_words.dart';
import 'package:wordclock/model/word_grid.dart';

final class WordClockGrid {
  final bool isDefault;
  final bool isReference;

  final TimeToWords timeToWords;
  final String paddingAlphabet;
  final WordGrid grid;

  const WordClockGrid({
    this.isDefault = false,
    this.isReference = false,
    required this.timeToWords,
    this.paddingAlphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    required this.grid,
  });
}

final class WordClockLanguage {
  /// The unique identifier for this language (e.g., 'en', 'e3', 'pl').
  final String id;

  /// The BCP 47 language tag (e.g., 'en-US', 'zh-Hans-CN', 'en-US-x-digital').
  final String languageCode;

  /// The name of the language displayed to the user (Native language name).
  final String displayName;

  /// The English name of the language (e.g. 'French', 'Japanese').
  /// TODO: Remove this once we have a proper translation system.
  final String englishName;

  /// A short description of this variant (e.g. 'Standard', 'Alternative').
  /// TODO Remove the nullability and default to empty string.
  final String? description;

  final List<WordClockGrid> grids;

  WordClockGrid? get defaultGridRef => grids.cast<WordClockGrid?>().firstWhere(
    (g) => g!.isDefault,
    orElse: () => grids.cast<WordClockGrid?>().firstWhere(
      (g) => g!.isReference,
      orElse: () => grids.isNotEmpty ? grids.first : null,
    ),
  );

  WordClockGrid? get referenceGridRef => grids
      .cast<WordClockGrid?>()
      .firstWhere((g) => g!.isReference, orElse: () => null);

  /// Convenience getter for the default time-to-words strategy.
  TimeToWords get timeToWords => defaultGridRef!.timeToWords;

  /// The minute increment this language supports (e.g., 1 or 5).
  final int minuteIncrement;

  /// Whether words in the same phrase require at least one cell of padding (or a newline)
  /// between them in the grid. Languages like Japanese and Chinese typically don't.
  final bool requiresPadding;

  WordClockLanguage({
    required this.id,
    required this.languageCode,
    required this.displayName,
    this.englishName = '',
    this.description = '',
    required this.grids,
    this.minuteIncrement = 5,
    this.requiresPadding = true,
  }) : assert(
         grids.where((g) => g.isDefault).length <= 1,
         'A language can have at most one default grid.',
       );

  /// Tokenizes a phrase into units based on this language's configuration.
  ///
  /// Examples:
  ///     tokenize('IT IS FIVE') => ['IT', 'IS', 'FIVE']
  List<String> tokenize(String phrase) {
    return phrase.split(' ').where((w) => w.isNotEmpty).toList();
  }
}
