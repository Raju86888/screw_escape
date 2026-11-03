# Feature Specification: Game Foundation

* **Feature ID**: `SPEC-001`
* **Status**: `Approved`
* **Author**: `Development Team`
* **Created**: `2026-11-03`
* **Last Updated**: `2026-11-03`

---

## 1. Overview & Goals

### 1.1 Context
"Screw Escape" is a casual mobile puzzle game for Android where players unscrew pins and fasteners from layered wooden and metallic structures. Before introducing puzzle physics and gameplay mechanics, this feature establishes the application shell, visual design system, home screen, settings modal with persistent sound toggle, a dedicated gameplay placeholder screen, and strict orientation locking.

### 1.2 Goals
* Lock Android app orientation strictly to `portraitUp` only.
* Establish a realistic, tactile visual aesthetic (warm wooden backgrounds, metallic accents, subtle shadows) built exclusively with native Flutter widgets, `CustomPainter`, gradients, and box shadows—without external image assets or third-party UI libraries.
* Implement a polished Home Screen with the game title, prominent "Play" Call-To-Action (CTA), Level Select placeholder, and Settings button.
* Implement a dedicated Gameplay Placeholder screen displaying "Gameplay coming soon" with a Back button returning to the Home Screen.
* Implement a Settings modal with a sound toggle whose preference persists across application restarts using local storage.
* Define a reusable UI component library (`MetallicButton`, `WoodSurface`, `ScrewAccent`) and design tokens (colors, typography, spacing).
* Ensure smooth rendering without noticeable jank and responsive layout across diverse Android viewport dimensions.

### 1.3 Non-Goals (Out of Scope)
* Actual screw puzzle mechanics, physics simulation, or interactive board.
* Level progression backend, cloud saves, or player authentication.
* Advertisements, rewarded videos, or in-app purchases (IAP).
* Daily challenges, achievements, leaderboards, or push notifications.
* Audio asset playback (sound toggle manages boolean state and persistence; actual sound playback will be integrated in a subsequent audio feature).

---

## 2. User Stories & Scenarios

### US-01: PortraitUp Launch & Orientation Lock
* **As a player**, I want the game to open and remain strictly in upright portrait orientation, **so that** the game is comfortable to hold and play with one hand.
  * *Scenario*: Given the app is launched on an Android device held in any orientation, when the app loads, then the screen orientation is locked strictly to `portraitUp`.

### US-02: Tactile Home Screen Experience
* **As a player**, I want to see a premium, warm wooden and metallic home screen, **so that** I immediately experience the craftsmanship and theme of the game.
  * *Scenario*: Given the app launches, when the home screen renders, then the player sees the "Screw Escape" title, textured wooden background, metallic screw/plate accents, and polished interactive buttons rendered cleanly using native Flutter drawing.

### US-03: Play Navigation to Gameplay Placeholder
* **As a player**, I want tapping "Play" to transition to the gameplay screen, **so that** I can begin playing.
  * *Scenario*: Given the home screen is visible, when the player taps the primary "Play" button, then the app navigates to the Gameplay Placeholder screen displaying "Gameplay coming soon" and a "Back" button.

### US-04: Returning Home from Gameplay Placeholder
* **As a player**, I want a clear "Back" button on the gameplay placeholder screen, **so that** I can return to the home screen at any time.
  * *Scenario*: Given the player is on the Gameplay Placeholder screen, when they tap the "Back" button or press the Android system back button, then the app transitions back to the Home Screen.

### US-05: Sound Preference Configuration & Persistence Across Restarts
* **As a player**, I want my sound toggle setting to be saved, **so that** I don't have to reconfigure sound every time I reopen the game.
  * *Scenario*: Given the player toggles sound to Off in the settings modal, when the app is fully terminated and relaunched, then the sound preference remains Off.

