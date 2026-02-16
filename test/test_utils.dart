import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/utils/font_helper.dart';

/// Helper to load fonts for golden tests.
Future<void> loadFonts() async {
  // Try to load all fonts defined in pubspec.yaml
  final fonts = FontHelper.familyToAsset;

  for (final entry in fonts.entries) {
    final loader = FontLoader(entry.key);
    final fontData = File(entry.value).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(fontData.buffer)));
    await loader.load();
  }
}
