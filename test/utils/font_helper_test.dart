import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/utils/font_helper.dart';

void main() {
  group('FontHelper', () {
    group('getFontFamilyFromTag', () {
      test('Common Latin languages return Noto Sans', () {
        expect(FontHelper.getFontFamilyFromTag('en'), 'Noto Sans');
        expect(FontHelper.getFontFamilyFromTag('en-US'), 'Noto Sans');
        expect(FontHelper.getFontFamilyFromTag('fr'), 'Noto Sans');
        expect(FontHelper.getFontFamilyFromTag('es-ES'), 'Noto Sans');
      });

      test('Tamil returns Noto Sans Tamil', () {
        expect(FontHelper.getFontFamilyFromTag('ta'), 'Noto Sans Tamil');
        expect(FontHelper.getFontFamilyFromTag('ta-IN'), 'Noto Sans Tamil');
      });

      test('Japanese returns Noto Sans JP', () {
        expect(FontHelper.getFontFamilyFromTag('ja'), 'Noto Sans JP');
        expect(FontHelper.getFontFamilyFromTag('ja-JP'), 'Noto Sans JP');
      });

      test('Chinese logic', () {
        // Simplified default
        expect(FontHelper.getFontFamilyFromTag('zh'), 'Noto Sans SC');
        expect(FontHelper.getFontFamilyFromTag('zh-CN'), 'Noto Sans SC');

        // Traditional variants
        expect(FontHelper.getFontFamilyFromTag('zh-TW'), 'Noto Sans TC');
        expect(FontHelper.getFontFamilyFromTag('zh-HK'), 'Noto Sans TC');
        expect(FontHelper.getFontFamilyFromTag('zh-Hant'), 'Noto Sans TC');
        expect(FontHelper.getFontFamilyFromTag('zh-Hant-TW'), 'Noto Sans TC');
      });

      test('Conlangs', () {
        // Klingon (Standard ISO 15924 script code is 'Piqd')
        expect(FontHelper.getFontFamilyFromTag('tlh-Piqd'), 'KlingonHaSta');
        // If script is not Piqd, it defaults to Noto Sans
        expect(FontHelper.getFontFamilyFromTag('tlh'), 'Noto Sans');

        // Elvish (Sindarin/Quenya)
        expect(FontHelper.getFontFamilyFromTag('sjn'), 'AlcarinTengwar');
        expect(FontHelper.getFontFamilyFromTag('qya'), 'AlcarinTengwar');

        // High Valyrian
        expect(FontHelper.getFontFamilyFromTag('hva'), 'ValyrianAdvanced');

        // Aurebesh
        expect(FontHelper.getFontFamilyFromTag('aure'), 'Aurebesh');

        // Mando'a
        expect(FontHelper.getFontFamilyFromTag('mando'), 'MandoAF');
      });

      test('Edge cases', () {
        // Unknown language defaults to Noto Sans
        expect(FontHelper.getFontFamilyFromTag('xx'), 'Noto Sans');

        // Empty string
        expect(FontHelper.getFontFamilyFromTag(''), 'Noto Sans');

        // Complex tag (extensions ignored by heuristic)
        // 'u-nu-latn' parts might be misinterpreted as country codes if length 2/3,
        // but generally shouldn't affect the language code check unless specific logic exists.
        // Current logic: parts[0] = 'en', parts[1]... iterated.
        expect(FontHelper.getFontFamilyFromTag('en-US-u-nu-latn'), 'Noto Sans');
      });
    });
  });
}
