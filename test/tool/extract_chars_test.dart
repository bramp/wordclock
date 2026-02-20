// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/languages/all.dart';
import 'package:wordclock/utils/font_helper.dart';

import '../../tool/extract_chars.dart';

void main() {
  group('Font Extraction Logic', () {
    test(
      'All language fonts have a corresponding entry in FontHelper.familyToAsset',
      () {
        final knownFonts = FontHelper.familyToAsset.keys.toSet();

        for (final language in WordClockLanguages.all) {
          final family = FontHelper.getFontFamilyFromTag(language.languageCode);

          // This fails if a new language introduces a font that isn't mapped
          expect(
            knownFonts,
            contains(family),
            reason:
                'Language ${language.id} (${language.englishName}) uses font "$family" which is not defined in FontHelper.familyToAsset',
          );
        }
      },
    );

    test('FontHelper.familyToAsset covers all major Noto Sans variants', () {
      final fonts = FontHelper.familyToAsset.keys;
      expect(
        fonts,
        containsAll([
          'Noto Sans',
          'Noto Sans Tamil',
          'Noto Sans JP',
          'Noto Sans SC',
          'Noto Sans TC',
        ]),
      );
    });

    // This test replicates the core logic of tool/extract_chars.dart to ensure it doesn't rot
    test('Extraction logic maps languages to valid font buckets', () {
      // The map used in tool/extract_chars.dart (must be manually kept in sync, which is what we are testing)
      final extractionbuckets = supportedFontFamilies;

      for (final language in WordClockLanguages.all) {
        final family = FontHelper.getFontFamilyFromTag(language.languageCode);
        expect(
          extractionbuckets,
          contains(family),
          reason:
              'Language ${language.id} uses font "$family", but tool/extract_chars.dart likely does not have a bucket for it.',
        );
      }
    });
  });
}
