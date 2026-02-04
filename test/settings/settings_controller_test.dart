import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wordclock/settings/settings_controller.dart';
import 'package:wordclock/services/platform_service.dart';

class MockPlatformService implements PlatformService {
  @override
  final bool isWeb;
  @override
  final Uri baseUri;
  @override
  final List<Locale> systemLocales;
  final Map<String, Object> prefsValues;

  MockPlatformService({
    this.isWeb = false,
    Uri? baseUri,
    this.systemLocales = const [Locale('en', 'US')],
    this.prefsValues = const {},
  }) : baseUri = baseUri ?? Uri.parse('http://localhost/');

  @override
  Future<SharedPreferences> get sharedPreferences async {
    SharedPreferences.setMockInitialValues(prefsValues);
    return SharedPreferences.getInstance();
  }
}

void main() {
  group('SettingsController _resolveLanguage', () {
    test('Prioritizes Web URL Path (e.g. /es-ES)', () async {
      final service = MockPlatformService(
        isWeb: true,
        baseUri: Uri.parse('http://wordclock.com/es-ES'),
        prefsValues: {'preferred_language_id': 'FR'}, // Should be ignored
      );
      final controller = SettingsController(platformService: service);
      await controller.loadSettings();

      expect(controller.gridLanguage.id, 'ES');
    });

    test('Prioritizes Web URL Fragment (e.g. #/it-IT)', () async {
      final service = MockPlatformService(
        isWeb: true,
        baseUri: Uri.parse('http://wordclock.com/#/it-IT'),
        prefsValues: {'preferred_language_id': 'FR'}, // Should be ignored
      );
      final controller = SettingsController(platformService: service);
      await controller.loadSettings();

      expect(controller.gridLanguage.id, 'IT');
    });

    test('Prioritizes Persistence if not Web (or URL empty)', () async {
      final service = MockPlatformService(
        isWeb: false,
        prefsValues: {'preferred_language_id': 'FR'},
      );
      final controller = SettingsController(platformService: service);
      await controller.loadSettings();

      expect(controller.gridLanguage.id, 'FR');
    });

    test('Prioritizes System Locale if Persistence missing', () async {
      final service = MockPlatformService(
        isWeb: false,
        systemLocales: [const Locale('de', 'DE')],
      );
      final controller = SettingsController(platformService: service);
      await controller.loadSettings();

      expect(controller.gridLanguage.id.startsWith('D'), true);
    });

    test('Falls back to Default (EN) if no match', () async {
      final service = MockPlatformService(
        isWeb: false,
        systemLocales: [const Locale('xx', 'YY')], // Unknown locale
      );
      final controller = SettingsController(platformService: service);
      await controller.loadSettings();

      expect(controller.gridLanguage.id, 'EN');
    });

    test('Web URL invalid, Persistence valid -> Persistence', () async {
      final service = MockPlatformService(
        isWeb: true,
        baseUri: Uri.parse('http://wordclock.com/INVALID'),
        prefsValues: {'preferred_language_id': 'ES'},
      );
      final controller = SettingsController(platformService: service);
      await controller.loadSettings();

      expect(controller.gridLanguage.id, 'ES');
    });
  });
}
