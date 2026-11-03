# Implementation Tasks: Game Foundation

* **Feature ID**: `SPEC-001`
* **Spec Reference**: `specs/001-game-foundation/spec.md`
* **Plan Reference**: `specs/001-game-foundation/plan.md`
* **Status**: `Pending Final Approval (Revision 1)`

> **SDD Rule**: No implementation task may begin until the task list is reviewed and approved. Each task must be independently verifiable with automated tests or concrete validation checks before marking as complete.

---

## Phase 1: Environment Setup & Project Configuration

- [x] **TASK-001-01**: Configure portrait orientation lock in Android Manifest and resolve compatible `shared_preferences` dependency
  - **Traces**: `REQ-001-01`, `AC-01`, Dependency Evaluation
  - **Details**:
    - Update `android/app/src/main/AndroidManifest.xml` with `android:screenOrientation="portrait"`.
    - Resolve and add the latest compatible stable version of `shared_preferences` (compatible with Dart `^3.13.7` and project Flutter SDK) under `dependencies` in `pubspec.yaml` without upgrading any unrelated dependencies.
  - **Verification**: Run `flutter pub get` and verify dependency resolves cleanly without upgrading unrelated packages.

- [x] **TASK-001-02**: Establish single source of truth for application metadata (`AppConfig`)
  - **Traces**: `REQ-001-02`, Single Version Truth, `AC-06`
  - **Details**:
    - Create `lib/src/core/config/app_config.dart` defining `appName = 'Screw Escape'`, `appVersion = 'v1.0.0'`, `defaultSoundEnabled = true`, and `soundPrefKey = 'pref_sound_enabled'`.
  - **Verification**: Write `test/unit/app_config_test.dart` asserting metadata constants.

---

## Phase 2: Domain & Data Layers (Sound Preferences & TDD)

- [x] **TASK-001-03**: Implement abstract `PreferencesRepository` contract and `InMemoryPreferencesRepository`
  - **Traces**: `REQ-001-06`, `NFR-001-04`, `AC-05`
  - **Details**:
    - Create `lib/src/features/settings/domain/preferences_repository.dart` defining `getBool` and `setBool`.
    - Create `lib/src/features/settings/data/in_memory_preferences_repository.dart` with support for simulated read/write exceptions.
  - **Verification**: Write `test/unit/in_memory_preferences_repository_test.dart` verifying in-memory storage, default fallback values, and simulated exception throwing.

- [x] **TASK-001-04**: Implement `SettingsController` using Test-Driven Development (TDD)
  - **Traces**: `REQ-001-05`, `REQ-001-06`, `EC-02`, `EC-03`, `AC-05`, `NFR-001-04`
  - **Details**:
    - Write unit test suite `test/unit/settings_controller_test.dart` testing:
      1. Default sound state equals `AppConfig.defaultSoundEnabled` (`true`).
      2. `setSoundEnabled` updates in-memory state and notifies listeners immediately.
      3. **Race Condition Guard**: A user toggle before `loadSettings()` completes is preserved and NOT overwritten by the slower async storage read.
      4. **Fault Tolerance (Read Failure)**: When repository read throws an exception, controller defaults safely to `true` and marks `isLoaded = true`.
      5. **Fault Tolerance (Write Failure)**: When repository write throws an exception, in-memory state stays responsive and the controller handles the error without crashing the UI.
    - Implement `lib/src/features/settings/domain/settings_controller.dart` to make all tests pass green.
  - **Verification**: Run `flutter test test/unit/settings_controller_test.dart` — 100% pass.

- [x] **TASK-001-05**: Implement `SharedPreferencesRepository` adapter with error propagation
  - **Traces**: `REQ-001-06`, `AC-05`
  - **Details**:
    - Create `lib/src/features/settings/data/shared_preferences_repository.dart` wrapping `SharedPreferences`.
    - Read operations fall back safely to default on failure; write operations propagate failures to `SettingsController` so errors are handled centrally at the controller layer without double-swallowing.
  - **Verification**: Write `test/unit/shared_preferences_repository_test.dart` using mock/in-memory SharedPreferences verifying read/write behavior and write failure propagation.

---

## Phase 3: Design System & Reusable Components (Native Painting Only)

