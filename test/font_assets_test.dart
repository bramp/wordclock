// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/utils/font_helper.dart';

void main() {
  test('Verify Font Assets Exist', () {
    print('Current Directory: ${Directory.current.path}');

    final fonts = FontHelper.familyToAsset;
    final missing = <String>[];

    for (final entry in fonts.entries) {
      final path = entry.value;
      final file = File(path);
      if (!file.existsSync()) {
        print('MISSING: ${entry.key} at $path');
        missing.add(entry.key);
      } else {
        print('FOUND: ${entry.key} at $path');
      }
    }

    if (missing.isNotEmpty) {
      fail('Missing fonts: ${missing.join(', ')}');
    }
  });
}
