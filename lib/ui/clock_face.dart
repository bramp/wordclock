import 'dart:async';

import 'package:flutter/material.dart';

import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/ui/clock_face_dot.dart';
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
                      child: _ClockLayout(
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
                        child: _ClockLayout(
                          grid: widget.grid,
                          remainder: _remainder,
                          showDots: settings.showMinuteDots,
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

class _ClockLayout extends StatelessWidget {
  final WordGrid grid;
  final Widget child;
  final int remainder;
  final bool showDots;

  /// If true, lights up all 4 dots regardless of the [remainder].
  /// This is used for the inactive/background layer to show the "placeholder" dots.
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
        padding: const EdgeInsets.all(
          20.0,
        ), // Outer margin to prevent dot shadow cropping
        child: Stack(
          children: [
            // The Grid (Inset)
            // Push grid in so dots fit in corners
            Padding(padding: const EdgeInsets.all(24.0), child: child),

            if (showDots) ...[
              // 1 minute: Top Left
              ClockFaceDot(
                top: 0,
                left: 0,
                color: dotColor,
                isActive: forceAllDots || remainder >= 1,
              ),
              // 2 minutes: Top Right
              ClockFaceDot(
                top: 0,
                right: 0,
                color: dotColor,
                isActive: forceAllDots || remainder >= 2,
              ),
              // 3 minutes: Bottom Right
              ClockFaceDot(
                bottom: 0,
                right: 0,
                color: dotColor,
                isActive: forceAllDots || remainder >= 3,
              ),
              // 4 minutes: Bottom Left
              ClockFaceDot(
                bottom: 0,
                left: 0,
                color: dotColor,
                isActive: forceAllDots || remainder >= 4,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