- [x] **TASK-001-06**: Implement Theme Tokens (`AppColors`, `AppTextStyles`, `AppSpacing`)
  - **Traces**: `REQ-001-02`, `NFR-001-02`, `AC-02`
  - **Details**:
    - Create `lib/src/core/theme/app_colors.dart` (wood tones, metallic brass/silver, emerald green CTA tokens).
    - Create `lib/src/core/theme/app_text_styles.dart` (bold title, button label, body styles).
    - Create `lib/src/core/theme/app_spacing.dart` (`xs: 4`, `sm: 8`, `md: 16`, `lg: 24`, `xl: 32`).
  - **Verification**: Write `test/widget/theme_tokens_test.dart` verifying all color definitions, font styles, and spacing metrics.

- [x] **TASK-001-07**: Implement `ScrewAccent` metallic screw-head widget using `CustomPainter`
  - **Traces**: `REQ-001-02`, `REQ-001-08`, `NFR-001-02`, `AC-02`
  - **Details**:
    - Create `lib/src/core/widgets/screw_accent.dart` with a `CustomPainter` rendering radial gradient metallic screw head, outer drop shadow, bevel ring, and inner slotted/Phillips groove. Zero external images.
  - **Verification**: Write `test/widget/screw_accent_test.dart` verifying rendering at multiple sizes (e.g., 16dp, 24dp, 32dp).

- [x] **TASK-001-08**: Implement `WoodSurface` wood-grain background widget using `CustomPainter`
  - **Traces**: `REQ-001-02`, `REQ-001-08`, `NFR-001-02`, `AC-02`
  - **Details**:
    - Create `lib/src/core/widgets/wood_surface.dart` rendering horizontal plank dividers, vertical wood grain gradients, and vignette/shadow borders via native Flutter canvas painting.
  - **Verification**: Write `test/widget/wood_surface_test.dart` verifying widget layout and child container rendering.

- [x] **TASK-001-09**: Implement `MetallicButton` tactile widget
  - **Traces**: `REQ-001-02`, `REQ-001-08`, `NFR-001-05`, `AC-03`, `AC-06`
  - **Details**:
    - Create `lib/src/core/widgets/metallic_button.dart` supporting:
      - Primary (emerald green / gold) and secondary (silver / wood) styles.
      - Beveled 3D border and drop shadow.
      - Visual press translation (`Transform.translate(offset: Offset(0, 2))`) on tap down.
      - Disabled state handling.
  - **Verification**: Write `test/widget/metallic_button_test.dart` asserting tap callbacks, disabled state, and visual press states.

- [x] **TASK-001-10**: Implement `ResponsiveContainer` layout wrapper
  - **Traces**: `NFR-001-03`, `EC-04`, `AC-09`
  - **Details**:
    - Create `lib/src/core/widgets/responsive_container.dart` constraining max content width to 480dp on tablets/wide screens while wrapping children in `SafeArea`.
  - **Verification**: Write `test/widget/responsive_container_test.dart` checking tablet vs mobile width constraints.

---

## Phase 4: Screens, Dialogs & Navigation

- [x] **TASK-001-11**: Implement `GameplayPlaceholderScreen` with Back navigation
  - **Traces**: `REQ-001-04`, `AC-04`, `EC-05`
  - **Details**:
    - Create `lib/src/features/gameplay_placeholder/presentation/gameplay_placeholder_screen.dart` displaying:
      - Text: `"Gameplay coming soon"`.
      - Tactical placeholder board background.
      - Back button (using `MetallicButton` or app bar) that executes `Navigator.of(context).pop()`.
  - **Verification**: Write `test/widget/gameplay_placeholder_screen_test.dart` asserting text presence and Back button callback.

- [x] **TASK-001-12**: Implement `SettingsDialog` and `SoundToggleRow`
  - **Traces**: `REQ-001-05`, `REQ-001-06`, `AC-06`, Single Version Truth
  - **Details**:
    - Create `lib/src/features/settings/presentation/widgets/sound_toggle_row.dart` with a sound switch and loading guard (disabled if `!controller.isLoaded`).
    - Create `lib/src/features/settings/presentation/settings_dialog.dart` styled with `WoodSurface`, displaying:
      - Sound toggle row.
      - App version label referencing `AppConfig.appVersion`.
      - Close button dismissing the modal.
  - **Verification**: Write `test/widget/settings_dialog_test.dart` verifying toggle updates `SettingsController`, version displays accurately, and Close dismisses the dialog.

- [x] **TASK-001-13**: Implement `LevelSelectDialog` placeholder modal
  - **Traces**: `REQ-001-07`, `AC-07`
  - **Details**:
    - Create `lib/src/features/home/presentation/widgets/level_select_dialog.dart` displaying level selection coming soon information and a Close button.
  - **Verification**: Write `test/widget/level_select_dialog_test.dart` verifying dialog display and dismissal.

