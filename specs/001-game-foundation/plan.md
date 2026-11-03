# Technical Implementation Plan: Game Foundation

* **Feature ID**: `SPEC-001`
* **Spec Reference**: `specs/001-game-foundation/spec.md`
* **Status**: `Approved`
* **Author**: `Development Team`
* **Date**: `2026-11-03`

---

## 1. Architectural Strategy & Principles

This plan establishes the core architecture for **Screw Escape** following Clean Architecture principles adapted for lightweight, high-performance Flutter casual gaming:

* **Separation of Concerns**:
  * **Domain Layer (Pure Dart)**: Pure business models, settings controller logic, and repository interfaces. No `flutter/material.dart` or UI dependencies. 100% unit-testable.
  * **Data Layer**: Concrete persistence implementations (local storage) implementing domain repository contracts with graceful error handling.
  * **Presentation Layer (Flutter)**: Design tokens, reusable visual components (`CustomPainter`), views, modals, and navigation routes.
* **Minimalist State Management**: Use Flutter's built-in `ChangeNotifier` and `ListenableBuilder` / `AnimatedBuilder`. No heavy external state management dependencies (such as BLoC, Riverpod, or Redux) are needed.
* **Declarative Navigation**: Built-in Flutter `Navigator` with robust `try/finally` state guards to avoid navigation lock-ups.
* **Zero External Visual Assets**: All textures, metallic screws, and beveled wooden planks are rendered programmatically via Flutter's `Canvas`, `CustomPainter`, `BoxDecoration`, `LinearGradient`, and `BoxShadow`.
* **Single Source of Truth for Configuration**: Centralized constants for application metadata (such as versioning) to eliminate hardcoded duplicates across UI views.

---

## 2. Proposed Folder Structure & Responsibilities

```text
lib/
├── main.dart                                # Entry point: orientation lock & app bootstrap
└── src/
    ├── app.dart                             # ScrewEscapeApp: MaterialApp configuration & theme
    ├── core/
    │   ├── config/
    │   │   └── app_config.dart              # Single source of truth for app metadata (version, build)
    │   ├── theme/
    │   │   ├── app_colors.dart              # Semantic wood, metallic, and CTA color tokens
    │   │   ├── app_text_styles.dart         # Typography hierarchy
    │   │   └── app_spacing.dart             # Spacing constants (4dp to 32dp)
    │   └── widgets/
    │       ├── metallic_button.dart         # Tactile beveled button (Play, Levels, Back)
    │       ├── wood_surface.dart            # Native wood-grain container / CustomPainter
    │       ├── screw_accent.dart            # Native metallic screw head CustomPainter
    │       └── responsive_container.dart    # Safe-area and max-width layout constraint wrapper
    └── features/
        ├── home/
        │   └── presentation/
        │       ├── home_screen.dart         # Main landing view with title, action buttons & debounce guard
        │       └── widgets/
        │           ├── game_title.dart      # Stylized embossed title with screw accents
        │           └── level_select_dialog.dart # Placeholder level select modal
        ├── gameplay_placeholder/
        │   └── presentation/
        │       └── gameplay_placeholder_screen.dart # "Gameplay coming soon" screen with Back button
        └── settings/
            ├── domain/
            │   ├── preferences_repository.dart # Abstract contract for key-value persistence
            │   └── settings_controller.dart    # Pure Dart ChangeNotifier with race & error guards
            ├── data/
            │   ├── in_memory_preferences_repository.dart # Lightweight fallback / test repository
            │   └── shared_preferences_repository.dart   # Local storage implementation with try/catch
            └── presentation/
                ├── settings_dialog.dart        # Wooden/metallic modal dialog
                └── widgets/
                    └── sound_toggle_row.dart   # Tactile toggle switch for sound with loading guard
```

---

## 3. Design System & Configuration Architecture

### 3.1 Single Source of Truth for App Metadata (`AppConfig`)
To prevent hardcoded duplicates across the Home Screen header and Settings dialog, a centralized configuration class will be established:

```dart
// lib/src/core/config/app_config.dart
abstract final class AppConfig {
  static const String appName = 'Screw Escape';
  static const String appVersion = 'v1.0.0';
  static const bool defaultSoundEnabled = true;
  static const String soundPrefKey = 'pref_sound_enabled';
}
```

### 3.2 Design Tokens

