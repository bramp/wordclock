import 'package:wordclock/languages/language.dart';

class Config {
  final int gridWidth;
  final int? seed;
  final WordClockLanguage language;
  final int targetHeight;
  final String algorithm;
  final int timeout;
  final bool useRanks;

  Config({
    required this.gridWidth,
    this.seed,
    required this.language,
    required this.targetHeight,
    required this.algorithm,
    required this.timeout,
    required this.useRanks,
  });
}
