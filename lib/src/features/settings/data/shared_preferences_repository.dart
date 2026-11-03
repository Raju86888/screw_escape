import 'package:shared_preferences/shared_preferences.dart';
import 'package:screw_escape/src/features/settings/domain/preferences_repository.dart';

/// Concrete implementation of [PreferencesRepository] backed by [SharedPreferences].
///
/// Encapsulates platform storage operations for Android. Read failures
/// fall back to defaults, while write failures are propagated to callers
/// (such as [SettingsController]) to prevent silent double-swallowing.
class SharedPreferencesRepository implements PreferencesRepository {
  final SharedPreferences? _prefsInstance;

  /// Creates a repository, optionally accepting a pre-initialized [prefsInstance] for testing.
  SharedPreferencesRepository([this._prefsInstance]);

  Future<SharedPreferences> _getPrefs() async {
    return _prefsInstance ?? await SharedPreferences.getInstance();
  }

  @override
  Future<bool> getBool(String key, {bool defaultValue = true}) async {
    try {
      final prefs = await _getPrefs();
      return prefs.getBool(key) ?? defaultValue;
    } catch (_) {
      // Safe fallback if reading from storage fails
      return defaultValue;
    }
  }

  @override
  Future<void> setBool(String key, bool value) async {
    // Write failures propagate directly to the controller layer so errors
    // are handled centrally without being silently swallowed at both layers.
    final prefs = await _getPrefs();
    await prefs.setBool(key, value);
  }
}