* **Colors (`AppColors`)**:
  * *Wood Palette*: `woodDark` (`#2C1810`), `woodMedium` (`#4A2E1B`), `woodLight` (`#7A5230`), `woodSurface` (`#8B5A2B`), `woodPlankDivider` (`#1F110B`).
  * *Metallic Palette*: `metalGold` (`#D4AF37`), `metalGoldDark` (`#AA820A`), `metalSilver` (`#C0C0C0`), `metalSilverDark` (`#7F8C8D`), `gunmetal` (`#2B2D2F`), `metalHighlight` (`#FFFFFF` at 40% opacity).
  * *CTA Palette*: `playGreen` (`#2E7D32`), `playGreenLight` (`#4CAF50`), `playGreenDark` (`#1B5E20`).
* **Typography (`AppTextStyles`)**:
  * `gameTitle`: Bold embossed header with letter-spacing, drop-shadows.
  * `buttonLabel`: Heavy, high-contrast, uppercase styling with text shadow.
  * `body`: Crisp, readable sans-serif for dialogs and descriptions.
* **Spacing (`AppSpacing`)**: `xs: 4`, `sm: 8`, `md: 16`, `lg: 24`, `xl: 32`.

### 3.3 Native Visual Components (Zero External Images)

1. **`WoodSurface` (`CustomPainter` / Layered Decoration)**:
   * Uses vertical gradient stops and horizontal plank lines drawn via `CustomPainter` to mimic natural timber grain without any external bitmap images.
2. **`ScrewAccent` (`CustomPainter`)**:
   * Draws a radial gradient circle bounded by a dark shadow, a rim highlight ring, and an inner recessed Phillips cross (`+`) or slotted groove (`-`) in gunmetal/silver.
3. **`MetallicButton` (`StatefulWidget`)**:
   * Multi-layer beveled physical button:
     * Outer shadow (giving elevation off the wood board).
     * Beveled border with top-light highlight and bottom-dark shadow.
     * Inner gradient fill (`playGreen` or `metalGold` or `metalSilver`).
     * On-press translation (`Transform.translate(offset: Offset(0, 2))`) and shadow compression to give an authentic tactile feel within 1 frame (< 16ms).

---

## 4. Navigation & State Management

### 4.1 State Management: `SettingsController` with Error & Race Guarding

The controller guarantees that:
1. **Async Race Protection**: An asynchronous load completing after a user interaction *cannot* overwrite the user's explicit choice.
2. **Fault Tolerance**: Read or write failures in the underlying repository are caught safely and do not throw unhandled exceptions or crash the app. The in-memory state remains responsive and defaults safely.
3. **Ready Indicator**: Exposes `isLoaded` so UI widgets can disable the toggle or display a subtle loading indicator until initial state resolution completes.

```dart
class SettingsController extends ChangeNotifier {
  final PreferencesRepository _repository;
  bool _soundEnabled = AppConfig.defaultSoundEnabled;
  bool _isLoaded = false;
  bool _userHasMutated = false;

  SettingsController(this._repository);

  bool get soundEnabled => _soundEnabled;
  bool get isLoaded => _isLoaded;

  /// Loads persisted sound setting safely on cold start.
  Future<void> loadSettings() async {
    try {
      final persisted = await _repository.getBool(
        AppConfig.soundPrefKey,
        defaultValue: AppConfig.defaultSoundEnabled,
      );
      // Race guard: If the user toggled the setting before async load completed,
      // preserve the user's explicit choice and discard the older storage read.
      if (!_userHasMutated) {
        _soundEnabled = persisted;
      }
    } catch (e) {
      // Storage failure fallback: maintain default without crashing.
      if (!_userHasMutated) {
        _soundEnabled = AppConfig.defaultSoundEnabled;
      }
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  /// Sets sound setting, updating memory immediately and persisting asynchronously.
  Future<void> setSoundEnabled(bool value) async {
    _userHasMutated = true;
    _soundEnabled = value;
    notifyListeners();

    try {
      await _repository.setBool(AppConfig.soundPrefKey, value);
    } catch (e) {
      // Graceful write failure: keep in-memory state responsive and intact.
      // Log error internally without bubbling unhandled exception to UI.
    }
  }
}
```

### 4.2 Navigation Architecture & Resilient Debounce Guard

