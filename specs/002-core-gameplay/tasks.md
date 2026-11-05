# Implementation Tasks: Core Gameplay

* **Feature ID**: `SPEC-002`
* **Feature Name**: Core Gameplay (Interactive Screw Puzzle, 3-Slot Holding Tray, Board Falling Physics, Solvable Level 1, Hint & Undo)
* **Spec Reference**: `specs/002-core-gameplay/spec.md`
* **Plan Reference**: `specs/002-core-gameplay/plan.md`
* **Status**: `Pending Final Approval (Tasks Phase Revision 1)`

> **SDD Rule**: No implementation task may begin until the task list is reviewed and approved. Each task must be independently verifiable with automated tests or concrete validation checks before marking as complete.

---

## Phase 1: Domain Entities & Game State Logic (Pure Dart TDD)

- [x] **TASK-002-01**: Implement controlled mutable domain models (`BoardStatus`, `GameStatus`, `ScrewState`, `WoodenBoardState`) with deep-copy isolation
  - **Dependencies**: None
  - **Traces**: `REQ-002-01`, `REQ-002-03`, `AC-002-01`, `AC-002-03`, `NFR-002-02`, Plan §3.1
  - **TDD Steps**:
    1. **Red**: Create `test/unit/gameplay/domain_models_test.dart` asserting enum values for `BoardStatus` (`pinned`, `falling`, `cleared`) and `GameStatus` (`playing`, `won`, `lost`). Assert `ScrewState` initialization, `isInTray`, and `clone()` value equivalence. Assert `WoodenBoardState` initialization, `containsPoint`, and deep-copy isolation (mutating cloned board's `attachedScrewIds` set or screw's `traySlot` does not affect original). Confirm tests fail (`flutter test test/unit/gameplay/domain_models_test.dart`).
    2. **Green**: Implement:
       - `lib/src/features/gameplay/domain/models/board_status.dart`
       - `lib/src/features/gameplay/domain/models/game_status.dart`
       - `lib/src/features/gameplay/domain/models/screw_state.dart` with `clone()`
       - `lib/src/features/gameplay/domain/models/wooden_board_state.dart` with `clone()` producing fresh `Set<String>.from(attachedScrewIds)`
       - Zero Flutter UI imports (pure headless Dart).
    3. **Refactor & Verify**: Run `flutter test test/unit/gameplay/domain_models_test.dart` and confirm 100% pass.

- [x] **TASK-002-02**: Implement `GameStateSnapshot` and `MoveResult` models
  - **Dependencies**: `TASK-002-01`
  - **Traces**: `REQ-002-09`, `AC-002-08`, `NFR-002-02`, Plan §3.1
  - **TDD Steps**:
    1. **Red**: Create `test/unit/gameplay/game_state_snapshot_test.dart` asserting `GameStateSnapshot` deep copies `boards`, `screws`, and `traySlots`. Assert that `snapshot.clone()` produces independent copies with zero shared mutable collections or entity references. Assert `MoveResult` fields (`screwId`, `traySlot`, `boardDropped`, `droppedBoardId`, `clearedScrewIds`). Confirm tests fail.
    2. **Green**: Implement:
       - `lib/src/features/gameplay/domain/models/game_state_snapshot.dart` with deep-copy constructor and `clone()`
       - `lib/src/features/gameplay/domain/models/move_result.dart`
    3. **Refactor & Verify**: Run `flutter test test/unit/gameplay/game_state_snapshot_test.dart` and confirm 100% pass.

- [x] **TASK-002-03**: Implement dynamic pure geometric screw accessibility in `GameState`
  - **Dependencies**: `TASK-002-01`
  - **Traces**: `REQ-002-01`, `EC-002-05`, `NFR-002-02`, Plan §3.2
  - **TDD Steps**:
    1. **Red**: Create `test/unit/gameplay/game_state_accessibility_test.dart` testing:
       - In-tray screw (`traySlot != null`) returns `false`.
       - Non-pinned board screw returns `false`.
       - Covered screw (higher `zIndex` pinned board contains screw coordinate) returns `false`.
       - Uncovered screw returns `true`.
       - Top-layer board screw (highest `zIndex`) returns `true` unconditionally while pinned.
       - Confirm tests fail.
    2. **Green**: Implement `GameState.isScrewAccessible(String screwId)` in `lib/src/features/gameplay/domain/models/game_state.dart`. Zero mutable or cached boolean accessibility flags.
    3. **Refactor & Verify**: Run `flutter test test/unit/gameplay/game_state_accessibility_test.dart` and confirm 100% pass.

