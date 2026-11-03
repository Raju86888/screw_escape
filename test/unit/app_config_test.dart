import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('defines correct application metadata and default values', () {
      expect(AppConfig.appName, equals('Screw Escape'));
      expect(AppConfig.appVersion, equals('v1.0.0'));
      expect(AppConfig.defaultSoundEnabled, isTrue);
      expect(AppConfig.soundPrefKey, equals('pref_sound_enabled'));
    });
  });
}