To satisfy requirement `EC-05` and prevent navigation lockouts:
* **The Problem**: A naive boolean `_isNavigating = true` can permanently disable the Play button if navigation throws an unexpected exception or if the pop event isn't captured properly.
* **The Solution**: A robust `try/finally` lifecycle pattern attached to the async push:

```dart
// In HomeScreenState:
bool _isNavigating = false;

Future<void> _onPlayPressed() async {
  if (_isNavigating) return;
  _isNavigating = true;

  try {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const GameplayPlaceholderScreen(),
      ),
    );
  } finally {
    // try/finally guarantees _isNavigating resets to false when returning from
    // GameplayPlaceholderScreen or if an unexpected navigation exception occurs.
    if (mounted) {
      setState(() {
        _isNavigating = false;
      });
    }
  }
}
```

---

## 5. Local Storage & Sound Preference Persistence

### 5.1 Architecture & Exception Handling

```dart
// Domain contract (lib/src/features/settings/domain/preferences_repository.dart)
abstract class PreferencesRepository {
  Future<bool> getBool(String key, {bool defaultValue = true});
  Future<void> setBool(String key, bool value);
}

// Concrete SharedPreferences wrapper (lib/src/features/settings/data/shared_preferences_repository.dart)
class SharedPreferencesRepository implements PreferencesRepository {
  final SharedPreferencesAsync? _asyncPrefs; // Or SharedPreferences instance

  @override
  Future<bool> getBool(String key, {bool defaultValue = true}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(key) ?? defaultValue;
    } catch (e) {
      // Fallback safely to default if disk read or platform channel fails
      return defaultValue;
    }
  }

  @override
  Future<void> setBool(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      // Re-throw or absorb depending on controller policy; controller catches safely.
    }
  }
}

// In-Memory test/fallback repository (lib/src/features/settings/data/in_memory_preferences_repository.dart)
class InMemoryPreferencesRepository implements PreferencesRepository {
  final Map<String, dynamic> _storage = {};
  bool throwOnRead = false;
  bool throwOnWrite = false;

  @override
  Future<bool> getBool(String key, {bool defaultValue = true}) async {
    if (throwOnRead) throw Exception('Simulated read failure');
    return _storage[key] as bool? ?? defaultValue;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    if (throwOnWrite) throw Exception('Simulated write failure');
    _storage[key] = value;
  }
}
```

---

## 6. Orientation Lock Implementation

* In `android/app/src/main/AndroidManifest.xml`:
  Ensure `<activity android:name=".MainActivity" ... android:screenOrientation="portrait" ...>` is set.
* In `lib/main.dart`:
  ```dart
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  ```

---

## 7. Requirements Traceability Matrix

| Requirement ID | Architectural Component | Class / File | Verification Method |
|---|---|---|---|
| `REQ-001-01` | Bootstrap & Android Manifest | `lib/main.dart`, `AndroidManifest.xml` | Device / Emulator Verification |
| `REQ-001-02` | Design System & Theme | `lib/src/core/theme/*` | Widget & Screenshot Tests |
| `REQ-001-03` | Home Screen & Nav Guard | `lib/src/features/home/presentation/home_screen.dart` | Widget Test |
| `REQ-001-04` | Gameplay Placeholder | `lib/src/features/gameplay_placeholder/presentation/gameplay_placeholder_screen.dart` | Widget Navigation Test |
| `REQ-001-05` | Settings Dialog | `lib/src/features/settings/presentation/settings_dialog.dart` | Widget Test |
| `REQ-001-06` | Sound Persistence & Error Guards | `lib/src/features/settings/domain/settings_controller.dart`, `preferences_repository.dart` | Pure Dart Unit Test |
| `REQ-001-07` | Level Select Entry | `lib/src/features/home/presentation/widgets/level_select_dialog.dart` | Widget Test |
| `REQ-001-08` | Reusable UI Widgets | `lib/src/core/widgets/metallic_button.dart`, `wood_surface.dart`, `screw_accent.dart` | Widget Tests |
| `NFR-001-01` | Performance / Smoothness | Native rendering via `CustomPainter` & lightweight widgets | Manual frame profile |
| `NFR-001-02` | Native Visuals Only | All widgets use `CustomPainter`, `Canvas`, and gradients (0 images) | Code review & audit |
| `NFR-001-03` | Responsive Layout | `lib/src/core/widgets/responsive_container.dart`, `SingleChildScrollView` | Multi-viewport Widget Tests |
| `NFR-001-04` | Testing Architecture | Unit tests (Domain/Data) + Widget tests (UI) | `flutter test` automated suite |
| `NFR-001-05` | Touch Responsiveness | Immediate visual translation in `MetallicButton` | Widget gesture tests |
| Single Version Truth | Configuration | `lib/src/core/config/app_config.dart` | Unit & Widget Tests |

