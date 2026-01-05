# WordClock

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

## Tools and Utilities

The project includes several CLI tools for development and visualization.

### Grid Builder (`bin/grid_builder.dart`)

Generates a character grid for a specific language or visualizes the word dependency graph.

**Generate a grid:**

```bash
dart run bin/grid_builder.dart --lang=en --width=11 --seed=42
```

**Visualize the dependency graph (Graphviz DOT):**

```bash
dart run bin/grid_builder.dart --lang=en --dot > graph.dot
dot -Tpng graph.dot -o graph.png
```

### CLI Clock (`bin/cli.dart`)

A command-line version of the word clock.

```bash
# Show current time in English
dart run bin/cli.dart

# Show a specific time in multiple languages
dart run bin/cli.dart 10:15 --lang=en,fr,de
```

### Import TimeCheck (`bin/import_timecheck.dart`)

Imports language definitions from the TimeCheck project.

```bash
dart run bin/import_timecheck.dart
```