- [x] **TASK-002-04**: Implement authoritative state transitions with terminal-state precedence (`applyMove`, `finalizeBoardClear`, `evaluateLoseCondition`, `undo`, `clone`)
  - **Dependencies**: `TASK-002-02`, `TASK-002-03`
  - **Traces**: `REQ-002-01`, `REQ-002-02`, `REQ-002-04`, `REQ-002-05`, `REQ-002-06`, `REQ-002-07`, `REQ-002-08`, `REQ-002-09`, `EC-002-02`, `EC-002-04`, `AC-002-02`, `AC-002-04`, `AC-002-05`, `AC-002-06`, `AC-002-07`, `AC-002-08`, Plan §3.3
  - **TDD Steps**:
    1. **Red**: Create `test/unit/gameplay/game_state_test.dart` asserting:
       - `applyMove` moves screw to lowest empty tray slot, removes it from board attached set, and marks board `falling` if empty.
       - `applyMove` rejects inaccessible screws or full tray.
       - `finalizeBoardClear` marks board `cleared`, ejects board's screws from tray, and sets `status = GameStatus.won` when all boards cleared.
       - **Terminal-State Precedence**: Win condition unconditionally supersedes lose condition. When the last board is cleared, `status` becomes `won` and subsequent `evaluateLoseCondition()` does NOT alter status to `lost`.
       - `evaluateLoseCondition` transitions to `lost` only when `status == GameStatus.playing`, tray is full, and no board has 0 attached screws.
       - `undo` pops snapshot and restores exact pre-move board, screw, tray, and accessibility state.
       - `clone` deep-clones state, collections, and all snapshots in `history` (`history.map((s) => s.clone()).toList()`).
       - Confirm tests fail.
    2. **Green**: Implement authoritative state methods in `lib/src/features/gameplay/domain/models/game_state.dart`.
    3. **Refactor & Verify**: Run `flutter test test/unit/gameplay/game_state_test.dart` and confirm 100% pass.

---

## Phase 2: Declarative Level 1 & BFS Solver

- [x] **TASK-002-05** [P]: Implement declarative Level 1 layout data
  - **Dependencies**: `TASK-002-01`, `TASK-002-04`
  - **Traces**: `REQ-002-12`, `AC-002-01`, Plan §7
  - **TDD Steps**:
    1. **Red**: Create `test/unit/gameplay/level_1_data_test.dart` asserting exact geometries:
       - Canvas: $360 \times 500\,\text{dp}$.
       - Board 1 (Oak, `zIndex: 0`, bounds `Rect.fromLTWH(40, 310, 280, 50)`): `screw_1a(75, 335)`, `screw_1b(180, 335)`.
       - Board 2 (Walnut, `zIndex: 1`, bounds `Rect.fromLTWH(40, 210, 280, 50)`): `screw_2a(75, 235)`, `screw_2b(180, 235)`.
       - Board 3 (Teak, `zIndex: 2`, bounds `Rect.fromLTWH(150, 140, 60, 260)`): `screw_3a(180, 170)`, `screw_3b(180, 375)`.
       - Tray: 3 empty slots (`[null, null, null]`).
       - Initial accessibility: screws 3a, 3b, 2a, 1a accessible; 2b, 1b covered.
       - Confirm tests fail.
    2. **Green**: Implement `lib/src/features/gameplay/domain/levels/level_1_data.dart` defining factory method `Level1Data.create()`.
    3. **Refactor & Verify**: Run `flutter test test/unit/gameplay/level_1_data_test.dart` and confirm 100% pass.

