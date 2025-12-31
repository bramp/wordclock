import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wordclock/logic/time_to_words.dart';
import 'package:wordclock/model/grid_def.dart';
import 'package:wordclock/ui/letter_grid.dart';
import 'package:wordclock/settings/settings_controller.dart';
import 'package:wordclock/ui/settings_page.dart';

class ClockFace extends StatefulWidget {
  final GridDefinition grid;
  final SettingsController settingsController;

  ClockFace({super.key, GridDefinition? grid, required this.settingsController})
    : grid = grid ?? GridDefinition.english11x10;

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

    final phrase = TimeToWords.convert(now);
    final words = phrase.split(' ');

    final newIndices = <int>{};

    int lastEndIndex = -1;

    for (final wordStr in words) {
      final definitions = widget.grid.mapping[wordStr];
      if (definitions != null && definitions.isNotEmpty) {
        List<int>? chosenDef;

        // Try to find a definition that starts strictly after the last word ended
        for (final def in definitions) {
          if (def.first > lastEndIndex) {
            chosenDef = def;
            break;
          }
        }

        // Fallback: If we couldn't find one after the last index,
        // use the last known definition (likely the one furthest down the board).
        // This handles edge cases or strange layouts, but ideally shouldn't be hit
        // for standard recursive layouts.
        chosenDef ??= definitions.last;

        newIndices.addAll(chosenDef);

        // Update lastEndIndex to the end of this word
        // We use the max index of the word, assuming contiguous
        lastEndIndex = chosenDef.last;
      }
    }

    _activeIndices = newIndices;
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
                    _ClockLayout(
                      grid: widget.grid,
                      remainder: 0,
                      showDots: settings.showMinuteDots,
                      forceAllDots:
                          true, // Always show placeholder dots if dots are enabled
                      dotColor: settings.inactiveColor,
                      child: LetterGrid(
                        grid: widget.grid,
                        activeIndices: const {},
                        inactiveColor: const Color(0xFF333333),
                        activeColor: Colors.transparent,
                      ),
                    ),

                    // Layer 2: Active Elements
                    ShaderMask(
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
            ],
          ],
        ),
      ),
    );
  }
}

// TODO Should this be it's own file?
// TODO This should animate in the same way that letter_grid does. Can we share/reuse code to ensure consistency?
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
        boxShadow: color == Colors.white
            ? [BoxShadow(color: color, blurRadius: 8, spreadRadius: 1)]
            : [],
      ),
    );
  }
}
