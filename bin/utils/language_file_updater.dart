// ignore_for_file: avoid_print
import 'dart:io';

import 'package:wordclock/languages/all.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/generator/model/word_placement.dart';

/// Metadata for a generated grid
class GridGenerationMetadata {
  final String algorithm;
  final int seed;
  final DateTime timestamp;
  final int iterationCount;
  final Duration duration;

  GridGenerationMetadata({
    required this.algorithm,
    required this.seed,
    required this.timestamp,
    required this.iterationCount,
    required this.duration,
  });
}

/// Finds the language file path for a given language ID.
/// Returns null if not found.
String? findLanguageFilePath(String languageId) {
  final languagesDir = Directory('lib/languages');
  if (!languagesDir.existsSync()) {
    return null;
  }

  for (final file in languagesDir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      final content = file.readAsStringSync();
      // Look for id: 'XX' pattern where XX is the language ID
      final pattern = RegExp(r"id:\s*'" + RegExp.escape(languageId) + r"'");
      if (pattern.hasMatch(content)) {
        return file.path;
      }
    }
  }
  return null;
}

/// Generates the WordClockGrid code block with @generated marker.
String generateGridCode(
  WordClockLanguage lang,
  WordGrid grid,
  GridGenerationMetadata metadata, {
  List<WordPlacement> wordPlacements = const [],
  String indent = '    ',
}) {
  // Try to preserve the existing strategy if possible, but for now we'll use the default one
  // from the language object.
  final strategy = lang.defaultGridRef!.timeToWords;
  // TODO: Export the constructor call string from TimeToWords itself?
  // For now, we hack it by getting the class name.
  final strategyName = strategy.runtimeType.toString();

  // TODO Remove this feature
  final strategyParams = '()';

  // Group words by row for comments
  final rowWords = <int, List<String>>{};
  final sortedPlacements = List<WordPlacement>.from(wordPlacements)
    ..sort((a, b) => a.startOffset.compareTo(b.startOffset));

  for (final p in sortedPlacements) {
    // Strip instance suffix if present (e.g. "FIVE (#0)" -> "FIVE")
    final word = p.word.split(' (')[0];
    rowWords.putIfAbsent(p.row, () => []).add(word);
  }

  final rowLines = List.generate(grid.height, (row) {
    final line = grid.cells
        .sublist(row * grid.width, (row + 1) * grid.width)
        .join('');

    // Escape special characters
    final escapedLine = line.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
    final comment = rowWords[row]?.join(' ') ?? '';
    final commentStr = comment.isNotEmpty ? ' // $comment' : '';

    // Relative indentation of 6 spaces within the WordClockGrid block
    return "      '$escapedLine'$commentStr";
  }).join('\n');

  final template =
      '''
// @generated begin - do not edit manually
// Generated: ${metadata.timestamp.toIso8601String()}
// Algorithm: ${metadata.algorithm}
// Seed: ${metadata.seed}
// Iterations: ${metadata.iterationCount}, Duration: ${metadata.duration.inMilliseconds}ms
WordClockGrid(
  isDefault: true,
  timeToWords: $strategyName$strategyParams,
  paddingAlphabet: '${lang.defaultGridRef!.paddingAlphabet}',
  grid: WordGrid.fromLetters(
    width: ${grid.width},
    letters:
$rowLines
    ,
  ),
),
// @generated end''';

  return template
      .split('\n')
      .map((line) => line.isEmpty ? line : '$indent$line')
      .join('\n');
}

/// Updates the defaultGrid section in a language file for a specific language ID.
/// Returns true if successful, false otherwise.
bool updateLanguageFile(
  String languageId,
  WordGrid grid,
  GridGenerationMetadata metadata,
  List<WordPlacement> wordPlacements,
) {
  final filePath = findLanguageFilePath(languageId);
  if (filePath == null) {
    print('Error: Could not find language file for ID: $languageId');
    return false;
  }

  final file = File(filePath);
  final content = file.readAsStringSync();

  // Find the language block that contains this ID
  // We need to find the defaultGrid that belongs to this specific language ID
  final lang = WordClockLanguages.byId[languageId];
  if (lang == null) {
    print('Error: Unknown language ID: $languageId');
    return false;
  }

  final updatedContent = updateLanguageFileContent(
    content,
    lang,
    grid,
    metadata,
    wordPlacements: wordPlacements,
  );

  if (updatedContent == null) {
    print('Error: Could not find/replace defaultGrid for language $languageId');
    return false;
  }

  file.writeAsStringSync(updatedContent);

  // Format the updated file
  try {
    Process.runSync('dart', ['format', filePath]);
  } catch (e) {
    print('Warning: Failed to format $filePath: $e');
  }

  print('Updated $filePath for language $languageId');
  return true;
}