### US-06: Level Selection Entry Point
* **As a player**, I want to see a "Levels" button on the home screen, **so that** I can discover level selection in future releases.
  * *Scenario*: Given the player taps "Levels", when triggered, then an informative placeholder dialog appears without crashing.

### US-07: Responsive Layout Across Android Form Factors
* **As a player**, I want the UI to display cleanly on phones of various heights and widths, **so that** components do not clip or overflow.
  * *Scenario*: Given the app runs on screens ranging from compact (320dp width) to tall aspect ratios (20:9, 21:9) and tablets, when displayed, then all buttons and titles fit safely inside view boundaries.

---

## 3. Requirements

### 3.1 Functional Requirements

* **REQ-001-01 (Strict PortraitUp Orientation)**:
  * The application must enforce `DeviceOrientation.portraitUp` exclusively via Flutter's `SystemChrome.setPreferredOrientations`.
  * The Android manifest must set `android:screenOrientation="portrait"` to prevent rotation during cold launch.
* **REQ-001-02 (Design System & Native Visual Tokens)**:
  * Define semantic color tokens:
    * Wood tones: deep oak `#2C1810`, warm teak `#4A2E1B`, light walnut `#7A5230`, board surface `#8B5A2B`.
    * Metallic accents: brass gold `#D4AF37`, brushed silver `#C0C0C0`, dark gunmetal `#2B2D2F`, highlight `#E8E8E8`.
    * Button CTAs: emerald play green `#2E7D32` with beveled highlight, amber gold `#F59E0B`.
  * Define typographic hierarchy (Game Title, Heading, Body, Button Label).
  * Define spacing constants (4dp, 8dp, 16dp, 24dp, 32dp).
  * **Prohibition**: External raster or vector image assets (PNG, JPEG, SVG) and third-party UI component packages are strictly prohibited. All visuals must be rendered using native Flutter widgets, `CustomPainter`, gradients, and box shadows.
* **REQ-001-03 (Home Screen Layout)**:
  * Header area: Settings button (icon button) and version indicator.
  * Hero title area: "Screw Escape" stylized title with metallic screw head accents and drop shadows.
  * Action area:
    * Primary CTA: Prominent, elevated "Play" button with beveled edges and press feedback.
    * Secondary CTA: "Levels" button for the level select entry point.
* **REQ-001-04 (Gameplay Placeholder Screen)**:
  * Navigated to when the user taps "Play".
  * Must display the text `"Gameplay coming soon"`.
  * Must provide a visible, accessible "Back" button (or app bar navigation) that navigates back to the Home Screen.
  * Must handle Android system back navigation (predictive/system back gesture) gracefully returning to the Home Screen.
* **REQ-001-05 (Settings Dialog & Modal)**:
  * Triggered by tapping the Settings button on the Home Screen.
  * Rendered as an elevated modal dialog styled with a wooden/metallic frame.
  * Displays a Sound Toggle switch/button reflecting current state (`On` / `Off`).
  * Displays app version (e.g., `v1.0.0`).
  * Includes a Close button (`X` icon or tap outside modal) that dismisses the dialog.
* **REQ-001-06 (Persistent Sound Preference via Local Storage)**:
  * Sound state (`soundEnabled: bool`, default: `true`) must persist across application restarts.
  * Persistence must use local storage. Built-in Flutter/Dart capabilities (e.g., standard file-based storage via `dart:io` or lightweight key-value persistence) must be evaluated first before considering external dependencies.
  * Persistence logic must be encapsulated behind an abstract storage interface (e.g., `PreferencesRepository` or `SettingsService`) to decouple business logic from storage implementation.
* **REQ-001-07 (Level Selection Entry Point)**:
  * Tapping "Levels" displays an informative placeholder dialog (e.g., "Level selection coming soon") that can be dismissed cleanly.