- [x] **TASK-002-06** [P]: Implement canonical BFS state key and `PuzzleSolver`
  - **Dependencies**: `TASK-002-04`
  - **Traces**: `REQ-002-10`, `REQ-002-13`, `NFR-002-02`, Plan §3.4, §4.1
  - **TDD Steps**:
    1. **Red**: Create `test/unit/gameplay/puzzle_solver_test.dart` asserting:
       - `canonicalStateKey` format: `B:$bParts#S:$sParts#T:$tParts#G:$gPart` with sorted keys.
       - Identical states with different map/set insertion orders produce the identical string key.
       - Solver explores graph and finds winning paths without infinite loops or state aliasing.
       - Confirm tests fail.
    2. **Green**: Implement `lib/src/features/gameplay/domain/solver/puzzle_solver.dart` with `canonicalStateKey`, `SolverResult`, and pure Dart BFS `PuzzleSolver.solve(GameState initial)` using authoritative domain transitions.
    3. **Refactor & Verify**: Run `flutter test test/unit/gameplay/puzzle_solver_test.dart` and confirm 100% pass.

- [x] **TASK-002-07**: Implement Level 1 solvability verification and performance benchmark telemetry test
  - **Dependencies**: `TASK-002-05`, `TASK-002-06`
  - **Traces**: `REQ-002-13`, `AC-002-11`, Plan §4.2, §7
  - **TDD Steps**:
    1. **Red**: Update/create `test/unit/gameplay/level_solvability_test.dart` to assert:
       - Mandatory correctness: `result.isSolvable == true`.
       - Mandatory shortest path length: `result.shortestPath.length == 6`.
       - Canonical sequence: `['screw_3a', 'screw_3b', 'screw_2a', 'screw_2b', 'screw_1a', 'screw_1b']` leads to `GameStatus.won`.
       - Deadlock trap: `['screw_1a', 'screw_2a', 'screw_3a']` reaches `GameStatus.lost`.
       - **Benchmark Target Telemetry**: Measure BFS elapsed time using `Stopwatch`. Log measured elapsed time and execution environment (`print('Level 1 BFS: ${stopwatch.elapsedMilliseconds}ms across ${result.statesVisited} states on ${Platform.operatingSystem}')`). Treat `< 5 ms` as a measured benchmark target for health monitoring, keeping solvability assertions mandatory.
       - Confirm tests fail if solver logic is unlinked.
    2. **Green**: Hook solver to `Level1Data.create()` and verify all solvability proofs hold.
    3. **Refactor & Verify**: Run `flutter test test/unit/gameplay/level_solvability_test.dart` and confirm 100% pass.

---

## Phase 3: Gameplay Controller & Animation Pipeline (Application Layer)

- [x] **TASK-002-08**: Implement `GameplayController` state management and strict input locking lifecycle
  - **Dependencies**: `TASK-002-04`, `TASK-002-05`
  - **Traces**: `REQ-002-01`, `EC-002-01`, `NFR-002-01`, Plan §5.2
  - **TDD Steps**:
    1. **Red**: Create `test/unit/gameplay/gameplay_controller_test.dart` asserting:
       - `GameplayController` initializes with `Level1Data.create()` and `isInputLocked == false`.
       - Tapping a valid screw immediately engages `isInputLocked = true` and notifies listeners on the initial frame.
       - Subsequent taps while locked are completely discarded.
       - Tapping when tray is full rejects input.
       - Confirm tests fail.
    2. **Green**: Implement `lib/src/features/gameplay/application/gameplay_controller.dart` as a `ChangeNotifier` with state and input locking.
    3. **Refactor & Verify**: Run `flutter test test/unit/gameplay/gameplay_controller_test.dart` and confirm 100% pass.

