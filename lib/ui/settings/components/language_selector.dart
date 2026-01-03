import 'package:flutter/material.dart';
import 'package:wordclock/settings/settings_controller.dart';

class LanguageSelector extends StatelessWidget {
  final SettingsController controller;

  const LanguageSelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SettingsController.supportedLanguages.map((lang) {
            final isSelected = controller.currentLanguage.id == lang.id;
            final label = lang.description != null
                ? '${lang.displayName} (${lang.description})'
                : lang.displayName;
            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  controller.setLanguage(lang);
                }
              },
            );
          }).toList(),
        );
      },
    );
  }
}