- [x] **TASK-001-14**: Implement `HomeScreen` with resilient navigation debounce guard
  - **Traces**: `REQ-001-03`, `REQ-001-04`, `EC-04`, `EC-05`, `AC-02`, `AC-03`, Single Version Truth
  - **Details**:
    - Create `lib/src/features/home/presentation/widgets/game_title.dart` with stylized embossed title and `ScrewAccent` details.
    - Create `lib/src/features/home/presentation/home_screen.dart`:
      - Header with Settings icon button and `AppConfig.appVersion`.
      - Center hero `GameTitle`.
      - Primary CTA "Play" button navigating to `GameplayPlaceholderScreen` with `try/finally` debounce guard (`_isNavigating`).
      - Secondary CTA "Levels" button opening `LevelSelectDialog`.
      - Scrollable container to prevent small-screen overflow (`EC-04`).
  - **Verification**: Write `test/widget/home_screen_test.dart` verifying all elements render, buttons trigger appropriate modals/navigation, and version text matches `AppConfig.appVersion`.

---

## Phase 5: App Integration & Bootstrap (Testable Dependency Injection)

- [x] **TASK-001-15**: Implement `ScrewEscapeApp` with dependency injection and update `lib/main.dart`
  - **Traces**: `REQ-001-01`, `REQ-001-06`, `AC-01`, `NFR-001-01`, `NFR-001-04`
  - **Details**:
    - Create `lib/src/app.dart` defining `ScrewEscapeApp` configured with theme and `HomeScreen`.
    - Structure app initialization so `ScrewEscapeApp` accepts an injectable `SettingsController` parameter. This allows widget and integration tests to provide a controlled `SettingsController` backed by `InMemoryPreferencesRepository` without platform channel dependencies.
    - Update `lib/main.dart`:
      - Enforce `SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])`.
      - Instantiate production `SharedPreferencesRepository` and `SettingsController`.
      - Kick off `settingsController.loadSettings()`.
      - Mount `ScrewEscapeApp(settingsController: settingsController)`.
  - **Verification**: Write `test/widget/app_smoke_test.dart` injecting a test controller and verifying clean app startup.

---

## Phase 6: Regression & Acceptance Verification

- [x] **TASK-001-16**: Navigation flow & debounce regression widget tests
  - **Traces**: `REQ-001-03`, `REQ-001-04`, `EC-05`, `AC-03`, `AC-04`
  - **Details**:
    - Create `test/widget/play_navigation_test.dart`:
      1. Tapping Play pushes `GameplayPlaceholderScreen`.
      2. Rapid double-tapping Play does NOT push duplicate routes.
      3. Tapping Back pops to `HomeScreen` and clears `_isNavigating`, allowing subsequent taps.
  - **Verification**: Run `flutter test test/widget/play_navigation_test.dart` — 100% pass.

- [x] **TASK-001-17**: Multi-viewport responsiveness tests
  - **Traces**: `NFR-001-03`, `EC-04`, `AC-09`
  - **Details**:
    - Create `test/widget/responsive_layout_test.dart`:
      - Test `HomeScreen` across viewports: Compact (320x568), Standard (390x844), Tall (412x915), and Tablet (800x1280).
      - Assert zero `RenderFlex` overflow exceptions thrown.
  - **Verification**: Run `flutter test test/widget/responsive_layout_test.dart` — 100% pass.

- [x] **TASK-001-18**: Acceptance criteria verification and code health audit
  - **Traces**: All `AC-01` through `AC-10`
  - **Details**:
    - Run full test suite: `flutter test`.
    - Run analyzer: `flutter analyze`.
    - Verify all 10 Acceptance Criteria in `specs/001-game-foundation/spec.md` are fulfilled.
  - **Verification**: `flutter test` passes with zero failures; `flutter analyze` reports zero issues/warnings.

---

## Sign-off & Completion
* **Verified By**: Automated SDD Suite & Pair Programming Audit
* **Date**: 2026-11-03
* **Status**: Complete & Verified (100%)
* **Revision Notes**:
  * Revision 1: Specified resolving latest compatible stable version for `shared_preferences` without upgrading unrelated dependencies (TASK-001-01), propagated write failures in `SharedPreferencesRepository` to `SettingsController` to avoid double-swallowing (TASK-001-05), and structured `ScrewEscapeApp` dependency injection for fully isolated widget testing without platform channels (TASK-001-15).
