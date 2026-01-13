// ignore_for_file: avoid_print
import 'dart:io';

import 'package:wordclock/languages/all.dart';
import 'package:wordclock/languages/language.dart';
import 'package:wordclock/model/word_grid.dart';

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

  for (final file in languagesDir.listSync()) {
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
  String indent = '    ',
}) {
  final buffer = StringBuffer();

  // Add @generated marker with metadata
  buffer.writeln('$indent// @generated begin - do not edit manually');
  buffer.writeln(
    '$indent// Generated: ${metadata.timestamp.toIso8601String()}',
  );
  buffer.writeln('$indent// Algorithm: ${metadata.algorithm}');
  buffer.writeln('$indent// Seed: ${metadata.seed}');
  buffer.writeln(
    '$indent// Iterations: ${metadata.iterationCount}, Duration: ${metadata.duration.inMilliseconds}ms',
  );
  buffer.writeln('$indent\WordClockGrid(');
  buffer.writeln('$indent  isDefault: true,');

  // Try to preserve the existing strategy if possible, but for now we'll use the default one
  // from the language object.
  final strategy = lang.defaultGridRef!.timeToWords;
  // TODO: Export the constructor call string from TimeToWords itself?
  // For now, we hack it by getting the class name.
  final strategyName = strategy.runtimeType.toString();

  // Handle English space flag
  String strategyParams = '';
  if (strategyName.contains('English')) {
    // We assume we want useSpaceInTwentyFive: true for default grids now
    strategyParams = '(useSpaceInTwentyFive: true)';
  } else {
    strategyParams = '()';
  }

  buffer.writeln('$indent  timeToWords: $strategyName$strategyParams,');
  buffer.writeln(
    '$indent  paddingAlphabet: \'${lang.defaultGridRef!.paddingAlphabet}\',',
  );
  buffer.writeln('$indent  grid: WordGrid.fromLetters(');
  buffer.writeln('$indent    width: ${grid.width},');
  buffer.writeln('$indent    letters:');

  for (int row = 0; row < grid.height; row++) {
    final line = grid.cells
        .sublist(row * grid.width, (row + 1) * grid.width)
        .join('');
    // Escape special characters
    final escapedLine = line.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
    buffer.writeln("$indent      '$escapedLine'");
  }

  buffer.writeln('$indent  ),');
  buffer.writeln('$indent),');
  buffer.write('$indent// @generated end');

  return buffer.toString();
}

/// Updates the defaultGrid section in a language file for a specific language ID.
/// Returns true if successful, false otherwise.
bool updateLanguageFile(
  String languageId,
  WordGrid grid,
  GridGenerationMetadata metadata,
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
  );

  if (updatedContent == null) {
    print('Error: Could not find/replace defaultGrid for language $languageId');
    return false;
  }

  file.writeAsStringSync(updatedContent);
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
  GridGenerationMetadata metadata,
) {
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
        '${langBlock.substring(0, generatedMatch.start)}\n${generateGridCode(language, grid, metadata, indent: indent)},\n$indent${langBlock.substring(afterGenerated)}';
    return content.substring(0, langStart) +
        updatedLangBlock +
        content.substring(langEnd);
  }

  // Find plain defaultGrid pattern - need to handle nested parentheses
  final defaultGridStart = langBlock.indexOf('defaultGrid:');
  if (defaultGridStart == -1) {
    return null;
  }

  // Find the matching closing paren for WordGrid.fromLetters(...)
  final fromLettersStart = langBlock.indexOf(
    'WordGrid.fromLetters(',
    defaultGridStart,
  );
  if (fromLettersStart == -1) {
    return null;
  }

  // Find the matching closing paren
  int parenCount = 0;
  int defaultGridEnd = fromLettersStart;
  bool foundOpenParen = false;
  while (defaultGridEnd < langBlock.length) {
    final char = langBlock[defaultGridEnd];
    if (char == '(') {
      parenCount++;
      foundOpenParen = true;
    } else if (char == ')') {
      parenCount--;
      if (foundOpenParen && parenCount == 0) {
        defaultGridEnd++; // Include the closing paren
        break;
      }
    }
    defaultGridEnd++;
  }

  // Include any trailing comma
  if (defaultGridEnd < langBlock.length && langBlock[defaultGridEnd] == ',') {
    defaultGridEnd++;
  }

  // Get the indentation from the start of the defaultGrid line
  int indentStart = defaultGridStart;
  while (indentStart > 0 && langBlock[indentStart - 1] != '\n') {
    indentStart--;
  }
  final indent = langBlock.substring(indentStart, defaultGridStart);

  // Skip any whitespace after the trailing comma to find what comes next
  int afterDefaultGrid = defaultGridEnd;
  while (afterDefaultGrid < langBlock.length &&
      (langBlock[afterDefaultGrid] == ' ' ||
          langBlock[afterDefaultGrid] == '\t' ||
          langBlock[afterDefaultGrid] == '\n')) {
    afterDefaultGrid++;
  }

  final updatedLangBlock =
      '${langBlock.substring(0, indentStart)}${generateGridCode(language, grid, metadata, indent: indent)},\n$indent${langBlock.substring(afterDefaultGrid)}';

  return content.substring(0, langStart) +
      updatedLangBlock +
      content.substring(langEnd);
}

/// Gets all language IDs that can be solved.
List<String> getAllLanguageIds() {
  return WordClockLanguages.all.map((lang) => lang.id).toList();
}
