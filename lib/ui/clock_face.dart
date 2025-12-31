import 'dart:async';

import 'package:flutter/material.dart';

import 'package:wordclock/model/word_grid.dart';

import 'package:wordclock/ui/clock_layout.dart';
import 'package:wordclock/ui/letter_grid.dart';
import 'package:wordclock/settings/settings_controller.dart';
import 'package:wordclock/ui/settings_page.dart';

class ClockFace extends StatefulWidget {
  final WordGrid grid;
  final SettingsController settingsController;

  ClockFace({super.key, WordGrid? grid, required this.settingsController})
    : grid = grid ?? WordGrid.english11x10;

  @override
  State<ClockFace> createState() => _ClockFaceState();
}

class _ClockFaceState extends State<ClockFace> {
  late Timer _timer;

  // State for caching calculations
  DateTime? _lastTime;
  Set<int> _activeIndices = {};
  int _remainder = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Update every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      // Trigger rebuild to update UI
      setState(() {});
    });
  }

  void _recalculateIndices(DateTime now) {
    if (_lastTime != null &&
        _lastTime!.minute == now.minute &&
        _lastTime!.hour == now.hour &&
        _activeIndices.isNotEmpty) {
      // No change in time that affects words.
      return;
    }

    _lastTime = now;
    _activeIndices = widget.grid.getIndices(now);
    _remainder = now.minute % 5;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to settings changes to rebuild UI when theme changes
    return ListenableBuilder(
      listenable: widget.settingsController,
      builder: (context, child) {
        final settings = widget.settingsController.settings;
        // Use the clock provided by settings
        final now = widget.settingsController.clock.now();

        // Recalculate grid if time changed
        _recalculateIndices(now);

        return Scaffold(
          key: _scaffoldKey, // TODO Do we need a GlobalKey? Document why
          backgroundColor: settings.backgroundColor,
          endDrawer: SettingsPanel(controller: widget.settingsController),
          drawerScrimColor: Colors.black.withValues(alpha: 0.3),
          body: Stack(
            children: [
              // Background: Faceplate color (usually matches scaffold)
              Positioned.fill(
                child: Container(color: settings.backgroundColor),
              ),

              Center(
                child: Stack(
                  children: [
                    // Layer 1: Inactive Elements
                    RepaintBoundary(
                      child: ClockLayout(
                        grid: widget.grid,
                        remainder: 0,
                        showDots: settings.showMinuteDots,
                        forceAllDots: true, // Always show placeholder dots
                        dotColor: settings.inactiveColor,
                        child: LetterGrid(
                          grid: widget.grid,
                          activeIndices: const {},
                          inactiveColor: const Color(0xFF333333),
                          activeColor: Colors.transparent,
                        ),
                      ),
                    ),

                    // Layer 2: Active Elements
                    RepaintBoundary(
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: settings.activeGradientColors,
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.srcIn,
                        child: ClockLayout(
                          grid: widget.grid,
                          remainder: _remainder,
                          showDots: settings.showMinuteDots,
                          forceAllDots: false,
                          dotColor: Colors.white,
                          child: LetterGrid(
                            grid: widget.grid,
                            activeIndices: _activeIndices,
                            activeColor: Colors.white,
                            inactiveColor: Colors.white.withValues(alpha: 0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Settings Button (Bottom Right)
              Positioned(
                bottom: 16,
                right: 16,
                child: IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  onPressed: () {
                    _scaffoldKey.currentState?.openEndDrawer();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
