import 'package:flutter/material.dart';
import 'package:wordclock/model/word_grid.dart';

class LetterGrid extends StatelessWidget {
  final WordGrid grid;
  final Set<int> activeIndices;
  final Color activeColor;
  final Color inactiveColor;

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

          // Let's use a Wrap or GridView?
          // GridView is perfect.

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
              // Should the following be it's own widget? Which could look ~identical to clock_face_dot.
              return Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  style: TextStyle(
                    fontFamily: 'monospace', // Default mono, can be changed
                    fontSize: height * 0.6, // Scale font with cell height
                    fontWeight: isActive ? FontWeight.w900 : FontWeight.w300,
                    color: isActive ? activeColor : inactiveColor,
                    // TODO: Re-enable shadows when performance is improved.
                    /*
                    shadows: isActive && activeColor.a > 0.5
                        ? [
                            BoxShadow(
                              color: activeColor,
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                    */
                    shadows: [],
                  ),
                  child: Text(char),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