* **REQ-001-08 (Reusable UI Components)**:
  * `MetallicButton`: Tactile button widget supporting primary (Play) and secondary (Levels/Back) variants with bevel, shadow, and pressed state translation.
  * `WoodSurface`: Background container rendering layered wood-grain gradients and border shadows via native Flutter painting.
  * `ScrewAccent`: Decorative metallic screw-head widget with realistic radial highlights and slot/Phillips grooves.

### 3.2 Non-Functional Requirements

* **NFR-001-01 (Smooth Performance & No Jank)**:
  * The home screen, gameplay placeholder screen, and settings dialog must render smoothly without noticeable jank, stutter, or dropped frames during animations and screen transitions on baseline Android devices (Android 8.0+ / API 26+).
* **NFR-001-02 (Native Rendering Only)**:
  * Zero external image files (PNG/JPG/SVG) and zero third-party UI component packages. All visuals must be implemented using standard Flutter painting primitives (`Canvas`, `Paint`, `Path`, `BoxDecoration`, `LinearGradient`, `BoxShadow`).
* **NFR-001-03 (Responsive Layout & Safe Areas)**:
  * Screens must be wrapped in `SafeArea` and responsive containers (e.g., `LayoutBuilder`, `SingleChildScrollView`) to prevent `RenderFlex` overflow errors on small screens (minimum width: 320dp) while constraining max width on tablets (up to 1200dp).
* **NFR-001-04 (Testing Architecture)**:
  * **Pure Dart Unit Tests**: Core business logic (sound settings controller, persistence repository interface, default fallback behavior) must be unit-testable in pure Dart without Flutter engine dependencies.
  * **Widget Tests**: All Flutter UI components (Home screen, Gameplay placeholder screen, Settings dialog, `MetallicButton`, `WoodSurface`, `ScrewAccent`) must be validated using Flutter widget tests.
  * **Constraint**: 100% headless testability across all application state is not required; widget-level testing is expected for presentation and navigation.
* **NFR-001-05 (Touch Responsiveness)**:
  * Tapping buttons must provide immediate visual feedback (e.g., scale depression or downward translation) within 1 frame (< 16ms).

---

## 4. Visual Direction & Screen Layouts

### Home Screen
```text
+-------------------------------------------------------+
|  [ (S) Settings ]                       v1.0.0        |
|                                                       |
|                     (O)   (O)                         |
|                 SCREW  ESCAPE                         |
|                     (O)   (O)                         |
|                                                       |
|              [  === PLAY NOW ===  ]                   |
|                                                       |
|              [    === LEVELS ===  ]                   |
|                                                       |
|         [Wood Planks / Screws Background]             |
+-------------------------------------------------------+
```

### Gameplay Placeholder Screen
```text
+-------------------------------------------------------+
|  [ <- Back ]                                          |
|                                                       |
|                                                       |
|               Gameplay coming soon                    |
|                                                       |
|            [ Tactical Game Board Area ]               |
|                                                       |
+-------------------------------------------------------+
```

---

## 5. Edge Cases & Failure Modes

* **EC-01 (Device Orientation Change Attempt)**: When the physical device is turned to landscape or reverse portrait, the app must remain strictly in `portraitUp` without rotating or re-rendering into landscape.
* **EC-02 (App Process Death & Restart)**: When the app is terminated by the OS or user and reopened, the sound preference must load the previously saved value instead of reverting to default.
* **EC-03 (Corrupted or Missing Storage File)**: If local storage is missing, unreadable, or corrupted, the system must fall back gracefully to default (`soundEnabled = true`) without crashing or blocking the UI.
* **EC-04 (Compact Viewports)**: On small Android screens (< 600dp vertical height or < 360dp width), the home screen must allow vertical scrolling if needed to prevent `RenderFlex overflowed by XX pixels`.
* **EC-05 (Rapid Repeated Taps on Navigation)**: Rapidly double-tapping "Play" must not push multiple instances of the Gameplay Placeholder onto the navigation stack.
* **EC-06 (Large Text / Accessibility Font Scale)**: With Android font scaling enabled (up to 1.5x), button labels and titles must not clip or cause layout exceptions.