- [x] **TASK-002-09**: Implement sequential animation pipeline and settlement event orchestration
  - **Dependencies**: `TASK-002-08`
  - **Traces**: `REQ-002-02`, `REQ-002-05`, `REQ-002-06`, `REQ-002-07`, `REQ-002-08`, `REQ-002-15`, `AC-002-02`, `AC-002-04`, `AC-002-05`, `AC-002-06`, `AC-002-07`, Plan §5.1, §5.2, §5.3
  - **TDD Steps**:
    1. **Red**: Create `test/unit/gameplay/gameplay_animation_pipeline_test.dart` asserting sequential lifecycle:
       - Screw translation phase ($250\,\text{ms}$, `Curves.easeInOutCubic`) updates `GameState`.
       - Board drop phase ($400\,\text{ms}$, `Curves.easeInQuad` with $+8^\circ$ tilt) triggers only if `boardDropped == true`.
       - Board clear finalize: ejects screws from tray ($150\,\text{ms}$ shrink & fade).
       - Terminal resolution with $100\,\text{ms}$ settlement buffer: triggers win event if won, lose event if lost, or unlocks input if playing.
       - Confirm tests fail.
    2. **Green**: Implement sequential async pipeline in `GameplayController`.
    3. **Refactor & Verify**: Run `flutter test test/unit/gameplay/gameplay_animation_pipeline_test.dart` and confirm 100% pass.

- [x] **TASK-002-10**: Implement Undo, Hint (with safe timer lifecycle), and Restart operations
  - **Dependencies**: `TASK-002-06`, `TASK-002-09`
  - **Traces**: `REQ-002-09`, `REQ-002-10`, `REQ-002-11`, `EC-002-03`, `EC-002-04`, `AC-002-08`, `AC-002-09`, `AC-002-10`, Plan §3.3, §6.5
  - **TDD Steps**:
    1. **Red**: Create `test/unit/gameplay/gameplay_controller_controls_test.dart` asserting:
       - `undo()` rolls back snapshot, clears hint halo, cancels active hint timer, and notifies listeners. Disabled if locked or history empty.
       - `requestHint()` executes BFS solver read-only: highlights first winning screw for 3.0s, or triggers deadlock toast event if unsolvable.
       - **Hint Timer Lifecycle Safety**: Requesting a new hint cancels previous timer. Calling `undo()` or `restartLevel()` cancels active timer. Calling `dispose()` disposes timer safely (`_isDisposed = true; _hintTimer?.cancel();`). Stale timer callbacks never mutate controller state.
       - `restartLevel()` cancels timer, resets to pristine Level 1, clears history, and notifies listeners.
       - Confirm tests fail.
    2. **Green**: Implement `undo()`, `requestHint()`, `restartLevel()`, and `dispose()` with `_hintTimer` safety in `GameplayController`.
    3. **Refactor & Verify**: Run `flutter test test/unit/gameplay/gameplay_controller_controls_test.dart` and confirm 100% pass.

---

## Phase 4: Presentation Components (Flutter Widgets & CustomPainters)

- [x] **TASK-002-11** [P]: Implement `HoldingTrayWidget` with recessed metallic sockets
  - **Dependencies**: `TASK-002-01`
  - **Traces**: `REQ-002-04`, `REQ-002-06`, `REQ-002-14`, `AC-002-02`, `AC-002-05`, Plan §6.4
  - **TDD Steps**:
    1. **Red**: Create `test/widget/gameplay/holding_tray_widget_test.dart` asserting:
       - Renders fixed 3 horizontal sockets inside wooden tray.
       - Sockets render empty recessed bevel when vacant.
       - Sockets render docked `ScrewAccent` brass heads when occupied.
       - Ejection triggers scale ($1.0 \to 0.0$) and fade ($1.0 \to 0.0$) transition over $150\,\text{ms}$.
       - Confirm tests fail.
    2. **Green**: Implement `lib/src/features/gameplay/presentation/widgets/holding_tray_widget.dart` using native Flutter containers, gradients, and `ScrewAccent`.
    3. **Refactor & Verify**: Run `flutter test test/widget/gameplay/holding_tray_widget_test.dart` and confirm 100% pass.

