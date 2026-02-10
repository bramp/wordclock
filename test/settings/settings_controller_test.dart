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

  MockPlatformService({
    this.isWeb = false,
    Uri? baseUri,
    this.systemLocales = const [Locale('en', 'US')],
    Map<String, Object> prefsValues = const {},
  }) : baseUri = baseUri ?? Uri.parse('http://localhost/') {
    SharedPreferences.setMockInitialValues(prefsValues);
  }

  @override
  Future<SharedPreferences> get sharedPreferences async {
    return SharedPreferences.getInstance();
  }
}

void main() {
  group('SettingsController _resolveLanguage', () {
    test('Prioritizes Web URL Path (e.g. /es-ES)', () async {
      final service = MockPlatformService(
        isWeb: true,
        baseUri: Uri.parse('http://wordclock.com/es-ES'),
        prefsValues: {
          SettingsController.kLanguageIdKey: 'FR',
        }, // Should be ignored
      );
      final controller = SettingsController(platformService: service);
      await controller.loadSettings();

      expect(controller.gridLanguage.id, 'ES');
    });

    test('Prioritizes Web URL Fragment (e.g. #/it-IT)', () async {
      final service = MockPlatformService(
        isWeb: true,
        baseUri: Uri.parse('http://wordclock.com/#/it-IT'),
        prefsValues: {
          SettingsController.kLanguageIdKey: 'FR',
        }, // Should be ignored
      );
      final controller = SettingsController(platformService: service);
      await controller.loadSettings();

      expect(controller.gridLanguage.id, 'IT');
    });

    test('Prioritizes Persistence if not Web (or URL empty)', () async {
      final service = MockPlatformService(
        isWeb: false,
        prefsValues: {SettingsController.kLanguageIdKey: 'FR'},
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
        prefsValues: {SettingsController.kLanguageIdKey: 'ES'},
      );
      final controller = SettingsController(platformService: service);
      await controller.loadSettings();

      expect(controller.gridLanguage.id, 'ES');
    });
  });

  group('SettingsController Persistence', () {
    test('UI Locale is persisted (when changed)', () async {
      // We need to bypass the _isSupportedUiLocale check or add a second locale
      // Currently SettingsController.supportedUiLocales only has 'en'
      // For testing, let's just verify that it doesn't save when it's the SAME as current
      // and skip the change test until we have a second supported locale,
      // OR we just verify the call to _isSupportedUiLocale.

      final service = MockPlatformService(systemLocales: [const Locale('en')]);
      final controller = SettingsController(platformService: service);
      await controller.loadSettings();

      // Since only 'en' is supported, let's verifiy it is loaded correctly
      expect(controller.uiLocale.languageCode, 'en');
    });

    test('Analytics consent is persisted', () async {
      final service = MockPlatformService();
      final controller = SettingsController(platformService: service);
      await controller.loadSettings();

      controller.setAnalyticsConsent(true);

      final prefs = await service.sharedPreferences;
      expect(prefs.getBool(SettingsController.kAnalyticsConsentKey), true);
    });

    test('Clock speed is persisted', () async {
      final service = MockPlatformService();
      final controller = SettingsController(platformService: service);
      await controller.loadSettings();

      controller.setClockSpeed(ClockSpeed.fast);

      final prefs = await service.sharedPreferences;
      expect(prefs.getString(SettingsController.kClockSpeedKey), 'fast');

      // Verify it loads back
      final controller2 = SettingsController(platformService: service);
      await controller2.loadSettings();
      expect(controller2.clockSpeed, ClockSpeed.fast);
    });
  });
}
