import 'package:flutter/material.dart';

class ClockFaceDot extends StatelessWidget {
  final Color color;
  final bool isActive;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const ClockFaceDot({
    super.key,
    required this.color,
    required this.isActive,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the effective color to display
    // If active, use the passed color.
    // If inactive, fade to transparent version of that color.
    final effectiveColor = isActive ? color : color.withValues(alpha: 0.0);

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: effectiveColor,
          shape: BoxShape.circle,
          // Only show shadow if color is opaque/white (active state)
          // Inactive dots (grey) usually don't glow.
          // Shadows removed for performance/smoothness
          // TODO: Re-enable shadows when performance is improved.
          /*
          boxShadow: isActive && color == Colors.white
              ? [BoxShadow(color: color, blurRadius: 8, spreadRadius: 1)]
              : [],
          */
          boxShadow: const [],
        ),
      ),
    );
  }
}
