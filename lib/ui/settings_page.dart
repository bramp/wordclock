import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wordclock/settings/settings_controller.dart';

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
                      const _SectionHeader(title: 'Theme'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ThemeChip(
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
                          _ThemeChip(
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
                          _ThemeChip(
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
                      const _SectionHeader(title: 'Display'),
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
                      const _SectionHeader(title: 'About'),
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
                        const _SectionHeader(title: 'Debug'),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Fast Tick Mode',
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: const Text(
                            '1 minute per second',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          value: controller.isFastTickMode,
                          activeThumbColor: Colors.redAccent,
                          onChanged: (value) =>
                              controller.setFastTickMode(value),
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
                                time.hour,
                                time.minute,
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
                              controller.setFastTickMode(false);
                            },
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

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String label;
  final List<Color> colors;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeChip({
    required this.label,
    required this.colors,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? colors.first
                : Colors.grey.withValues(alpha: 0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(colors: colors),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
