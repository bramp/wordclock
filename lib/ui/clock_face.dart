import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:wordclock/model/word_grid.dart';
import 'package:wordclock/languages/language.dart';

import 'package:wordclock/settings/theme_settings.dart';
import 'package:wordclock/ui/clock_layout.dart';
import 'package:wordclock/ui/letter_grid.dart';
import 'package:wordclock/settings/settings_controller.dart';
import 'package:wordclock/ui/settings/settings_panel.dart';
import 'package:wordclock/utils/locale_helper.dart';

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

class _ClockFaceState extends State<ClockFace>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _plasmaController;

  // State for caching calculations
  DateTime? _lastTime;
  Set<int> _activeIndices = {};
  int _remainder = 0;
  WordGrid? _lastGrid;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Plasma animation controller
    _plasmaController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    // Update every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      // Trigger rebuild to update UI
      setState(() {});
    });
  }

  bool _lastHighlightAll = false;

  void _recalculateIndices(DateTime now, WordClockGrid grid) {
    if (_lastTime != null &&
        _lastTime!.minute == now.minute &&
        _lastTime!.hour == now.hour &&
        _activeIndices.isNotEmpty &&
        _lastGrid == grid.grid &&
        _lastHighlightAll == widget.settingsController.highlightAll) {
      // No change that affects words.
      return;
    }

    _lastHighlightAll = widget.settingsController.highlightAll;

    _lastTime = now;
    _lastGrid = grid.grid;
    final lang = widget.settingsController.gridLanguage;

    if (widget.settingsController.highlightAll) {
      _activeIndices = widget.settingsController.allActiveIndices;
      // Highlight all minute dots if applicable
      _remainder = lang.minuteIncrement - 1;
    } else {
      final phrase = lang.timeToWords.convert(now);
      final units = lang.tokenize(phrase);
      _activeIndices = grid.grid.getIndices(
        units,
        requiresPadding: lang.requiresPadding,
      );
      _remainder = now.minute % lang.minuteIncrement;
    }
  }

  @override
  void dispose() {
    _plasmaController.dispose();
    _timer.cancel();
    super.dispose();
  }

  // Cache the grids to prevent rebuilding 110 widgets every second
  Widget? _cachedInactiveGrid;
  Widget? _cachedActiveGrid;
  Set<int>? _lastActiveIndices;
  WordGrid? _lastCachedGrid;
  Locale? _lastLocale;

  void _updateCachedGrids(
    SettingsController settings,
    WordGrid grid,
    Set<int> activeIndices,
    Duration duration,
    Curve curve,
  ) {
    final locale = LocaleHelper.parseLocale(settings.gridLanguage.languageCode);
    if (_cachedActiveGrid == null ||
        _cachedInactiveGrid == null ||
        !setEquals(_lastActiveIndices, activeIndices) ||
        _lastCachedGrid != grid ||
        _lastLocale != locale) {
      _cachedInactiveGrid = LetterGrid(
        grid: grid,
        locale: locale,
        activeIndices: const {},
        inactiveColor: const Color(0xFF333333),
        activeColor: Colors.transparent,
        duration: duration,
        curve: curve,
      );

      _cachedActiveGrid = LetterGrid(
        grid: grid,
        locale: locale,
        activeIndices: activeIndices,
        activeColor: Colors.white,
        inactiveColor: Colors.white.withValues(alpha: 0),
        duration: duration,
        curve: curve,
      );

      _lastActiveIndices = activeIndices;
      _lastCachedGrid = grid;
      _lastLocale = locale;
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
        final lang = widget.settingsController.gridLanguage;
        // Use the clock provided by settings
        final now = widget.settingsController.clock.now();
        final grid = widget.settingsController.grid;

        // Recalculate grid if time changed
        _recalculateIndices(now, grid);

        final showDots = settings.showMinuteDots && lang.minuteIncrement > 1;

        // Update cache if needed
        _updateCachedGrids(
          widget.settingsController,
          grid.grid,
          _activeIndices,
          widget.animationDuration,
          widget.animationCurve,
        );

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: settings.backgroundColor,
          endDrawer: SettingsPanel(controller: widget.settingsController),
          drawerScrimColor: Colors.black.withAlpha(0x4D),
          body: Stack(
            children: [
              GestureDetector(
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
                child: Center(
                  child: Stack(
                    children: [
                      // Layer 1: Inactive Elements
                      RepaintBoundary(
                        child: ClockLayout(
                          grid: grid.grid,
                          remainder: 0,
                          showDots: showDots,
                          forceAllDots: true,
                          dotColor: settings.inactiveColor,
                          duration: widget.animationDuration,
                          curve: widget.animationCurve,
                          child: _cachedInactiveGrid!,
                        ),
                      ),

                      // Layer 2: Active Elements
                      ListenableBuilder(
                        listenable: _plasmaController,
                        builder: (context, child) {
                          return RepaintBoundary(
                            child: ShaderMask(
                              shaderCallback: (bounds) {
                                if (settings.backgroundType ==
                                    BackgroundType.plasma) {
                                  return SweepGradient(
                                    colors: [
                                      ...settings.activeGradientColors,
                                      settings.activeGradientColors.first,
                                    ],
                                    transform: GradientRotation(
                                      _plasmaController.value * 2 * 3.14159,
                                    ),
                                  ).createShader(bounds);
                                } else {
                                  return LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: settings.activeGradientColors,
                                  ).createShader(bounds);
                                }
                              },
                              blendMode: BlendMode.srcIn,
                              child: child!,
                            ),
                          );
                        },
                        child: ClockLayout(
                          grid: grid.grid,
                          remainder: _remainder,
                          showDots: showDots,
                          forceAllDots: false,
                          dotColor: Colors.white,
                          duration: widget.animationDuration,
                          curve: widget.animationCurve,
                          child: _cachedActiveGrid!,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Settings Button (Bottom Right)
              Positioned(
                bottom: 16,
                right: 16,
                child: IconButton(
                  key: const Key('settings-button'),
                  tooltip: 'Settings',
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
