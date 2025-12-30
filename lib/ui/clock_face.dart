import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wordclock/logic/time_to_words.dart';
import 'package:wordclock/model/grid_def.dart';
import 'package:wordclock/ui/letter_grid.dart';

class ClockFace extends StatefulWidget {
  final GridDefinition grid;

  const ClockFace({super.key, this.grid = GridDefinition.english11x10});

  @override
  State<ClockFace> createState() => _ClockFaceState();
}

class _ClockFaceState extends State<ClockFace> {
  late Timer _timer;
  DateTime _now = DateTime.now();
  final Set<int> _activeIndices = {};
  int _remainder = 0;

  @override
  void initState() {
    super.initState();
    _updateTime();
    // Update every second to ensure we catch minute changes promptly
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }
  
  void _updateTime() {
    final now = DateTime.now();
    if (_now.minute != now.minute || _activeIndices.isEmpty) {
      setState(() {
        _now = now;
        final words = TimeToWords.convert(_now);
        _activeIndices.clear();
        for (final word in words) {
          final indices = widget.grid.mapping[word];
          if (indices != null) {
            _activeIndices.addAll(indices);
          }
        }
        
        // Calculate remainder minutes (0-4)
        // We floor'd the time logic, so remainder is just minute % 5.
        _remainder = _now.minute % 5;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Default background
      body: Stack(
        children: [
          // Background: Solid Black (Faceplate)
          Positioned.fill(
            child: Container(color: Colors.black),
          ),
          
          Center(
            child: Stack(
              children: [
                // Layer 1: Inactive Elements (Unlit Letters & Dots)
                _ClockLayout(
                  grid: widget.grid,
                  remainder: 0, 
                  showDots: true, // Show dots in inactive layer
                  forceAllDots: true, // Show ALL dots as inactive placeholders
                  dotColor: const Color.fromRGBO(255, 255, 255, 0.15),
                  child: LetterGrid(
                    grid: widget.grid,
                    activeIndices: const {},
                    inactiveColor: const Color(0xFF333333),
                    activeColor: Colors.transparent,
                  ),
                ),
                
                // Layer 2: Active Elements (Lit Letters + Dots) -> Masked
                ShaderMask(
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFF00CC), // Purple
                        Color(0xFF333399), // Dark Blue
                        Color(0xFF00CCFF), // Light Blue
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcIn,
                  child: _ClockLayout(
                    grid: widget.grid,
                    remainder: _remainder,
                    showDots: true,
                    forceAllDots: false,
                    dotColor: Colors.white,
                    child: LetterGrid(
                      grid: widget.grid,
                      activeIndices: _activeIndices,
                      activeColor: Colors.white,
                      inactiveColor: Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClockLayout extends StatelessWidget {
  final GridDefinition grid;
  final Widget child;
  final int remainder;
  final bool showDots;
  final bool forceAllDots;
  final Color dotColor;

  const _ClockLayout({
    required this.grid,
    required this.child,
    required this.remainder,
    required this.showDots,
    this.forceAllDots = false,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: grid.width / grid.height,
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Outer margin to prevent dot shadow cropping
        child: Stack(
          children: [
            // The Grid (Inset)
            // Push grid in so dots fit in corners
            Padding(
              padding: const EdgeInsets.all(24.0), 
              child: child,
            ),
            
            if (showDots) ...[
               // 1 minute: Top Left
               if (forceAllDots || remainder >= 1)
                 Positioned(top: 0, left: 0, child: _Dot(color: dotColor)),
               // 2 minutes: Top Right
               if (forceAllDots || remainder >= 2)
                 Positioned(top: 0, right: 0, child: _Dot(color: dotColor)),
               // 3 minutes: Bottom Right
               if (forceAllDots || remainder >= 3)
                 Positioned(bottom: 0, right: 0, child: _Dot(color: dotColor)),
               // 4 minutes: Bottom Left
               if (forceAllDots || remainder >= 4)
                 Positioned(bottom: 0, left: 0, child: _Dot(color: dotColor)),
            ]
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        // Only show shadow if color is opaque/white (active state)
        // Inactive dots (grey) usually don't glow.
        boxShadow: color == Colors.white ? [
           BoxShadow(color: color, blurRadius: 8, spreadRadius: 1)
        ] : [],
      ),
    );
  }
}
