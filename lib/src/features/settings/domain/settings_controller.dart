import 'package:flutter/foundation.dart';
import 'package:screw_escape/src/core/config/app_config.dart';
import 'package:screw_escape/src/features/settings/domain/preferences_repository.dart';

/// State controller managing player settings and audio preferences.
///
/// Designed to be pure Dart and testable in headless unit test environments.
/// Protects against initialization race conditions and storage read/write faults.
class SettingsController extends ChangeNotifier {
  final PreferencesRepository _repository;

  bool _soundEnabled = AppConfig.defaultSoundEnabled;
  bool _isLoaded = false;
  bool _userHasMutated = false;

  SettingsController(this._repository);

  /// Whether sound effects and audio feedback are enabled.
  bool get soundEnabled => _soundEnabled;

  /// Whether initial preferences have been loaded from persistent storage.
  bool get isLoaded => _isLoaded;

  /// Asynchronously loads persisted sound preference on cold start.
  ///
  /// Protects against storage read faults by safely falling back to defaults.
  /// If the user explicitly toggled the setting before loading completed,
  /// the user's explicit preference is preserved and not overwritten.
  Future<void> loadSettings() async {
    try {
      final persisted = await _repository.getBool(
        AppConfig.soundPrefKey,
        defaultValue: AppConfig.defaultSoundEnabled,
      );

      // Race guard: do not overwrite a user action made prior to load completion.
      if (!_userHasMutated) {
        _soundEnabled = persisted;
      }
    } catch (_) {
      // Storage read failure fallback: maintain default without crashing.
      if (!_userHasMutated) {
        _soundEnabled = AppConfig.defaultSoundEnabled;
      }
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  /// Updates the sound preference immediately in memory and persists asynchronously.
  ///
  /// Propagated storage write failures are caught internally so the in-memory
  /// state remains responsive and the UI does not crash with an unhandled error.
  Future<void> setSoundEnabled(bool value) async {
    _userHasMutated = true;
    _soundEnabled = value;
    notifyListeners();

    try {
      await _repository.setBool(AppConfig.soundPrefKey, value);
    } catch (_) {
      // Write failure handled gracefully: in-memory state remains responsive.
      // Unhandled exceptions are prevented from bubbling to UI callers.
    }
  }
}

