import 'package:flutter/material.dart';

class ClockLetter extends StatelessWidget {
  final String char;
  final bool isActive;
  final TextStyle activeStyle;
  final TextStyle inactiveStyle;

  static const duration = Duration(milliseconds: 1000);
  static const curve = Curves.easeInOut;

  const ClockLetter({
    super.key,
    required this.char,
    required this.isActive,
    required this.activeStyle,
    required this.inactiveStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Optimization: If we are fading between Transparent and ActiveColor,
    // use AnimatedOpacity (with FadeTransition internally) which is much cheaper
    // than re-painting the Text via AnimatedDefaultTextStyle.
    if (inactiveStyle.color?.a == 0) {
      return Center(
        child: AnimatedOpacity(
          opacity: isActive ? 1.0 : 0.0,
          duration: duration,
          curve: curve,
          child: Text(
            char,
            // For opacity fade, we always render the "Active" look and just fade its visibility
            style: activeStyle,
          ),
        ),
      );
    }

    return Center(
      child: AnimatedDefaultTextStyle(
        duration: duration,
        curve: curve,
        style: isActive ? activeStyle : inactiveStyle,
        child: Text(char),
      ),
    );
  }
}
