import 'package:flutter/material.dart';

class ClockFaceDot extends StatelessWidget {
  final Color color;
  final bool isActive;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  // Toggle for expensive glow effects
  static const bool enableGlow = true;

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
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: effectiveColor,
          shape: BoxShape.circle,
          boxShadow: enableGlow && isActive && color == Colors.white
              ? [BoxShadow(color: color, blurRadius: 8, spreadRadius: 1)]
              : [],
        ),
      ),
    );
  }
}