---

## 6. Assumptions & Constraints

1. **Target Platform**: Android (API 26+) using Flutter SDK with Dart 3.13+.
2. **Strict Native Visuals**: No external image files (`.png`, `.jpg`, `.svg`) and no third-party UI libraries. All visual presentation is powered by Flutter's built-in vector, canvas, and layout system.
3. **Audio Scope**: No audio asset playback (`.mp3` / `.wav`) is executed in Feature 001. The feature manages logical preference state and persistence only.
4. **Local Persistence**: Preference storage must evaluate Flutter/Dart standard capabilities first before considering any external packages.
5. **Orientation**: Locked exclusively to `portraitUp`.

---

## 7. Acceptance Criteria

- [ ] **AC-01 (Strict PortraitUp Lock)**: The app launches and stays locked strictly in `portraitUp` orientation when rotated on an Android device or emulator. (Traces: `REQ-001-01`, `EC-01`)
- [ ] **AC-02 (Native Visual Styling)**: The home screen displays warm wooden surfaces, metallic screw accents, and beveled buttons rendered strictly using native Flutter widgets and `CustomPainter` with zero external image assets. (Traces: `REQ-001-02`, `NFR-001-02`)
- [ ] **AC-03 (Play Button Navigation)**: Tapping the "Play" button navigates to the Gameplay Placeholder screen. (Traces: `REQ-001-03`, `REQ-001-04`)
- [ ] **AC-04 (Gameplay Placeholder & Back Navigation)**: The Gameplay Placeholder screen displays "Gameplay coming soon" and tapping its "Back" button (or Android system back) returns the user to the Home Screen. (Traces: `REQ-001-04`, `EC-05`)
- [ ] **AC-05 (Sound Preference Persistence Across Restarts)**: Changing the sound toggle setting in the settings dialog persists the choice locally; restarting the app preserves and loads the updated preference. (Traces: `REQ-001-05`, `REQ-001-06`, `EC-02`)
- [ ] **AC-06 (Settings Dialog & Toggle UI)**: Tapping the Settings button opens a modal dialog styled with the wooden/metallic theme, displaying a functioning Sound Toggle, version text, and a working dismiss/close button. (Traces: `REQ-001-05`)
- [ ] **AC-07 (Level Select Placeholder)**: Tapping "Levels" displays an informative placeholder dialog that dismisses cleanly without errors. (Traces: `REQ-001-07`)
- [ ] **AC-08 (Smooth Performance)**: The home screen, modal dialog, and placeholder screen transitions render smoothly without noticeable jank on baseline Android devices. (Traces: `NFR-001-01`)
- [ ] **AC-09 (Responsive Layout)**: Screens render without `RenderFlex` overflow errors across small (320x568), standard (390x844), tall (412x915), and tablet viewports. (Traces: `NFR-001-03`, `EC-04`)
- [ ] **AC-10 (Automated Test Verification)**:
  - Unit tests verify pure Dart business logic (sound settings controller, persistence repository, fallback handling).
  - Widget tests verify Home screen rendering, Play button navigation, Gameplay Placeholder screen display, Back button navigation, and Settings dialog sound toggle interaction. (Traces: `NFR-001-04`)

---

## 8. Sign-off & Approvals

* **Reviewed By**: Project Lead
* **Approval Date**: 2026-11-03
* **Approval Status**: Approved (Revision 1)
* **Revision Notes**:
  * Revision 1: Incorporated persistence requirement for sound preferences, added Gameplay Placeholder screen with Back navigation, constrained orientation strictly to `portraitUp`, clarified unit/widget testing architecture, replaced strict 60 FPS metric with smooth rendering without noticeable jank, explicitly prohibited external images and third-party UI libraries, and ensured all ACs are objectively verifiable.
