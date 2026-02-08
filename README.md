# WordClock

[![Test](https://github.com/bramp/wordclock/actions/workflows/test.yml/badge.svg)](https://github.com/bramp/wordclock/actions/workflows/test.yml)
[![Deploy to GitHub Pages](https://github.com/bramp/wordclock/actions/workflows/deploy.yml/badge.svg)](https://github.com/bramp/wordclock/actions/workflows/deploy.yml)
[![codecov](https://codecov.io/gh/bramp/wordclock/branch/main/graph/badge.svg)](https://codecov.io/gh/bramp/wordclock)
[![Test Results](https://img.shields.io/badge/Codecov-Test_Results-blue)](https://codecov.io/gh/bramp/wordclock/tests)
[![License](https://img.shields.io/github/license/bramp/wordclock)](https://github.com/bramp/wordclock/blob/main/LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=flat&logo=Dart&logoColor=white)](https://dart.dev)
[![Repo Size](https://img.shields.io/github/repo-size/bramp/wordclock)](https://github.com/bramp/wordclock)
[![Last Commit](https://img.shields.io/github/last-commit/bramp/wordclock)](https://github.com/bramp/wordclock)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/bramp/wordclock/graphs/commit-activity)

 A minimal, aesthetic word clock application built with Flutter. Inspired by [QLOCKTWO](https://www.qlocktwo.com/).

Features:

- **Time to Words**: Converts current time into a grid of lighted words (e.g., "IT IS TWENTY FIVE TO TEN").
- **Stencil Design**: Uses a gradient background revealed by active letters.
- **Cross-Platform**: Runs on Android and Web.

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and configured.

### Running the App

#### Web

To run the app in your default browser (Chrome is recommended):

```bash
flutter run -d chrome
```

#### Android

Ensure you have an Android device connected or an emulator running.

```bash
flutter run -d android
```

### Building for Release

#### Web

```bash
flutter build web
```

The build artifacts will be in `build/web/`.

#### Android APK

```bash
flutter build apk
```

The APK will be in `build/app/outputs/flutter-apk/app-release.apk`.

## Development Setup

### Pre-commit Hooks

This project uses [pre-commit](https://pre-commit.com/) to ensure code quality.

1. Install `pre-commit` (e.g., via Homebrew on MacOS):

   ```bash
   brew install pre-commit
   ```

2. Install the hooks:

   ```bash
   pre-commit install
   ```

Now, every time you commit, the hooks (formatting, analysis, testing) will run automatically.

### Firebase Analytics

This project uses Firebase Analytics to track user engagement and app usage.

**Current Configuration:**
- ✅ Web and Android platforms are configured
- ✅ Google Analytics measurement ID: `G-8L3MVJBV65`
- ✅ Firebase project: `wordclock-me`

**Adding iOS or other platforms:**

If you need to add Firebase support for additional platforms (iOS, macOS, etc.):

1. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Reconfigure Firebase:
   ```bash
   flutterfire configure
   ```

3. Select the platforms you want to add when prompted

This will update `lib/firebase_options.dart` and add platform-specific configuration files (e.g., `GoogleService-Info.plist` for iOS).

**Testing Analytics:**

To verify analytics is working:
- **Web**: Check browser DevTools → Network for Firebase Analytics requests
- **Android**: Enable debug mode with `adb shell setprop debug.firebase.analytics.app com.bramp.wordclock`
- **Firebase Console**: View real-time events at [Firebase Console](https://console.firebase.google.com/) → Analytics → DebugView

## Tools and Utilities

The project includes several CLI tools for development and visualization.

### Grid Builder (`bin/grid_builder.dart`)

Generates, visualizes, and validates word grids.

**Usage:**

```bash
dart run bin/grid_builder.dart <command> [arguments]
```

**Commands:**

- **Solve**: Generate a new grid layout.
  ```bash
  # Generate a 11x10 grid for English using backtracking
  dart run bin/grid_builder.dart solve --lang=en --width=11 --height=10
  ```

- **View**: Visualize an existing grid (color-coded).
  ```bash
  # View the default grid for Romanian
  dart run bin/grid_builder.dart view --lang=ro --grid=default
  ```

- **Graph**: Generate dependency graph in DOT format.
  ```bash
  # Generate graph for English and save to PNG
  dart run bin/grid_builder.dart graph --lang=en > graph.dot
  dot -Tpng graph.dot -o graph.png
  ```

- **Check**: Validate grid consistency.
  ```bash
  # Check all languages
  dart run bin/grid_builder.dart check

  # Check specific language
  dart run bin/grid_builder.dart check --lang=ro
  ```

- **Debug**: Interactive debugger for backtracking failures.
  ```bash
  dart run bin/grid_builder.dart debug --lang=ro
  ```

### CLI Clock (`bin/cli.dart`)

A command-line version of the word clock.

```bash
# Show current time in English
dart run bin/cli.dart

# Show a specific time in multiple languages
dart run bin/cli.dart 10:15 --lang=en,fr,de
```

### Phrase Validation (`bin/validate_phrases.dart`)

Uses OpenAI's GPT models to validate that the generated phrases are grammatically correct and suitable for a word clock grid.

**Usage:**

```bash
# Preview the prompts without sending them to OpenAI (default)
dart run bin/validate_phrases.dart

# Send prompts to OpenAI for validation (requires OPENAI_API_KEY)
export OPENAI_API_KEY="your-key"
dart run bin/validate_phrases.dart --no-dry-run
```

The results are saved as Markdown files in the `phrases_validation/` directory, including scores, identified issues, and phrasing suggestions.

## Adding a New Language

Adding a new language to WordClock involves defining the logic for telling time, generating a letter grid, and ensuring the necessary fonts are available.

### 1. Create Language File

Create a new file in `lib/languages/<language>.dart` (e.g., `italian.dart`). You need to extend `WordClockLanguage` and implement the `timeToWords` logic.

```dart
class ItalianLanguage extends WordClockLanguage {
  // ... implementation ...
}
```

### 2. Register Language

Add your new language instance to the `WordClockLanguages.all` list in `lib/languages/all.dart`.

```dart
static final List<WordClockLanguage> all = [
  // ...
  italianLanguage,
  // ...
];
```

### 3. Generate Grid

Use the `grid_builder` tool to generate an optimized letter grid for your language. This tool uses backtracking to verify that all possible 5-minute time intervals can be displayed on the grid.

```bash
# Example: Generate a 11x10 grid for Italian and update the file
dart run bin/grid_builder.dart solve --lang=it --width=11 --height=10 -u
```

The `-u` (or `--update`) flag will automatically locate your language file and insert the generated grid. If you omit this flag, the tool will print the grid code to the console for you to copy-paste.

### 4. Build Fonts

WordClock uses subsetted fonts (Noto Sans) to minimize app size and work offline. You must rebuild the fonts to include any new characters from your added language.

**Step A: Extract Characters**\
Run the extraction script to scan the codebase and language files for every character used.
```bash
dart run tool/extract_chars.dart
# Generates characters.txt
```

**Step B: Subset Fonts**\
Run the shell script to download source fonts and generate optimized subsets.
```bash
./tool/subset_fonts.sh
```

### 5. Verify

Run the tests to ensure everything is wired up correctly and no font loading errors occur.

```bash
flutter test
```

## Related

* https://www.qlocktwo.com/
* https://www.kickstarter.com/projects/1629174995/word-clock-a-living-canvas
  * Has lots of "clever" features.
* Shaper Image Word Clock
  * Review https://www.youtube.com/watch?v=e04TjcN8k2Y&t=309s
* https://www.kickstarter.com/projects/edcs/the-wordclock
* https://www.kickstarter.com/projects/420233999/the-tempus-fugit-wordclock
