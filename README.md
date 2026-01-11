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

### Import TimeCheck (`bin/import_timecheck.dart`)

Imports language definitions from the TimeCheck project.

```bash
dart run bin/import_timecheck.dart
```

## Related

* https://www.qlocktwo.com/
* https://www.kickstarter.com/projects/1629174995/word-clock-a-living-canvas
  * Has lots of "clever" features.
* Shaper Image Word Clock
  * Review https://www.youtube.com/watch?v=e04TjcN8k2Y&t=309s
* https://www.kickstarter.com/projects/edcs/the-wordclock
* https://www.kickstarter.com/projects/420233999/the-tempus-fugit-wordclock
