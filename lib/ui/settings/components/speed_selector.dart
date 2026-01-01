import 'package:flutter/material.dart';
import 'package:wordclock/settings/settings_controller.dart' show ClockSpeed;
import 'package:wordclock/ui/settings/components/speed_chip.dart';

class SpeedSelector extends StatelessWidget {
  final ClockSpeed currentSpeed;
  final ValueChanged<ClockSpeed> onSpeedChanged;

  const SpeedSelector({
    super.key,
    required this.currentSpeed,
    required this.onSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              isSelected: currentSpeed == ClockSpeed.normal,
              onTap: () => onSpeedChanged(ClockSpeed.normal),
            ),
            SpeedChip(
              label: 'Fast',
              color: Colors.orangeAccent,
              isSelected: currentSpeed == ClockSpeed.fast,
              onTap: () => onSpeedChanged(ClockSpeed.fast),
            ),
            SpeedChip(
              label: 'Hyper',
              color: Colors.purpleAccent,
              isSelected: currentSpeed == ClockSpeed.hyper,
              onTap: () => onSpeedChanged(ClockSpeed.hyper),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(switch (currentSpeed) {
            ClockSpeed.normal => 'Standard time',
            ClockSpeed.fast => '1 minute per second',
            ClockSpeed.hyper => '5 minutes per second',
          }, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ),
      ],
    );
  }
}
