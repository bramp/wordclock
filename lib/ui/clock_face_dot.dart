import 'package:flutter/material.dart';

class ClockFaceDot extends StatelessWidget {
  final Color color;
  
  const ClockFaceDot({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    // TODO: This should animate in the same way that letter_grid does. 
    // Consider using AnimatedContainer or a similar implicit animation approach 
    // to match the fade/transition style of the letters if/when implemented.
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        // Only show shadow if color is opaque/white (active state)
        boxShadow: color == Colors.white ? [
           BoxShadow(color: color, blurRadius: 8, spreadRadius: 1)
        ] : [],
      ),
    );
  }
}
