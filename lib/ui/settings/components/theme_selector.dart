import 'package:flutter/material.dart';
import 'package:wordclock/settings/theme_settings.dart';
import 'package:wordclock/ui/settings/components/theme_chip.dart';

class ThemeSelector extends StatelessWidget {
  final ThemeSettings currentTheme;
  final ValueChanged<ThemeSettings> onThemeChanged;

  const ThemeSelector({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ThemeChip(
          label: 'Default',
          colors: ThemeSettings.defaultTheme.activeGradientColors,
          isSelected: _isTheme(ThemeSettings.defaultTheme),
          onTap: () => onThemeChanged(ThemeSettings.defaultTheme),
        ),
        ThemeChip(
          label: 'Warm',
          colors: ThemeSettings.warmTheme.activeGradientColors,
          isSelected: _isTheme(ThemeSettings.warmTheme),
          onTap: () => onThemeChanged(ThemeSettings.warmTheme),
        ),
        ThemeChip(
          label: 'Matrix',
          colors: ThemeSettings.matrixTheme.activeGradientColors,
          isSelected: _isTheme(ThemeSettings.matrixTheme),
          onTap: () => onThemeChanged(ThemeSettings.matrixTheme),
        ),
        ThemeChip(
          label: 'White',
          colors: ThemeSettings.whiteTheme.activeGradientColors,
          isSelected: _isTheme(ThemeSettings.whiteTheme),
          onTap: () => onThemeChanged(ThemeSettings.whiteTheme),
        ),
      ],
    );
  }

  bool _isTheme(ThemeSettings target) {
    // We ignore showMinuteDots for theme selection logic if desired,
    // but with equality operator, strict equality is cleaner.
    // However, existing logic seemed to permit variance in `showMinuteDots`.
    // Let's use color equality which effectively what themes represent here.
    if (currentTheme.activeGradientColors.length !=
        target.activeGradientColors.length) {
      return false;
    }
    for (int i = 0; i < currentTheme.activeGradientColors.length; i++) {
      if (currentTheme.activeGradientColors[i] !=
          target.activeGradientColors[i]) {
        return false;
      }
    }
    return currentTheme.backgroundColor == target.backgroundColor;
  }
}
