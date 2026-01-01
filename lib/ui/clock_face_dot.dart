import 'package:flutter/material.dart';

class ClockFaceDot extends StatelessWidget {
  final Color color;
  final bool isActive;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final Duration duration;
  final Curve curve;

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
    this.duration = const Duration(milliseconds: 1000),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    // Generate the decoration once (stateless within this build)
    final decoration = BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: enableGlow && isActive && color == Colors.white
          ? [BoxShadow(color: color, blurRadius: 8, spreadRadius: 1)]
          : [],
    );

    // Use AnimatedOpacity to fade the dot in/out, matching the text behavior.
    // This avoids interpolating the shadow (shrinking it) and instead fades it naturally.
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: AnimatedOpacity(
        opacity: isActive ? 1.0 : 0.0,
        duration: duration,
        curve: curve,
        child: Container(width: 12, height: 12, decoration: decoration),
      ),
    );
  }
}
