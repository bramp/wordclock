import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:wordclock/model/word_grid.dart';

import 'package:wordclock/ui/clock_layout.dart';
import 'package:wordclock/ui/letter_grid.dart';
import 'package:wordclock/settings/settings_controller.dart';
import 'package:wordclock/ui/settings/settings_panel.dart';

class ClockFace extends StatefulWidget {
  final SettingsController settingsController;
  final Duration animationDuration;
  final Curve animationCurve;

  const ClockFace({
    super.key,
    required this.settingsController,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  State<ClockFace> createState() => _ClockFaceState();
}

class _ClockFaceState extends State<ClockFace> {
  late Timer _timer;

  // State for caching calculations
  DateTime? _lastTime;
  Set<int> _activeIndices = {};
  int _remainder = 0;
  WordGrid? _lastGrid;

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

  bool _lastHighlightAll = false;

  void _recalculateIndices(DateTime now, WordGrid grid) {
    if (_lastTime != null &&
        _lastTime!.minute == now.minute &&
        _lastTime!.hour == now.hour &&
        _activeIndices.isNotEmpty &&
        _lastGrid == grid &&
        _lastHighlightAll == widget.settingsController.highlightAll) {
      // No change that affects words.
      return;
    }

    _lastHighlightAll = widget.settingsController.highlightAll;

    _lastTime = now;
    _lastGrid = grid;
    final lang = widget.settingsController.currentLanguage;

    if (widget.settingsController.highlightAll) {
      _activeIndices = widget.settingsController.allActiveIndices;
      // Highlight all minute dots if applicable
      _remainder = lang.minuteIncrement - 1;
    } else {
      final phrase = lang.timeToWords.convert(now);
      final units = lang.tokenize(phrase);
      _activeIndices = grid.getIndices(units);
      _remainder = now.minute % lang.minuteIncrement;
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Cache the grids to prevent rebuilding 110 widgets every second
  Widget? _cachedInactiveGrid;
  Widget? _cachedActiveGrid;
  Set<int>? _lastActiveIndices;
  WordGrid? _lastCachedGrid;

  void _updateCachedGrids(
    SettingsController settings,
    WordGrid grid,
    Set<int> activeIndices,
    Duration duration,
    Curve curve,
  ) {
    if (_cachedActiveGrid == null ||
        _cachedInactiveGrid == null ||
        !setEquals(_lastActiveIndices, activeIndices) ||
        _lastCachedGrid != grid) {
      _cachedInactiveGrid = LetterGrid(
        grid: grid,
        activeIndices: const {},
        inactiveColor: const Color(0xFF333333),
        activeColor: Colors.transparent,
        duration: duration,
        curve: curve,
      );

      _cachedActiveGrid = LetterGrid(
        grid: grid,
        activeIndices: activeIndices,
        activeColor: Colors.white,
        inactiveColor: Colors.white.withValues(alpha: 0),
        duration: duration,
        curve: curve,
      );

      _lastActiveIndices = activeIndices;
      _lastCachedGrid = grid;
    }
  }

  @override
  void didUpdateWidget(ClockFace oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Invalidate cache if settings config changed passed from parent
    // Note: grid logic is now handled in build/update methods via controller
  }

  // Helper for set equality
  bool setEquals<T>(Set<T>? a, Set<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    return a.containsAll(b);
  }

  @override
  Widget build(BuildContext context) {
    // Listen to settings changes to rebuild UI when theme changes
    return ListenableBuilder(
      listenable: widget.settingsController,
      builder: (context, child) {
        if (kDebugMode) print('Rebuilding ClockFace... ${DateTime.now()}');
        final settings = widget.settingsController.settings;
        final lang = widget.settingsController.currentLanguage;
        // Use the clock provided by settings
        final now = widget.settingsController.clock.now();
        final grid = widget.settingsController.currentGrid;

        // Recalculate grid if time changed
        _recalculateIndices(now, grid);

        final showDots = settings.showMinuteDots && lang.minuteIncrement > 1;

        // Update cache if needed
        _updateCachedGrids(
          widget.settingsController,
          grid,
          _activeIndices,
          widget.animationDuration,
          widget.animationCurve,
        );

        return Scaffold(
          key: _scaffoldKey, // TODO Do we need a GlobalKey? Document why
          backgroundColor: settings.backgroundColor,
          endDrawer: SettingsPanel(controller: widget.settingsController),
          drawerScrimColor: Colors.black.withAlpha(0x4D),
          body: GestureDetector(
            onLongPress: () async {
              final phrase = lang.timeToWords.convert(now);
              await Clipboard.setData(ClipboardData(text: phrase));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Copied "$phrase" to clipboard'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    width: 400,
                  ),
                );
              }
            },
            child: Stack(
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
                          grid: grid,
                          remainder: 0,
                          showDots: showDots,
                          forceAllDots: true, // Always show placeholder dots
                          dotColor: settings.inactiveColor,
                          duration: widget.animationDuration,
                          curve: widget.animationCurve,
                          child: _cachedInactiveGrid!,
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
                            grid: grid,
                            remainder: _remainder,
                            showDots: showDots,
                            forceAllDots: false,
                            dotColor: Colors.white,
                            duration: widget.animationDuration,
                            curve: widget.animationCurve,
                            child: _cachedActiveGrid!,
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
          ),
        );
      },
    );
  }
}
