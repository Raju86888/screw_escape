/// Abstract contract for key-value preferences persistence.
///
/// Decouples business logic and state controllers from platform-specific
/// storage implementations.
abstract class PreferencesRepository {
  /// Retrieves a boolean preference for the given [key].
  ///
  /// Returns [defaultValue] if the key does not exist or cannot be read.
  Future<bool> getBool(String key, {bool defaultValue = true});

  /// Persists a boolean preference for the given [key].
  ///
  /// Throws an exception if the write operation fails, allowing callers
  /// to handle persistence errors centrally.
  Future<void> setBool(String key, bool value);
}

