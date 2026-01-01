import 'package:flutter/material.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/ui/clock_letter.dart';

class LetterGrid extends StatelessWidget {
  final WordGrid grid;
  final Set<int> activeIndices;
  final Color activeColor;
  final Color inactiveColor;

  // Toggle for expensive glow effects
  static const bool enableGlow = true;

  const LetterGrid({
    super.key,
    required this.grid,
    required this.activeIndices,
    this.activeColor = Colors.white,
    this.inactiveColor = const Color.fromRGBO(255, 255, 255, 0.15),
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

          final activeStyle = TextStyle(
            fontFamily: 'monospace',
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: activeColor,
            shadows: shadows,
          );

          final inactiveStyle = TextStyle(
            fontFamily: 'monospace',
            fontSize: fontSize,
            fontWeight: FontWeight.w300,
            color: inactiveColor,
            shadows: const [],
          );

          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(), // Disable scrolling
            itemCount: grid.letters.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: grid.width,
              childAspectRatio: width / height,
            ),
            itemBuilder: (context, index) {
              final isActive = activeIndices.contains(index);
              final char = grid.letters[index];

              return ClockLetter(
                char: char,
                isActive: isActive,
                activeStyle: activeStyle,
                inactiveStyle: inactiveStyle,
              );
            },
          );
        },
      ),
    );
  }
}
