import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wordclock/constants.dart';
import 'package:wordclock/settings/settings_controller.dart';
import 'package:wordclock/settings/theme_settings.dart';
import 'package:wordclock/ui/settings/components/debug_settings.dart';
import 'package:wordclock/ui/settings/components/language_selector.dart';
import 'package:wordclock/ui/settings/components/section_header.dart';
import 'package:wordclock/ui/settings/components/theme_selector.dart';

import 'package:go_router/go_router.dart';
import 'package:wordclock/languages/language.dart';

class SettingsPanel extends StatelessWidget {
  final SettingsController controller;

  const SettingsPanel({super.key, required this.controller});

  String _getUiDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'es':
        return 'Español';
      default:
        return locale.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the controller for changes to rebuild the UI
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final settings = controller.settings;

        // Sort languages for the selector
        final sortedLanguages = List<WordClockLanguage>.from(
          SettingsController.supportedLanguages.where((l) => !l.isHidden),
        );
        sortedLanguages.sort((a, b) {
          if (a.isAlternative != b.isAlternative) {
            return a.isAlternative ? 1 : -1;
          }
          final nameCompare = a.displayName.compareTo(b.displayName);
          if (nameCompare != 0) return nameCompare;
          return (a.description ?? '').compareTo(b.description ?? '');
        });

        // Sort UI locales
        final sortedUiLocales = List<Locale>.from(
          SettingsController.supportedUiLocales,
        );
        sortedUiLocales.sort(
          (a, b) => _getUiDisplayName(a).compareTo(_getUiDisplayName(b)),
        );

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
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      const SectionHeader(title: 'Interface Language'),
                      LanguageSelector<Locale>(
                        currentSelection: controller.uiLocale,
                        availableOptions: sortedUiLocales,
                        labelBuilder: _getUiDisplayName,
                        onSelected: controller.setUiLocale,
                        icon: Icons.translate,
                        semanticsLabelPrefix: 'Interface Language',
                      ),
                      const SizedBox(height: 16),
                      const SectionHeader(title: 'Clock Language'),
                      LanguageSelector<WordClockLanguage>(
                        currentSelection: controller.gridLanguage,
                        availableOptions: sortedLanguages,
                        labelBuilder: (l) => l.displayName,
                        subtitleBuilder: (l) => l.description,
                        searchKeywordsBuilder: (l) => l.englishName,
                        styleBuilder: (l) => l.id == 'KP'
                            ? const TextStyle(fontFamily: 'KlingonPiqad')
                            : null,
                        onSelected: (l) {
                          context.go('/${l.languageCode}');
                        },
                        icon: Icons.language,
                        semanticsLabelPrefix: 'Clock Language',
                      ),
                      const SizedBox(height: 24),
                      const SectionHeader(title: 'Theme'),
                      ThemeSelector(
                        currentTheme: settings,
                        onThemeChanged: controller.updateTheme,
                      ),
                      const SizedBox(height: 24),
                      const SectionHeader(title: 'Display'),
                      Tooltip(
                        message:
                            'The four corner dots represent 1, 2, 3, and 4 minutes past each five-minute step.',
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Show Minute Dots'),
                          subtitle: const Text(
                            'Displays corner dots for precise minutes',
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
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Plasma Text'),
                        subtitle: const Text(
                          'Adds animated background color effect',
                        ),
                        value: settings.backgroundType == BackgroundType.plasma,
                        activeThumbColor: settings.activeGradientColors.last,
                        onChanged: (value) {
                          controller.setBackgroundType(
                            value
                                ? BackgroundType.plasma
                                : BackgroundType.solid,
                          );
                        },
                      ),

                      const SizedBox(height: 32),
                      Text(
                        'About',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('WordClock v1.0'),
                        subtitle: Text(
                          'Built with Flutter',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('by bramp'),
                        trailing: const Icon(Icons.open_in_new, size: 20),
                        onTap: () async {
                          final uri = Uri.parse(kAuthorUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Licenses'),
                        trailing: const Icon(Icons.description, size: 20),
                        onTap: () {
                          showLicensePage(
                            context: context,
                            applicationName: 'WordClock',
                            applicationVersion: 'v1.0.0',
                            applicationIcon: const Icon(Icons.access_time),
                          );
                        },
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Privacy Policy'),
                        trailing: const Icon(Icons.open_in_new, size: 20),
                        onTap: () async {
                          final uri = Uri.parse(kPrivacyPolicyUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
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