- [x] **TASK-002-12** [P]: Implement `WoodenBoardWidget` with gravity drop and tilt animation
  - **Dependencies**: `TASK-002-01`
  - **Traces**: `REQ-002-05`, `REQ-002-14`, `REQ-002-15`, `AC-002-04`, Plan §6.2
  - **TDD Steps**:
    1. **Red**: Create `test/widget/gameplay/wooden_board_widget_test.dart` asserting:
       - Renders board plank using `WoodSurface` with chamfered borders.
       - Correct dimensions based on `WoodenBoardState`.
       - When falling, animates vertical translation ($Y \to Y + 600\,\text{dp}$) and rotation ($+8^\circ$) over $400\,\text{ms}$ with `Curves.easeInQuad`.
       - Confirm tests fail.
    2. **Green**: Implement `lib/src/features/gameplay/presentation/widgets/wooden_board_widget.dart`.
    3. **Refactor & Verify**: Run `flutter test test/widget/gameplay/wooden_board_widget_test.dart` and confirm 100% pass.

- [x] **TASK-002-13** [P]: Implement `InteractiveScrewWidget` with touch target and travel animation
  - **Dependencies**: `TASK-002-01`
  - **Traces**: `REQ-002-02`, `REQ-002-14`, `REQ-002-15`, `AC-002-02`, Plan §6.3
  - **TDD Steps**:
    1. **Red**: Create `test/widget/gameplay/interactive_screw_widget_test.dart` asserting:
       - Renders brass head via `ScrewAccent`.
       - Minimum touch target size is $48 \times 48\,\text{dp}$ ($R = 24\,\text{dp}`).
       - Tapping triggers `onTap` callback with screw ID.
       - Movement animation translates screw towards target offset over $250\,\text{ms}$ with `Curves.easeInOutCubic`.
       - Tapping while disabled triggers no callback.
       - Confirm tests fail.
    2. **Green**: Implement `lib/src/features/gameplay/presentation/widgets/interactive_screw_widget.dart`.
    3. **Refactor & Verify**: Run `flutter test test/widget/gameplay/interactive_screw_widget_test.dart` and confirm 100% pass.

- [x] **TASK-002-14** [P]: Implement `HintHighlightWidget` with pulsating golden halo
  - **Dependencies**: None
  - **Traces**: `REQ-002-10`, `REQ-002-14`, `AC-002-09`, Plan §6.5
  - **TDD Steps**:
    1. **Red**: Create `test/widget/gameplay/hint_highlight_widget_test.dart` asserting:
       - Renders circular halo with `AppColors.metalGoldLight` / `0xFFFFD700`.
       - Drives looping scale ($1.0\times$ to $1.25\times$) and opacity ($0.6$ to $1.0$) with `Curves.easeInOut`.
       - Auto-dismisses or disposes cleanly when active for 3.0s.
       - Confirm tests fail.
    2. **Green**: Implement `lib/src/features/gameplay/presentation/widgets/hint_highlight_widget.dart`.
    3. **Refactor & Verify**: Run `flutter test test/widget/gameplay/hint_highlight_widget_test.dart` and confirm 100% pass.

- [x] **TASK-002-15**: Implement responsive `PuzzleCanvas` with inverse touch coordinate mapping
  - **Dependencies**: `TASK-002-04`, `TASK-002-11`, `TASK-002-12`, `TASK-002-13`, `TASK-002-14`
  - **Traces**: `REQ-002-01`, `REQ-002-14`, `NFR-002-04`, `AC-002-01`, `AC-002-02`, Plan §6.1
  - **TDD Steps**:
    1. **Red**: Create `test/widget/gameplay/puzzle_canvas_test.dart` asserting:
       - Normalizes to $360 \times 500\,\text{dp}$ canvas within `LayoutBuilder`.
       - Computes uniform scale $S$ and centering offsets $dx, dy$.
       - Maps screen coordinates via inverse transform: $P_{\text{logical}} = ((x_{\text{screen}} - dx) / S, (y_{\text{screen}} - dy) / S)$.
       - Taps outside canvas bounds $[0, 360] \times [0, 500]$ are discarded.
       - Top-down candidate selection: taps resolve candidate screws within radius $24\,\text{dp}$ by highest `zIndex`.
       - Tapping covered screws produces no move.
       - Renders boards stacked by `zIndex`, screws, and active `HintHighlightWidget`.
       - Confirm tests fail.
    2. **Green**: Implement `lib/src/features/gameplay/presentation/widgets/puzzle_canvas.dart`.
    3. **Refactor & Verify**: Run `flutter test test/widget/gameplay/puzzle_canvas_test.dart` and confirm 100% pass.

---

## Phase 5: Screens, Modals & Navigation Integration

- [x] **TASK-002-16** [P]: Implement `GameHud` top bar and bottom action bar
  - **Dependencies**: None
  - **Traces**: `REQ-002-09`, `REQ-002-10`, `REQ-002-11`, `AC-002-01`, `AC-002-08`, `AC-002-09`, `AC-002-10`, Plan §2
  - **TDD Steps**:
    1. **Red**: Create `test/widget/gameplay/game_hud_test.dart` asserting:
       - `GameHud`: Back button, "LEVEL 1" title, Restart button. Restart is disabled and dimmed when `isInputLocked == true`.
       - `GameControlsBar`: Undo button, Hint button. Undo is disabled when `isInputLocked` or `history.isEmpty`. Hint is disabled when `isInputLocked`.
       - Confirm tests fail.
    2. **Green**: Implement:
       - `lib/src/features/gameplay/presentation/widgets/game_hud.dart`
       - `lib/src/features/gameplay/presentation/widgets/game_controls_bar.dart`
    3. **Refactor & Verify**: Run `flutter test test/widget/gameplay/game_hud_test.dart` and confirm 100% pass.

- [x] **TASK-002-17** [P]: Implement `LevelWinDialog` and `GameOverDialog` modals
  - **Dependencies**: None
  - **Traces**: `REQ-002-07`, `REQ-002-08`, `AC-002-06`, `AC-002-07`, Plan §5.3
  - **TDD Steps**:
    1. **Red**: Create `test/widget/gameplay/result_dialogs_test.dart` asserting:
       - `LevelWinDialog`: Headline "LEVEL 1 CLEARED!", "Replay Level" and "Main Menu" buttons trigger respective callbacks.
       - `GameOverDialog`: Headline "OUT OF HOLES!", subtext "The holding tray is full.", "Undo Move" and "Retry" buttons trigger callbacks.
       - Styled with `WoodSurface` and tactile metallic buttons.
       - Confirm tests fail.
    2. **Green**: Implement:
       - `lib/src/features/gameplay/presentation/widgets/level_win_dialog.dart`
       - `lib/src/features/gameplay/presentation/widgets/game_over_dialog.dart`
    3. **Refactor & Verify**: Run `flutter test test/widget/gameplay/result_dialogs_test.dart` and confirm 100% pass.

- [x] **TASK-002-18**: Implement `GameplayScreen` layout container and modal mounting
  - **Dependencies**: `TASK-002-10`, `TASK-002-15`, `TASK-002-16`, `TASK-002-17`
  - **Traces**: `REQ-002-01`, `REQ-002-16`, `NFR-002-04`, `AC-002-01`, Plan §2
  - **TDD Steps**:
    1. **Red**: Create `test/widget/gameplay/gameplay_screen_test.dart` asserting:
       - Renders `ResponsiveContainer`, `GameHud`, `HoldingTrayWidget`, `PuzzleCanvas`, and `GameControlsBar`.
       - Listens to `GameplayController` status: mounts `LevelWinDialog` when won, mounts `GameOverDialog` when lost, strictly after settlement.
       - Shows floating non-blocking snackbar toast when deadlock hint notification occurs.
       - Confirm tests fail.
    2. **Green**: Implement `lib/src/features/gameplay/presentation/gameplay_screen.dart`.
    3. **Refactor & Verify**: Run `flutter test test/widget/gameplay/gameplay_screen_test.dart` and confirm 100% pass.

- [x] **TASK-002-19**: Integrate `HomeScreen` Play CTA to navigate to `GameplayScreen`
  - **Dependencies**: `TASK-002-18`
  - **Traces**: `REQ-002-16`, `AC-002-01`, Plan §8
  - **TDD Steps**:
    1. **Red**: Create `test/widget/gameplay/gameplay_navigation_test.dart` asserting:
       - Tapping Play on `HomeScreen` pushes `GameplayScreen` (replacing placeholder).
       - Tapping Back in `GameHud` pops back to `HomeScreen`.
       - Navigation debounce guard prevents rapid double-push.
       - Confirm tests fail.
    2. **Green**: Update `lib/src/features/home/presentation/home_screen.dart` Play CTA route to `GameplayScreen`.
    3. **Refactor & Verify**: Run `flutter test test/widget/gameplay/gameplay_navigation_test.dart` and confirm 100% pass.

---

## Phase 6: Full Regression, Responsiveness & Acceptance Verification

- [x] **TASK-002-20**: Multi-viewport responsive layout and accessibility verification
  - **Dependencies**: `TASK-002-18`
  - **Traces**: `NFR-002-04`, `EC-002-07`, Plan §6.1
  - **TDD Steps**:
    1. **Red**: Create `test/widget/gameplay/responsive_gameplay_test.dart` running layout tests across:
       - Narrow phone: 320dp width
       - Standard phone: 360dp width
       - Large phone: 412dp width
       - Small tablet: 800dp width
       - Large tablet: 1200dp width
       - Assert zero `RenderFlex` overflow errors across all viewports.
       - Assert touch target accuracy across scaled dimensions.
       - Assert portrait orientation lock remains intact.
       - Confirm tests fail if layout overflows.
    2. **Green**: Fix any layout edge cases or padding constraints.
    3. **Refactor & Verify**: Run `flutter test test/widget/gameplay/responsive_gameplay_test.dart` and confirm 100% pass.

- [x] **TASK-002-21**: Comprehensive end-to-end acceptance verification and traceability audit
  - **Dependencies**: `TASK-002-07`, `TASK-002-19`, `TASK-002-20`
  - **Traces**: `AC-002-01` through `AC-002-12`, `REQ-002-01` through `REQ-002-16`
  - **Verification Steps**:
    1. Execute the entire automated test suite:
       ```bash
       flutter test
       ```
       Confirm that **100% of tests pass cleanly** with zero failures. (Note: The estimated test suite count is $\approx 90+$ passing tests based on cumulative unit, widget, and solver test suites; all implemented tests must pass).
    2. Run static analysis:
       ```bash
       flutter analyze
       ```
       Confirm 0 issues found.
    3. Verify all 12 Acceptance Criteria:
       - [x] AC-002-01: Playable Level 1 Launch
       - [x] AC-002-02: Tap-to-Move to First Empty Slot (250ms)
       - [x] AC-002-03: Screw Single Ownership & Board Association
       - [x] AC-002-04: Board Fall Animation (400ms, gravity curve)
       - [x] AC-002-05: Tray Clearing on Fall Complete (150ms)
       - [x] AC-002-06: Animation-Safe Game Over on Deadlock
       - [x] AC-002-07: Animation-Safe Victory on All Boards Cleared
       - [x] AC-002-08: Lossless Snapshot Undo Restoring Exact State
       - [x] AC-002-09: Unified BFS Hint with 3.0s Golden Halo
       - [x] AC-002-10: Level Restart Resetting to Initial State
       - [x] AC-002-11: Solvability Verified by Test (< 5ms target)
       - [x] AC-002-12: Strict Native Visuals & Zero Game Engine

- [x] **TASK-002-22**: Physical Android device verification and tactile inspection
  - **Dependencies**: `TASK-002-21`
  - **Traces**: `NFR-002-01`, `NFR-002-03`, `NFR-002-05`, `NFR-002-06`
  - **Verification Steps**:
    1. Launch the app on a physical Android device or emulator.
    2. Verify 60 FPS animation smoothness across screw travel, board gravity drop, and tray clearing.
    3. Verify tactile responsiveness of screw taps, button presses, and modal transitions.
    4. Confirm 100% offline functionality (airplane mode).
    5. Confirm zero third-party game engine artifacts and zero forced advertisements.
    6. Record manual inspection observations in acceptance report.
