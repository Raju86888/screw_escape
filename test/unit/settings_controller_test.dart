import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/core/config/app_config.dart';
import 'package:screw_escape/src/features/settings/data/in_memory_preferences_repository.dart';
import 'package:screw_escape/src/features/settings/domain/preferences_repository.dart';
import 'package:screw_escape/src/features/settings/domain/settings_controller.dart';

class _SlowPreferencesRepository implements PreferencesRepository {
  final Completer<bool> completer = Completer<bool>();

  @override
  Future<bool> getBool(String key, {bool defaultValue = true}) {
    return completer.future;
  }

  @override
  Future<void> setBool(String key, bool value) async {}
}

void main() {
  group('SettingsController (TDD)', () {
    late InMemoryPreferencesRepository repository;
    late SettingsController controller;

    setUp(() {
      repository = InMemoryPreferencesRepository();
      controller = SettingsController(repository);
    });

    test('initial state matches default config and is not loaded', () {
      expect(controller.soundEnabled, equals(AppConfig.defaultSoundEnabled));
      expect(controller.isLoaded, isFalse);
    });

    test('loadSettings updates state from repository and notifies listeners',
        () async {
      await repository.setBool(AppConfig.soundPrefKey, false);

      var notificationCount = 0;
      controller.addListener(() {
        notificationCount++;
      });

      await controller.loadSettings();

      expect(controller.soundEnabled, isFalse);
      expect(controller.isLoaded, isTrue);
      expect(notificationCount, equals(1));
    });

    test('setSoundEnabled updates state immediately and notifies listeners',
        () async {
      var notificationCount = 0;
      controller.addListener(() {
        notificationCount++;
      });

      await controller.setSoundEnabled(false);

      expect(controller.soundEnabled, isFalse);
      expect(notificationCount, equals(1));

      final persisted = await repository.getBool(AppConfig.soundPrefKey);
      expect(persisted, isFalse);
    });

    test('prevents race condition: user toggle is not overwritten by late load',
        () async {
      final slowRepo = _SlowPreferencesRepository();
      final raceController = SettingsController(slowRepo);

      // 1. Trigger async load (which does not complete yet)
      final loadFuture = raceController.loadSettings();
      expect(raceController.isLoaded, isFalse);

      // 2. User explicitly toggles sound to false before load finishes
      await raceController.setSoundEnabled(false);
      expect(raceController.soundEnabled, isFalse);

      // 3. Slower storage read resolves with 'true'
      slowRepo.completer.complete(true);
      await loadFuture;

      // 4. Verification: The user's explicit action (false) must be preserved!
      expect(raceController.soundEnabled, isFalse);
      expect(raceController.isLoaded, isTrue);
    });

    test('fault tolerance: storage read failure falls back safely to default',
        () async {
      repository.throwOnRead = true;

      var notified = false;
      controller.addListener(() {
        notified = true;
      });

      await expectLater(controller.loadSettings(), completes);

      expect(controller.soundEnabled, equals(AppConfig.defaultSoundEnabled));
      expect(controller.isLoaded, isTrue);
      expect(notified, isTrue);
    });

    test('fault tolerance: storage write failure keeps in-memory state responsive',
        () async {
      repository.throwOnWrite = true;

      var notified = false;
      controller.addListener(() {
        notified = true;
      });

      await expectLater(controller.setSoundEnabled(false), completes);

      // State is still updated in-memory for the user without an unhandled crash
      expect(controller.soundEnabled, isFalse);
      expect(notified, isTrue);
    });
  });
}

