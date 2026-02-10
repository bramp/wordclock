import 'package:flutter/material.dart';
import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/ui/clock_face_dot.dart';

class ClockLayout extends StatelessWidget {
  final WordGrid grid;
  final Widget child;
  final int remainder;
  final bool showDots;

  /// If true, lights up all 4 dots regardless of the [remainder].
  /// This is used for the inactive/background layer to show the "placeholder" dots.
  final bool forceAllDots;
  final Color dotColor;
  final Duration duration;
  final Curve curve;

  const ClockLayout({
    super.key,
    required this.grid,
    required this.child,
    required this.remainder,
    required this.showDots,
    this.forceAllDots = false,
    required this.dotColor,
    this.duration = const Duration(milliseconds: 1000),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: grid.width / grid.height,
      child: Padding(
        padding: const EdgeInsets.all(
          20.0,
        ), // Outer margin to prevent dot shadow cropping
        child: Stack(
          children: [
            // The Grid (Inset)
            // Push grid in so dots fit in corners, only if we are showing dots.
            Padding(
              padding: EdgeInsets.all(showDots ? 24.0 : 0.0),
              child: child,
            ),

            if (showDots) ...[
              // 1 minute: Top Left
              ClockFaceDot(
                top: 0,
                left: 0,
                color: dotColor,
                isActive: forceAllDots || remainder >= 1,
                duration: duration,
                curve: curve,
              ),
              // 2 minutes: Top Right
              ClockFaceDot(
                top: 0,
                right: 0,
                color: dotColor,
                isActive: forceAllDots || remainder >= 2,
                duration: duration,
                curve: curve,
              ),
              // 3 minutes: Bottom Right
              ClockFaceDot(
                bottom: 0,
                right: 0,
                color: dotColor,
                isActive: forceAllDots || remainder >= 3,
                duration: duration,
                curve: curve,
              ),
              // 4 minutes: Bottom Left
              ClockFaceDot(
                bottom: 0,
                left: 0,
                color: dotColor,
                isActive: forceAllDots || remainder >= 4,
                duration: duration,
                curve: curve,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
