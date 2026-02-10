import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/ui/clock_letter.dart';

class LetterGrid extends StatelessWidget {
  final WordGrid grid;
  final Locale locale;
  final Set<int> activeIndices;
  final Color activeColor;
  final Color inactiveColor;
  final Duration duration;
  final Curve curve;

  // Toggle for expensive glow effects
  static const bool enableGlow = true;

  const LetterGrid({
    super.key,
    required this.grid,
    required this.locale,
    required this.activeIndices,
    this.activeColor = Colors.white,
    this.inactiveColor = const Color.fromRGBO(255, 255, 255, 0.15),
    this.duration = const Duration(milliseconds: 1000),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    // We want the grid to fit within the screen, maintaining aspect ratio.
    // The grid is 11 columns x 10 rows.
    // Aspect Ratio is 11/10 = 1.1 width/height.

    return AspectRatio(
      aspectRatio: grid.width / grid.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate cell size
          final width = constraints.maxWidth / grid.width;
          final height = constraints.maxHeight / grid.height;
          // Use the smaller dimension to keep cells square-ish if needed,
          // or just fill the space.
          // Monospaced fonts usually need careful sizing.

          // Pre-compute styles to avoid recreation for every letter
          // Shared shadows list
          final shadows = enableGlow
              ? [
                  Shadow(color: activeColor, blurRadius: 10),
                  Shadow(color: activeColor, blurRadius: 20),
                ]
              : <Shadow>[];

          final fontSize = height * 0.6;

          final activeStyle = _getStyle(FontWeight.w700, activeColor, shadows);
          final inactiveStyle = _getStyle(
            FontWeight.w400,
            inactiveColor,
            const [],
          );

          return GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: grid.width,
            childAspectRatio: width / height,
            padding: EdgeInsets.zero,
            children: List.generate(grid.cells.length, (index) {
              final isActive = activeIndices.contains(index);
              final char = grid.cells[index];

              return ClockLetter(
                char: char,
                isActive: isActive,
                activeStyle: activeStyle,
                inactiveStyle: inactiveStyle,
                fontSize: fontSize,
                duration: duration,
                curve: curve,
              );
            }),
          );
        },
      ),
    );
  }

  /// Returns the appropriate Noto Sans variant based on the [locale].
  ///
  /// This mapping is essential for two reasons:
  /// 1. **Asset Bundling**: The `google_fonts` package maps these specific methods
  ///    to font family names (e.g., [GoogleFonts.notoSansJp] looks for "Noto Sans JP").
  ///    This allows us to bundle the fonts as assets and turn off runtime fetching.
  /// 2. **Glyph Coverage**: Different languages require specific glyph sets.
  ///    Using the language-specific variant ensures that characters like Kanji or
  ///    Tamil script are rendered using the correct typeface instead of falling
  ///    back to a generic system font.
  TextStyle _getStyle(FontWeight weight, Color color, List<Shadow> shadows) {
    final language = locale.languageCode.toLowerCase();

    if (language == 'ta') {
      return GoogleFonts.notoSansTamil(
        fontWeight: weight,
        color: color,
        shadows: shadows,
      );
    }

    if (language == 'ja') {
      return GoogleFonts.notoSansJp(
        fontWeight: weight,
        color: color,
        shadows: shadows,
      );
    }

    if (language == 'zh') {
      // Handle Traditional Chinese variants
      final script = locale.scriptCode?.toLowerCase();
      final country = locale.countryCode?.toLowerCase();

      if (script == 'hant' ||
          country == 'tw' ||
          country == 'hk' ||
          country == 'mo') {
        return GoogleFonts.notoSansTc(
          fontWeight: weight,
          color: color,
          shadows: shadows,
        );
      }

      // Default to Simplified Chinese
      return GoogleFonts.notoSansSc(
        fontWeight: weight,
        color: color,
        shadows: shadows,
      );
    }

    return GoogleFonts.notoSans(
      fontWeight: weight,
      color: color,
      shadows: shadows,
    );
  }
}
