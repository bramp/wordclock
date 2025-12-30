# WordClock

A minimal, aesthetic word clock application built with Flutter. Inspired by Qlocktwo.

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
