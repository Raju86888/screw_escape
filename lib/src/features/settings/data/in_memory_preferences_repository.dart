import 'package:screw_escape/src/features/settings/domain/preferences_repository.dart';

/// In-memory implementation of [PreferencesRepository].
///
/// Used for unit testing and headless test environments without
/// platform channel dependencies. Supports simulated faults for testing.
class InMemoryPreferencesRepository implements PreferencesRepository {
  final Map<String, bool> _storage = {};

  /// When true, simulated read operations throw a [PreferencesReadException].
  bool throwOnRead = false;

  /// When true, simulated write operations throw a [PreferencesWriteException].
  bool throwOnWrite = false;

  @override
  Future<bool> getBool(String key, {bool defaultValue = true}) async {
    if (throwOnRead) {
      throw const PreferencesReadException('Simulated storage read failure');
    }
    return _storage[key] ?? defaultValue;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    if (throwOnWrite) {
      throw const PreferencesWriteException('Simulated storage write failure');
    }
    _storage[key] = value;
  }
}

/// Exception thrown when reading preferences fails.
class PreferencesReadException implements Exception {
  final String message;
  const PreferencesReadException(this.message);

  @override
  String toString() => 'PreferencesReadException: $message';
}

/// Exception thrown when writing preferences fails.
class PreferencesWriteException implements Exception {
  final String message;
  const PreferencesWriteException(this.message);

  @override
  String toString() => 'PreferencesWriteException: $message';
}

