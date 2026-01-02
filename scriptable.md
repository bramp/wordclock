# Scriptable Word Clock Widget Extraction

This project uses the logic and data from the original [Scriptable Word Clock Widget](https://github.com/mvan231/Scriptable-Word-Clock-Widget) (implied source) as a reference implementation for our time-to-words logic.

The source file is located at `ScriptableWordClockWidget/Word Clock Widget.js`.

## Data Import

The logic relies on a JSON dataset extracted from the original JavaScript file. We have a script `bin/import_scriptable.dart` that handles this parsing and extraction.

To update `assets/scriptable_languages.json`:

1.  Ensure `ScriptableWordClockWidget/Word Clock Widget.js` exists.
2.  Run the import script:

```bash
dart run bin/import_scriptable.dart
```

This will parse the JS file (using `node` internally) and generate the `assets/scriptable_languages.json` file used by the Dart application.

## Extraction Tool

We have a utility script located at `bin/extract_scriptable_highlights.js` that parses the original JavaScript source code to extract the expected "highlighted words" for every 5-minute interval of the day (00:00 to 23:55).

This allows us to treat the original widget's logic as a "Source of Truth" to verify our Dart implementation against.

### Usage

Run the script using Node.js from the root of the repository:

```bash
# Extract output for all supported languages
node bin/extract_scriptable_highlights.js

# Extract output for a specific language code (e.g., E2 for English)
node bin/extract_scriptable_highlights.js --lang E2
```

### Output Format

The script outputs one line per time interval in the format:
`HH:MM -> WORD1 WORD2 ...`

Example:
```text
00:00 -> IT IS TWELVE O'CLOCK
00:05 -> IT IS FIVE PAST TWELVE
...
```
