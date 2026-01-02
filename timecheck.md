# TimeCheck Reference Extraction

This project uses the logic and data from the [QLockTwo TimeCheck](https://qlocktwo.com/eu/timecheck) web application as the definitive reference implementation for our time-to-words logic. The source file is `check-new.js`, which is a bundled JavaScript file extracted from the website (or archive).

## Data Import

The logic relies on a JSON dataset extracted from the `check-new.js` JavaScript bundle. We have a script `bin/import_timecheck.dart` that handles this parsing and extraction.

To update `assets/timecheck_languages.json`:

1.  `wget https://qlocktwo.com/pub/static/frontend/Qlocktwo/Theme/de_DE/js/check-new.js`
2.  Run the import script:

    ```bash
    dart run bin/import_timecheck.dart
    ```

This will invoke `bin/dump_timecheck_json.js` (using `node`) to parse the configuration and generate the `assets/timecheck_languages.json` file used by the Dart application.

## Extraction Tool

We have a utility script located at `bin/extract_timecheck_times.js` that executes the `check-new.js` logic in a simulated browser environment (Node.js VM) to extract the expected "highlighted words" for every 5-minute interval of the day (00:00 to 23:55).

This allows us to treat the official QLockTwo logic as a "Source of Truth" to verify our Dart implementation against.

### Usage

Run the script using Node.js from the root of the repository:

```bash
# Extract output for all supported languages
node bin/extract_timecheck_times.js

# Extract output for a specific language code (e.g., E2 for English)
node bin/extract_timecheck_times.js --lang E2
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
