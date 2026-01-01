import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wordclock/settings/settings_controller.dart';
import 'package:wordclock/settings/theme_settings.dart';
import 'package:wordclock/ui/settings/components/section_header.dart';
import 'package:wordclock/ui/settings/components/seed_selector.dart';
import 'package:wordclock/ui/settings/components/speed_chip.dart';
import 'package:wordclock/ui/settings/components/theme_chip.dart';

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
                      const SectionHeader(title: 'Theme'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ThemeChip(
                            label: 'Default',
                            colors:
                                ThemeSettings.defaultTheme.activeGradientColors,
                            isSelected:
                                settings ==
                                ThemeSettings
                                    .defaultTheme, // Ideally compare equality or IDs
                            onTap: () => controller.updateTheme(
                              ThemeSettings.defaultTheme,
                            ),
                          ),
                          ThemeChip(
                            label: 'Warm',
                            colors:
                                ThemeSettings.warmTheme.activeGradientColors,
                            isSelected:
                                settings.activeGradientColors ==
                                    ThemeSettings
                                        .warmTheme
                                        .activeGradientColors &&
                                settings.backgroundColor ==
                                    ThemeSettings.warmTheme.backgroundColor,
                            onTap: () =>
                                controller.updateTheme(ThemeSettings.warmTheme),
                          ),
                          ThemeChip(
                            label: 'Matrix',
                            colors:
                                ThemeSettings.matrixTheme.activeGradientColors,
                            isSelected:
                                settings.activeGradientColors ==
                                ThemeSettings.matrixTheme.activeGradientColors,
                            onTap: () => controller.updateTheme(
                              ThemeSettings.matrixTheme,
                            ),
                          ),
                        ],
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

                      if (kDebugMode) ...[
                        const SizedBox(height: 24),
                        const SectionHeader(title: 'Debug'),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: const Text(
                            'Speed',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            SpeedChip(
                              label: 'Normal',
                              color: Colors.grey,
                              isSelected:
                                  controller.clockSpeed == ClockSpeed.normal,
                              onTap: () =>
                                  controller.setClockSpeed(ClockSpeed.normal),
                            ),
                            SpeedChip(
                              label: 'Fast',
                              color: Colors.orangeAccent,
                              isSelected:
                                  controller.clockSpeed == ClockSpeed.fast,
                              onTap: () =>
                                  controller.setClockSpeed(ClockSpeed.fast),
                            ),
                            SpeedChip(
                              label: 'Hyper',
                              color: Colors.purpleAccent,
                              isSelected:
                                  controller.clockSpeed == ClockSpeed.hyper,
                              onTap: () =>
                                  controller.setClockSpeed(ClockSpeed.hyper),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            switch (controller.clockSpeed) {
                              ClockSpeed.normal => 'Standard time',
                              ClockSpeed.fast => '1 minute per second',
                              ClockSpeed.hyper => '5 minutes per second',
                            },
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Set Time',
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            controller.isManualTime
                                ? '${controller.clock.now().hour.toString().padLeft(2, '0')}:${controller.clock.now().minute.toString().padLeft(2, '0')}'
                                : 'System Time',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: const Icon(
                            Icons.access_time,
                            color: Colors.grey,
                          ),
                          onTap: () async {
                            final now = controller.clock.now();
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(now),
                            );

                            if (time != null && context.mounted) {
                              final newTime = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                now.hour,
                                now.minute,
                              );
                              controller.setManualTime(newTime);
                            }
                          },
                        ),
                        if (controller.isManualTime)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Reset to System Time',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                            leading: const Icon(
                              Icons.restore,
                              color: Colors.redAccent,
                            ),
                            onTap: () {
                              controller.setManualTime(null);
                            },
                          ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: const Text(
                            'Grid Seed',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        SeedSelector(
                          value: controller.gridSeed,
                          onChanged: (val) => controller.setGridSeed(val),
                        ),
                      ],
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