/// Replace the defaultGrid section for a specific language ID in the file content.
/// Returns the updated content, or null if the language ID or defaultGrid was not found.
/// This is the main logic function, exposed for testing.
String? updateLanguageFileContent(
  String content,
  WordClockLanguage language,
  WordGrid grid,
  GridGenerationMetadata metadata, {
  List<WordPlacement> wordPlacements = const [],
}) {
  final languageId = language.id;
  // Find the position of this language's id declaration
  final idPattern = RegExp(r"id:\s*'" + RegExp.escape(languageId) + r"'");
  final idMatch = idPattern.firstMatch(content);
  if (idMatch == null) {
    return null;
  }

  // Find the start of this language definition (look backwards for 'final')
  int langStart = idMatch.start;
  while (langStart > 0) {
    // Check for 'final ' keyword
    if (langStart >= 6 &&
        content.substring(langStart - 6, langStart) == 'final ') {
      langStart -= 6;
      break;
    }
    langStart--;
  }

  // Find the opening paren of WordClockLanguage(
  final openParenIndex = content.indexOf('(', langStart);
  if (openParenIndex == -1 || openParenIndex > idMatch.start + 100) {
    return null;
  }

  // Find the end of this language definition (balanced parentheses from the opening paren)
  int parenDepth = 0;
  int langEnd = openParenIndex;
  while (langEnd < content.length) {
    final char = content[langEnd];
    if (char == '(') {
      parenDepth++;
    } else if (char == ')') {
      parenDepth--;
      if (parenDepth == 0) {
        langEnd++;
        break;
      }
    }
    langEnd++;
  }

  // Include trailing semicolon if present
  if (langEnd < content.length && content[langEnd] == ';') {
    langEnd++;
  }

  // Extract the language block
  final langBlock = content.substring(langStart, langEnd);

  // Find defaultGrid section within this language block
  // First check for @generated block
  final generatedPattern = RegExp(
    r'\n([ \t]*)// @generated begin.*?// @generated end',
    dotAll: true,
  );
  final generatedMatch = generatedPattern.firstMatch(langBlock);

  if (generatedMatch != null) {
    // Replace existing @generated block, preserving the indentation (spaces/tabs only)
    final indent = generatedMatch.group(1) ?? '';

    // Find where the next field starts (skip comma and whitespace after @generated end)
    int afterGenerated = generatedMatch.end;
    // Skip trailing comma if present
    if (afterGenerated < langBlock.length && langBlock[afterGenerated] == ',') {
      afterGenerated++;
    }
    // Skip whitespace to find start of next field
    while (afterGenerated < langBlock.length &&
        (langBlock[afterGenerated] == ' ' ||
            langBlock[afterGenerated] == '\t' ||
            langBlock[afterGenerated] == '\n')) {
      afterGenerated++;
    }

    final updatedLangBlock =
        '${langBlock.substring(0, generatedMatch.start)}\n${generateGridCode(language, grid, metadata, wordPlacements: wordPlacements, indent: indent)},\n$indent${langBlock.substring(afterGenerated)}';
    return content.substring(0, langStart) +
        updatedLangBlock +
        content.substring(langEnd);
  }

  // 2. Find by plain defaultGrid pattern
  final defaultGridStart = langBlock.indexOf('defaultGrid:');
  if (defaultGridStart != -1) {
    return _replaceGridBlock(
      content,
      langStart,
      langEnd,
      langBlock,
      defaultGridStart,
      'defaultGrid:',
      language,
      grid,
      metadata,
      wordPlacements,
    );
  }

  // 3. Find by isDefault: true within a WordClockGrid
  final isDefaultStart = langBlock.indexOf(RegExp(r'isDefault:\s*true'));
  if (isDefaultStart != -1) {
    // Look backwards for WordClockGrid(
    int gridStart = isDefaultStart;
    while (gridStart > 0) {
      if (langBlock.substring(gridStart).startsWith('WordClockGrid(')) {
        break;
      }
      gridStart--;
    }

    if (gridStart > 0) {
      return _replaceGridBlock(
        content,
        langStart,
        langEnd,
        langBlock,
        gridStart,
        '', // No field name prefix to skip
        language,
        grid,
        metadata,
        wordPlacements,
      );
    }
  }

  return null;
}

/// Helper to replace a grid block once its start has been found.
String? _replaceGridBlock(
  String content,
  int langStart,
  int langEnd,
  String langBlock,
  int blockStart,
  String fieldPrefix,
  WordClockLanguage language,
  WordGrid grid,
  GridGenerationMetadata metadata,
  List<WordPlacement> wordPlacements,
) {
  // Find where the actual object initialization starts
  final openParenStart = langBlock.indexOf('(', blockStart);
  if (openParenStart == -1) return null;

  // Find the matching closing paren
  int parenCount = 0;
  int blockEnd = openParenStart;
  bool foundOpenParen = false;
  while (blockEnd < langBlock.length) {
    final char = langBlock[blockEnd];
    if (char == '(') {
      parenCount++;
      foundOpenParen = true;
    } else if (char == ')') {
      parenCount--;
      if (foundOpenParen && parenCount == 0) {
        blockEnd++; // Include the closing paren
        break;
      }
    }
    blockEnd++;
  }

  // Include any trailing comma
  if (blockEnd < langBlock.length && langBlock[blockEnd] == ',') {
    blockEnd++;
  }

  // Get the indentation from the start of the line
  int indentStart = blockStart;
  while (indentStart > 0 && langBlock[indentStart - 1] != '\n') {
    indentStart--;
  }
  final indent = langBlock.substring(indentStart, blockStart);

  // Skip any whitespace after the trailing comma to find what comes next
  int afterBlock = blockEnd;
  while (afterBlock < langBlock.length &&
      (langBlock[afterBlock] == ' ' ||
          langBlock[afterBlock] == '\t' ||
          langBlock[afterBlock] == '\n')) {
    afterBlock++;
  }

  final updatedLangBlock =
      '${langBlock.substring(0, indentStart)}${generateGridCode(language, grid, metadata, wordPlacements: wordPlacements, indent: indent)},\n$indent${langBlock.substring(afterBlock)}';

  return content.substring(0, langStart) +
      updatedLangBlock +
      content.substring(langEnd);
}

/// Gets all language IDs that can be solved.
List<String> getAllLanguageIds() {
  return WordClockLanguages.all.map((lang) => lang.id).toList();
}
