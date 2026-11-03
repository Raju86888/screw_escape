/// Application-wide configuration and metadata constants.
///
/// Acts as the single source of truth for branding, versioning,
/// and default application preferences.
abstract final class AppConfig {
  /// User-facing application display name.
  static const String appName = 'Screw Escape';

  /// Semantic version string displayed across UI components.
  static const String appVersion = 'v1.0.0';

  /// Default state for sound effects and audio.
  static const bool defaultSoundEnabled = true;

  /// Key used to persist the sound preference in local storage.
  static const String soundPrefKey = 'pref_sound_enabled';
}

