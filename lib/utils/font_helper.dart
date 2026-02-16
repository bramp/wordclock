class FontHelper {
  static const Map<String, String> familyToAsset = {
    'Noto Sans': 'assets/fonts/NotoSans-Variable.ttf',
    'Noto Sans Tamil': 'assets/fonts/NotoSansTamil-Variable.ttf',
    'Noto Sans SC': 'assets/fonts/NotoSansSC-Variable.ttf',
    'Noto Sans TC': 'assets/fonts/NotoSansTC-Variable.ttf',
    'Noto Sans JP': 'assets/fonts/NotoSansJP-Variable.ttf',
    'KlingonHaSta': 'assets/fonts/Klingon-pIqaD-HaSta.ttf',
    'AlcarinTengwar': 'assets/fonts/AlcarinTengwar.ttf',
  };

  /// Returns the font family name for the given language configuration.
  ///
  /// The returned string must match the font family name defined in `pubspec.yaml`.
  static String getFontFamily({
    required String languageCode,
    String? scriptCode,
    String? countryCode,
  }) {
    final lang = languageCode.toLowerCase();
    final script = scriptCode?.toLowerCase();
    final country = countryCode?.toLowerCase();

    if (lang == 'ta') {
      return 'Noto Sans Tamil';
    }

    if (lang == 'ja') {
      return 'Noto Sans JP';
    }

    if (lang == 'zh') {
      // Handle Traditional Chinese variants
      if (script == 'hant' ||
          country == 'tw' ||
          country == 'hk' ||
          country == 'mo') {
        return 'Noto Sans TC';
      }
      return 'Noto Sans SC';
    }

    // Klingon (pIqaD).
    if (lang == 'tlh' && script == 'piqd') {
      return 'KlingonHaSta';
    }

    if (lang == 'sjn' || lang == 'qya') {
      return 'AlcarinTengwar';
    }

    return 'Noto Sans';
  }

  /// Parses a BCP47 language tag and returns the corresponding font family.
  ///
  /// This is useful for tools that work with raw language tags.
  static String getFontFamilyFromTag(String tag) {
    // Simple parser for tags like "zh-Hans-CN" or "en-US"
    final parts = tag.split('-');
    final languageCode = parts.isNotEmpty ? parts[0] : '';

    String? scriptCode;
    String? countryCode;

    // A heuristic to distinguish script from region
    // ISO 15924 scripts are 4 letters. ISO 3166-1 regions are 2 letters (or 3 digits).
    for (var i = 1; i < parts.length; i++) {
      final part = parts[i];
      if (part.length == 4) {
        scriptCode = part;
      } else if (part.length == 2 || part.length == 3) {
        countryCode = part;
      }
    }

    return getFontFamily(
      languageCode: languageCode,
      scriptCode: scriptCode,
      countryCode: countryCode,
    );
  }
}
