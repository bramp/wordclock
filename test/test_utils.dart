// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/utils/font_helper.dart';

/// Helper to load fonts for golden tests.
Future<void> loadFonts() async {
  // Try to load all fonts defined in pubspec.yaml
  final fonts = FontHelper.familyToAsset;

  for (final entry in fonts.entries) {
    try {
      final loader = FontLoader(entry.key);
      final file = File(entry.value);
      if (!file.existsSync()) {
        print('ERROR: Font file not found: ${entry.value}');
        continue;
      }
      final fontData = file.readAsBytesSync();
      loader.addFont(Future.value(ByteData.view(fontData.buffer)));
      await loader.load();
      print('Loaded font: ${entry.key} from ${entry.value}');
    } catch (e) {
      print('FAILED to load font: ${entry.key} form ${entry.value}: $e');
    }
  }
}