---

## 8. Testing Strategy

### 8.1 Unit Tests (Pure Dart)
* `test/unit/settings_controller_test.dart`:
  * Default sound state is `AppConfig.defaultSoundEnabled` (`true`).
  * `setSoundEnabled` toggles state immediately and notifies listeners.
  * **Race Condition Prevention**: User toggle before `loadSettings()` completes is preserved and NOT overwritten by the slower storage read.
  * **Fault Tolerance (Read Failure)**: When repository throws on `getBool`, controller falls back to default (`true`), marks `isLoaded = true`, and app stays healthy.
  * **Fault Tolerance (Write Failure)**: When repository throws on `setBool`, in-memory state remains updated and UI does not crash.
* `test/unit/in_memory_preferences_repository_test.dart`:
  * Correctly stores and retrieves boolean keys.
  * Handles default values when key is absent.

### 8.2 Widget Tests (Flutter UI)
* `test/widget/home_screen_test.dart`:
  * Verifies title, Play button, Settings button, and Levels button are rendered.
  * Displays version string from `AppConfig.appVersion`.
  * Tapping Settings opens `SettingsDialog`.
  * Tapping Levels opens `LevelSelectDialog`.
* `test/widget/play_navigation_test.dart`:
  * Tapping Play navigates to `GameplayPlaceholderScreen`.
  * Verifies "Gameplay coming soon" and Back button are displayed.
  * Tapping Back returns to `HomeScreen`.
  * **Debounce Guard Test**: Rapid multiple taps trigger only a single push; returning to Home Screen clears the guard so Play can be tapped again.
* `test/widget/settings_dialog_test.dart`:
  * Displays version string from `AppConfig.appVersion`.
  * Renders sound toggle matching current controller state.
  * Tapping sound toggle switches state in `SettingsController`.
  * Close button dismisses the dialog.
* `test/widget/reusable_components_test.dart`:
  * Tests `MetallicButton`, `WoodSurface`, and `ScrewAccent` rendering.
  * Verifies `MetallicButton` responds to tap gestures and disabled states.
* `test/widget/responsive_layout_test.dart`:
  * Tests layout rendering across viewports (320x568, 390x844, 412x915, 800x1280) with zero `RenderFlex` overflow exceptions.

---

## 9. Dependency Evaluation

* **Proposed External Dependency**: `shared_preferences: ^2.2.0`
  * **Role**: Platform-specific implementation for `SharedPreferencesRepository`.
  * **Justification**: Official Flutter package maintained by the Flutter team. Provides robust, standard key-value persistence on Android via `SharedPreferences`.
  * **Decoupling**: Domain business logic and controllers interact only with the abstract `PreferencesRepository` interface, keeping business logic pure and unit-testable without platform channel overhead.
* **UI/Animation Dependencies**: None. Zero 3rd-party UI libraries.

---

## 10. Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|---|---|---|---|
| Screen overflow on ultra-small Android screens | Medium | Low | Wrap content in `SingleChildScrollView` with safe-area constraints. |
| Double-tap causing duplicate route pushes or permanent lock | Medium | Medium | Wrap navigation in `try/finally` to guarantee `_isNavigating` resets to `false`. |
| Storage read/write failure or delay on cold start | Medium | Low | In-memory default with `try/catch` fallbacks and race condition prevention in `SettingsController`. |
| Version mismatch across UI components | Low | Low | Centralize version string in `AppConfig.appVersion`. |

---

## 11. Sign-off & Approvals

* **Reviewed By**: Project Lead
* **Approval Date**: 2026-11-03
* **Approval Status**: Approved (Revision 1)
* **Revision Notes**:
  * Revision 1: Added explicit exception handling for persistence failures, implemented race-condition prevention in `SettingsController`, implemented `try/finally` navigation debounce guard in `HomeScreen`, and established `AppConfig` as the single source of truth for app metadata. Approved for implementation breakdown (`tasks.md`).
