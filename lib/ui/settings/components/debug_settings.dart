import 'package:flutter/material.dart';
import 'package:wordclock/settings/settings_controller.dart';
import 'package:wordclock/ui/settings/components/section_header.dart';
import 'package:wordclock/ui/settings/components/seed_selector.dart';
import 'package:wordclock/ui/settings/components/speed_selector.dart';

class DebugSettings extends StatelessWidget {
  final SettingsController controller;

  const DebugSettings({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder is redundant here if parent is already rebuilding,
    // but ensures this widget rebuilds if passed a controller that updates.
    // However, usually passed as simple widget from SettingsPanel.
    // We access properties directly. It relies on parent rebuilding or itself listening.
    // SettingsPanel wraps everything in ListenableBuilder, so we receive fresh state.

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const SectionHeader(title: 'Debug'),
        SpeedSelector(
          currentSpeed: controller.clockSpeed,
          onSpeedChanged: controller.setClockSpeed,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Set Time', style: TextStyle(color: Colors.white)),
          subtitle: Text(
            controller.isManualTime
                ? '${controller.clock.now().hour.toString().padLeft(2, '0')}:${controller.clock.now().minute.toString().padLeft(2, '0')}'
                : 'System Time',
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: const Icon(Icons.access_time, color: Colors.grey),
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
            leading: const Icon(Icons.restore, color: Colors.redAccent),
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
    );
  }
}
