import 'package:wordclock/logic/time_to_words.dart';
import 'package:wordclock/model/word_grid.dart';

import 'package:wordclock/logic/timecheck_time_to_words.dart';

final class WordClockLanguage {
  /// The unique identifier for this language (e.g., 'en', 'e3', 'pl').
  final String id;

  /// The BCP 47 language tag (e.g., 'en-US', 'zh-Hans-CN', 'en-US-x-digital').
  final String languageCode;

  /// The name of the language displayed to the user (Native Name).
  final String displayName;

  /// The English name of the language (e.g. 'French', 'Japanese').
  /// TODO: Remove this once we have a proper translation system.
  final String englishName;

  /// A short description of this variant (e.g. 'Standard', 'Alternative').
  final String? description;

  final TimeToWords timeToWords;

  final String paddingAlphabet;

  final WordGrid? _defaultGrid;

  /// The original grid from the TimeCheck dataset.
  final WordGrid? timeCheckGrid;

  /// The primary grid for this language. Defaults to [timeCheckGrid] if not provided.
  WordGrid? get defaultGrid => _defaultGrid ?? timeCheckGrid;

  /// The list of characters in the grid that are never used by any time.
  final List<TimeCheckWord>? padding;

  /// The minute increment this language supports (e.g., 1 or 5).
  final int minuteIncrement;

  /// Whether words in the same phrase require at least one cell of padding (or a newline)
  /// between them in the grid. Languages like Japanese and Chinese typically don't.
  final bool requiresPadding;

  WordClockLanguage({
    required this.id,
    required this.languageCode,
    required this.displayName,
    required this.englishName,
    this.description,
    required this.timeToWords,
    required this.paddingAlphabet,
    WordGrid? defaultGrid,
    this.timeCheckGrid,
    this.padding,
    this.minuteIncrement = 5,
    this.requiresPadding = true,
  }) : _defaultGrid = defaultGrid;
}
