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
            // Use ShaderMask to show the "Elaborate Background" (Gradient) 
            // only through the letters.
            child: ShaderMask(
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
              child: LetterGrid(
                grid: widget.grid,
                activeIndices: _activeIndices,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
