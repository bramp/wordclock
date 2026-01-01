import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wordclock/settings/settings_controller.dart';
import 'package:wordclock/settings/theme_settings.dart';
import 'package:wordclock/ui/settings/components/debug_settings.dart';
import 'package:wordclock/ui/settings/components/language_selector.dart';
import 'package:wordclock/ui/settings/components/section_header.dart';
import 'package:wordclock/ui/settings/components/theme_selector.dart';

class SettingsPanel extends StatelessWidget {
  final SettingsController controller;

  const SettingsPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Watch the controller for changes to rebuild the UI
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final settings = controller.settings;

        return Container(
          width: 300, // Fixed width for drawer/panel
          color: Colors.black.withValues(alpha: 0.85), // Semi-transparent black
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Settings',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      const SectionHeader(title: 'Language'),
                      LanguageSelector(controller: controller),
                      const SizedBox(height: 24),
                      const SectionHeader(title: 'Theme'),
                      ThemeSelector(
                        currentTheme: settings,
                        onThemeChanged: controller.updateTheme,
                      ),
                      const SizedBox(height: 24),
                      const SectionHeader(title: 'Display'),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Show Minute Dots',
                          style: TextStyle(color: Colors.white),
                        ),
                        value: settings.showMinuteDots,
                        activeThumbColor: settings.activeGradientColors.last,
                        onChanged: (value) {
                          controller.updateTheme(
                            ThemeSettings(
                              activeGradientColors:
                                  settings.activeGradientColors,
                              inactiveColor: settings.inactiveColor,
                              backgroundColor: settings.backgroundColor,
                              showMinuteDots: value,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),
                      const SectionHeader(title: 'About'),
                      const ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'WordClock v1.0',
                          style: TextStyle(color: Colors.grey),
                        ),
                        subtitle: Text(
                          'Built with Flutter',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),

                      if (kDebugMode) DebugSettings(controller: controller),
                    ],
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
