# Feature Specification: Core Gameplay

* **Feature ID**: `SPEC-002`
* **Feature Name**: Core Gameplay (Interactive Screw Puzzle, 3-Slot Holding Tray, Board Falling Physics, Solvable Level 1, Hint & Undo)
* **Status**: `Approved (Revision 3 - Final Specification Refinement)`
* **Author**: `Development Team`
* **Created**: `2026-11-03`
* **Last Updated**: `2026-11-03`

---

## 1. Overview & Goals

### 1.1 Context
"Screw Escape" is a tactile, casual mobile puzzle game for Android. In Feature 001, we established the application shell, visual design system (warm wood surfaces, metallic screws, beveled buttons), persistent settings, and placeholder screens. 

Feature 002 introduces the **Core Gameplay Engine**: an interactive mechanical puzzle where players unscrew pins from layered wooden boards to let them drop. The puzzle is governed by a **3-slot holding tray**, requiring strategic screw-removal order. This deliverable focuses on a polished, relaxing, and fair experience featuring **one completely playable, verified solvable level (Level 1)**, accompanied by **Hint** and **Undo** capabilities.

### 1.2 Goals
1. Deliver a fully playable, responsive, and tactile interactive puzzle board on Android in portrait orientation (`DeviceOrientation.portraitUp`).
2. Implement the **Confirmed 3-Slot Tray Mechanics**:
   - Tapping an accessible screw moves it automatically into the lowest-index empty tray slot (0, 1, or 2).
   - The holding tray capacity is strictly 3 slots.
   - Every screw belongs to exactly one wooden board.
   - Screws remain in the tray while their parent board is still pinned by other screws.
   - When all screws attached to a board have been moved to the tray, that board unlocks and animates falling off the screen.
   - When the board finishes falling, all screws associated with that board are cleared from the tray, freeing those slots for subsequent moves.
3. **Pure Geometric Screw Accessibility**:
   - Accessibility is derived dynamically as a pure function of board geometry, active pinned status, and z-order (`isScrewAccessible(screw, state)`). No manually assigned or cached boolean flags that can become stale.
4. **Deterministic Lossless Snapshot Undo**:
   - Each accepted move records an immutable, complete `GameStateSnapshot` of the pre-move state. Tapping "Undo" deterministically restores the exact previous logical state (tray occupancy, board statuses, screw positions, and accessibility) without fragile partial reconstruction.
5. **Unified Pure Dart BFS Solver & Solvability Proof**:
   - The BFS puzzle solver operates directly against the exact same authoritative state transition method (`GameState.applyMove`) used during live gameplay, eliminating discrepancy risks.
   - Level 1's layout is mathematically and executably verified to be solvable in 6 moves.
6. **Animation-Safe State Transitions**:
   - Win and lose conditions are evaluated and resolved **strictly after all screw movement, board falling, and tray clearing animations have completed**. Dialogs never interrupt active animations.
7. Maintain pure Flutter standard rendering (Canvas, `CustomPainter`, `AnimationController`) with **zero external image files**, **zero Flame engine dependencies**, and **zero forced ads**.

### 1.3 Non-Goals (Out of Scope for Feature 002)
* Multi-level progression campaigns (Level 2 through 50+ are reserved for a subsequent level pack feature).
* Audio playback / sound effects (sound toggle persistence is already implemented; audio asset integration is a separate dedicated feature).
* Timers, countdown pressure, or move-counter energy limits (the core game is relaxing and untimed).
* Advertisements (rewarded, interstitial, or banners), in-app purchases, or coin economy.
* Online leaderboards, cloud saves, multiplayer, or user accounts.
* Advanced complex physics simulations (rigid-body ragdoll collisions, friction solvers); board falling is rendered using realistic gravity-curve keyframe animations.

---

## 2. User Stories & Scenarios

### US-01: Intuitive Screw Removal & Tray Management
* **As a player**, I want to tap an accessible screw and have it unscrew and move into the first available tray slot, **so that** I can free the wooden boards holding the puzzle together.
  * *Scenario*: Given an accessible screw on a wooden board and at least one empty tray slot, when the player taps the screw, then the screw unscrews with a tactile visual depression and smoothly travels into the lowest-index empty tray slot.

### US-02: Board Drop & Tray Slot Recovery
* **As a player**, I want wooden boards to drop when their last screw is removed, and have their screws ejected from the tray, **so that** I recover holding capacity for future moves.
  * *Scenario*: Given a wooden board originally pinned by 2 screws where 1 screw is already in the tray, when the player moves the second screw into the tray, then the board unlocks, falls off-screen with gravity acceleration, and upon completing its drop, both screws are cleared from the tray, restoring 2 empty slots.

### US-03: Strategic Hole Capacity & Game Over Timing
* **As a player**, I want empty tray slots to be limited, and I want the game to let all animations finish before announcing game over, **so that** I understand why I lost without jarring interruptions.
  * *Scenario*: Given all 3 tray slots are filled and no boards have had all screws removed, when the last screw movement animation finishes settling and no boards are falling, then the game declares Game Over and presents options to Retry or Undo.

### US-04: Victory & Level Cleared
* **As a player**, I want to win the level when all boards are successfully dropped, **so that** I feel a sense of accomplishment.
  * *Scenario*: Given the final board drops off the screen, when the drop and tray clearing animations settle, then a celebratory "LEVEL CLEARED!" dialog appears with options to Replay or return to the Home Screen.

### US-05: Exact State Undo
* **As a player**, I want to undo my moves if I make a mistake, **so that** I can experiment without fear of frustrating restarts.
  * *Scenario*: Given a player moved a screw into a tray slot (and optionally caused a board to drop and clear tray slots), when they tap "Undo", then the exact previous snapshot is restored: the screw returns to its board, any fallen board is restored to its pinned state, tray occupancy is reverted, and accessibility is recomputed cleanly.

### US-06: Helpful Hint System
* **As a player**, I want a Hint button when I feel stuck, **so that** I can learn the winning strategy.
  * *Scenario*: Given a solvable board state, when the player taps "Hint", then the system calculates the optimal next move using pure Dart BFS logic without blocking UI rendering, and highlights the recommended screw with a pulsating gold halo.

### US-07: Level Restart & Navigation
* **As a player**, I want to restart the level or return to the home screen at any time, **so that** I am in full control of my session.
  * *Scenario*: Given an active game, when the player taps "Restart", the puzzle resets to its initial Level 1 state immediately; when they tap "Back" or "Home", they return to the main menu cleanly.

---

## 3. Game Architecture & Core Mechanics

### 3.1 Domain Data Model (Pure Dart, Zero Flutter UI)

```text
+-------------------------------------------------------------+
|                        GameState                            |
|-------------------------------------------------------------|
| - level: LevelData                                          |
| - boards: Map<String, WoodenBoardState>                     |
| - screws: Map<String, ScrewState>                           |
| - traySlots: List<String?> (fixed length: 3)                |
| - status: GameStatus (playing, won, lost)                   |
| - isInputLocked: bool                                       |
| - history: List<GameStateSnapshot>                          |
|-------------------------------------------------------------|
| + isScrewAccessible(screwId): bool                          |
| + applyMove(screwId): MoveResult                            |
| + undo(): bool                                              |
| + toSnapshot(): GameStateSnapshot                           |
| + restoreSnapshot(snapshot): void                           |
+-------------------------------------------------------------+
```

1. **`ScrewState`**:
   - `id`: Unique identifier (e.g., `screw_1a`).
   - `boardId`: The single wooden board this screw belongs to. **Every screw belongs to exactly one board**.
   - `position`: Coordinates `(x, y)` on the puzzle canvas where the screw sits while pinned.
   - `traySlot`: `null` if currently pinned on the board, or index `0, 1, 2` if currently resting in the tray.
2. **`WoodenBoardState`**:
   - `id`: Unique identifier (e.g., `board_1`).
   - `shape`: Bounding box `Rect` on the canvas: `Rect.fromLTWH(left, top, width, height)`.
   - `attachedScrewIds`: Set of screw IDs currently pinning this board.
   - `zIndex`: Stacking order (`0` = bottom, `1` = middle, `2` = top). Higher numbers render in front and obstruct lower boards.
   - `status`:
     - `pinned`: Board is held in place by $\ge 1$ attached screws.
     - `falling`: All attached screws have been moved to the tray; board is actively dropping.
     - `cleared`: Board has finished falling and exited the screen.
3. **`GameStateSnapshot` (Lossless Immutable State for Undo)**:
   - Stores deep immutable copies of `boards`, `screws`, `traySlots`, and `status`.
   - Guarantees 100% deterministic, complete state restoration upon Undo.

---

### 3.2 Dynamic Geometric Screw Accessibility & Hit-Testing

Rather than relying on mutable boolean flags that can become stale when boards drop or undos occur, **screw accessibility is derived dynamically as a pure function of board geometry, active pinned status, and z-order**:

$$\text{isScrewAccessible}(s, \text{state}) \iff \big(s.\text{traySlot} = \text{null}\big) \land \left( \forall B \in \text{state}.\text{pinnedBoards} : B.\text{zIndex} > s.\text{board}.\text{zIndex} \implies \neg B.\text{bounds}.\text{contains}(s.\text{position}) \right)$$

* **Rule 1 (In-Tray Invariance)**: A screw currently in the tray (`s.traySlot != null`) is off the board and cannot be tapped.
* **Rule 2 (Geometric Occlusion)**: A screw pinned on a board is **accessible** if and only if **no currently pinned board with a higher `zIndex` physically covers the screw's coordinate**.
* **Rule 3 (Top-Layer Accessibility Precedence)**:
  - Any screw belonging to the topmost active board (e.g. Board 3 with `zIndex: 2`) has no higher-layer board above it.
  - Therefore, all screws belonging to Board 3 are **unconditionally accessible** while pinned, regardless of whether Board 3's vertical plank crosses over other boards.
* **Rule 4 (Hit-Testing at Overlap Regions)**:
  - Each screw has a visual head radius $r = 12\,\text{dp}$ and an accessible touch target radius $R = 24\,\text{dp}$.
  - When the player taps coordinate $P(x, y)$:
    1. The hit-tester identifies all candidate screws within touch radius $\|P - S\| \le R$.
    2. If candidates exist across different z-orders, touch evaluation proceeds **strictly top-down** by board `zIndex`.
    3. If a covered screw (e.g., `screw_2b` on Board 2 or `screw_1b` on Board 1) lies directly beneath an overlapping higher board (Board 3), `isScrewAccessible` evaluates to `false`. The tap is absorbed by the surface of Board 3 and does not trigger the underlying screw.
    4. In Level 1, Board 3's own screws (`screw_3a` at $Y=170$ and `screw_3b` at $Y=375$) are intentionally placed in Board 3's non-overlapping zones (above Board 2 and below Board 1 respectively), ensuring 100% visual clarity and zero touch ambiguity.
* **Instant Recomputation**: When a board transitions to `cleared` or is restored via `undo()`, evaluating `isScrewAccessible` for all screws is instantaneous ($O(N_{\text{boards}} \times N_{\text{screws}})$, taking $< 0.05\text{ms}$ for Level 1).

---

### 3.3 Confirmed 3-Slot Tray & Unified Transition Rules

The gameplay state machine and the BFS puzzle solver use the **identical authoritative state transition logic**:

```dart
MoveResult applyMove(String screwId) {
  assert(isScrewAccessible(screwId));
  assert(traySlots.contains(null));

  // 1. Assign to lowest empty tray slot
  final targetSlot = traySlots.indexOf(null);
  traySlots[targetSlot] = screwId;

  final screw = screws[screwId]!;
  screw.traySlot = targetSlot;

  // 2. Remove screw from parent board's attached set
  final board = boards[screw.boardId]!;
  board.attachedScrewIds.remove(screwId);

  // 3. Check if board is now completely unscrewed
  final bool boardDropped = board.attachedScrewIds.isEmpty;
  if (boardDropped) {
    board.status = BoardStatus.falling;
  }

  return MoveResult(
    screwId: screwId,
    traySlot: targetSlot,
    boardDropped: boardDropped,
    droppedBoardId: boardDropped ? board.id : null,
  );
}

void finalizeBoardClear(String boardId) {
  final board = boards[boardId]!;
  board.status = BoardStatus.cleared;

  // Clear all screws belonging to this board from the tray
  for (int i = 0; i < traySlots.length; i++) {
    final sId = traySlots[i];
    if (sId != null && screws[sId]!.boardId == boardId) {
      traySlots[i] = null;
      screws[sId]!.traySlot = null; // Removed from tray
    }
  }
}
```

---

### 3.4 Animation-Safe Win and Lose Resolution

To prevent dialogs from interrupting active animations or creating visual glitches, win and lose conditions are evaluated **strictly after all active animations have settled**:

```text
User Taps Accessible Screw
      │
      ▼
Record Pre-Move Snapshot (history.add(toSnapshot()))
      │
      ▼
Lock Input (isInputLocked = true)
      │
      ▼
Animate Screw to Tray (250ms)
      │
      ▼
Board attachedScrewIds.isEmpty?
      │
   ├──(No)──> [Animations Complete] ──> Unlock Input ──> Done
   │
   └──(Yes)─> Animate Board Fall (400ms)
                    │
                    ▼
              finalizeBoardClear(boardId)
                    │
                    ▼
              Animate Tray Screw Ejection (150ms)
                    │
                    ▼
              [All Animations Complete]
                    │
                    ├─── All Boards Cleared? ──(Yes)──> Transition GameStatus.won
                    │                                   Display "LEVEL CLEARED!" Modal
                    │
                    ├─── Tray Full (0 empty slots)
                    │    AND No Boards have 0 screws? ──(Yes)──> Transition GameStatus.lost
                    │                                            Display "OUT OF HOLES!" Modal
                    │
                    └─── (No) ──> Unlock Input (isInputLocked = false) ──> Continue Play
```

* **No Premature Loss**: If the 3rd tray slot is filled by the final screw of a board, Game Over is not triggered; the board immediately drops and clears its screws from the tray.
* **No Interrupted Animations**: Victory or Game Over dialogs only mount after all falling boards and tray ejections have visually settled.

---

### 3.5 Exact State Undo & Pure Dart BFS Hint Engine

#### Undo Engine (Lossless Snapshot Restoration)
* **Behavior**:
  - Tapping "UNDO" pops the most recent `GameStateSnapshot` from `history`.
  - The live state restores all fields from the snapshot (`boards`, `screws`, `traySlots`, `status`).
  - Because accessibility is a pure function of board geometry and z-index, accessibility is automatically and flawlessly restored without any manual tracking.
* **Constraints**:
  - Undo is disabled while `isInputLocked == true` (during animations).
  - Undo is disabled when `history.isEmpty`.
  - Unlimited undos are permitted up to the level's initial state.

#### Hint Engine (Pure Dart BFS Solver)
* **Unified Implementation**:
  - The `PuzzleSolver` imports and uses the exact same `GameState` model and `applyMove` / `finalizeBoardClear` transitions as the UI controller.
  - Explores state transitions using Breadth-First Search (BFS) to find the shortest winning sequence of moves.
* **Performance**:
  - For Level 1, BFS explores the complete state graph ($< 60$ distinct states) in $< 1\text{ms}$ synchronously, guaranteeing zero UI frame drops.
* **Player Guidance**:
  - Highlights the first screw of the winning branch with an animated golden halo ($3.0\text{s}$).
  - If the board is in a deadlock, displays: *"No winning path from here. Use Undo or Restart!"*.

---

## 4. Fully Specified Level 1 Design (The Inaugural Puzzle)

Level 1 is crafted to teach the core mechanics naturally: **layering**, **screw ownership**, **tray capacity management**, and **why the top board must be cleared first**.

### 4.1 Physical Canvas Coordinates & Geometries ($360 \times 500\,\text{dp}$)

```text
+-------------------------------------------------------+
|  [<- Back]               LEVEL 1            [Restart] |
+-------------------------------------------------------+
|                                                       |
|       [ TRAY:   ( Slot 0 )   ( Slot 1 )   ( Slot 2 ) ]|
|                                                       |
|                  +-----------------+                  |
|                  |     BOARD 3     |                  |
|                  | (screw_3a) (Top)|                  |
|                  +--------|--------+                  |
|      +--------------------|--------------------+      |
|      |  BOARD 2           | (Walnut, Layer 1)  |      |
|      | (screw_2a)         | [s_2b: Covered]    |      |
|      +--------------------|--------------------+      |
|                           |                           |
|      +--------------------|--------------------+      |
|      |  BOARD 1           | (Oak, Layer 0)     |      |
|      | (screw_1a)         | [s_1b: Covered]    |      |
|      +--------------------|--------------------+      |
|                  +--------|--------+                  |
|                  | (screw_3b) (Btm)|                  |
|                  |     BOARD 3     | (Teak, Layer 2)  |
|                  +-----------------+                  |
|                                                       |
+-------------------------------------------------------+
|          [ < Undo ]              [ Hint * ]           |
+-------------------------------------------------------+
```

### 4.2 Exact Component Geometries & Screw Coordinates

1. **Board 1 (Bottom Layer, Oak, `zIndex: 0`)**:
   - Bounds: `Rect.fromLTWH(40, 310, 280, 50)` ($X \in [40, 320]$, $Y \in [310, 360]$).
   - Visual: Deep warm oak grain (`AppColors.woodMedium`).
   - Attached Screws (2):
     - `screw_1a`: at `(75, 335)`. Physically on Board 1 ($75 \in [40, 320]$, $335 \in [310, 360]$). Uncovered by higher boards $\rightarrow$ **Accessible initially**.
     - `screw_1b`: at `(180, 335)`. Physically on Board 1 ($180 \in [40, 320]$, $335 \in [310, 360]$). Covered by Board 3 ($180 \in [150, 210]$, $335 \in [140, 400]$) $\rightarrow$ **Inaccessible initially**.
2. **Board 2 (Middle Layer, Walnut, `zIndex: 1`)**:
   - Bounds: `Rect.fromLTWH(40, 210, 280, 50)` ($X \in [40, 320]$, $Y \in [210, 260]$).
   - Visual: Medium walnut grain (`AppColors.woodLight`).
   - Attached Screws (2):
     - `screw_2a`: at `(75, 235)`. Physically on Board 2 ($75 \in [40, 320]$, $235 \in [210, 260]$). Uncovered $\rightarrow$ **Accessible initially**.
     - `screw_2b`: at `(180, 235)`. Physically on Board 2 ($180 \in [40, 320]$, $235 \in [210, 260]$). Covered by Board 3 ($180 \in [150, 210]$, $235 \in [140, 400]$) $\rightarrow$ **Inaccessible initially**.
3. **Board 3 (Top Layer, Teak, `zIndex: 2`)**:
   - Bounds: `Rect.fromLTWH(150, 140, 60, 260)` ($X \in [150, 210]$, $Y \in [140, 400]$).
   - Visual: Light teak plank (`AppColors.woodSurface`) with prominent drop shadows over Board 2 and Board 1.
   - Attached Screws (2):
     - `screw_3a`: at `(180, 170)`. Physically on Board 3 ($180 \in [150, 210]$, $170 \in [140, 400]$). Above Board 2 ($170 < 210$) $\rightarrow$ **Accessible initially** (`zIndex: 2`).
     - `screw_3b`: at `(180, 375)`. Physically on Board 3 ($180 \in [150, 210]$, $375 \in [140, 400]$). Below Board 1 ($375 > 360$) $\rightarrow$ **Accessible initially** (`zIndex: 2`).

### 4.3 Executably Verified Winning Sequence & Mathematical Solvability Proof

The exact Level 1 configuration above was modeled and verified by an automated BFS solver unit test using the authoritative `GameState.applyMove` transition logic:
* **Automated Test Suite**: [`test/unit/level_solvability_test.dart`](file:///Users/satyanarayanaraju/development/screw_escape/test/unit/level_solvability_test.dart)
* **Execution Command**:
  ```bash
  flutter test test/unit/level_solvability_test.dart
  ```
* **Actual Test Verification Results**:
  ```
  00:00 +0: Level 1 BFS Solvability & Pure Dart Transition Tests Level 1 is mathematically solvable in 6 moves using GameState.applyMove
  00:00 +1: Level 1 BFS Solvability & Pure Dart Transition Tests Initial screw accessibility matches geometric occlusion
  00:00 +2: Level 1 BFS Solvability & Pure Dart Transition Tests Covered screws dynamically become accessible when covering board falls
  00:00 +3: Level 1 BFS Solvability & Pure Dart Transition Tests Filling all 3 tray slots without dropping a board triggers GameStatus.lost
  00:00 +4: Level 1 BFS Solvability & Pure Dart Transition Tests Lossless Undo restores exact pre-move state deterministically
  00:00 +5: All tests passed!
  ```
* **Metrics Verified by Test Execution**:
  - Total distinct reachable game states explored: **53**.
  - Deadlock endpoints identified: **12**.
  - Peak tray occupancy on winning paths: **2 slots** (leaving a 1-slot safety buffer).
* **Authoritative Winning Move Sequences**:
  - **Canonical Top-Down Path (6 moves)**:
    1. Tap `screw_3a` $\rightarrow$ moves to Tray Slot 0 (`tray = [screw_3a, null, null]`).
    2. Tap `screw_3b` $\rightarrow$ moves to Tray Slot 1 (`tray = [screw_3a, screw_3b, null]`).
       - Board 3 has 0 remaining screws $\rightarrow$ Board 3 falls and clears!
       - `screw_3a` and `screw_3b` are ejected $\rightarrow$ `tray = [null, null, null]`.
       - With Board 3 cleared, `screw_1b` and `screw_2b` become dynamically **accessible**.
    3. Tap `screw_2a` $\rightarrow$ moves to Tray Slot 0 (`tray = [screw_2a, null, null]`).
    4. Tap `screw_2b` $\rightarrow$ moves to Tray Slot 1 (`tray = [screw_2a, screw_2b, null]`).
       - Board 2 has 0 remaining screws $\rightarrow$ Board 2 falls and clears!
       - `screw_2a` and `screw_2b` are ejected $\rightarrow$ `tray = [null, null, null]`.
    5. Tap `screw_1a` $\rightarrow$ moves to Tray Slot 0 (`tray = [screw_1a, null, null]`).
    6. Tap `screw_1b` $\rightarrow$ moves to Tray Slot 1 (`tray = [screw_1a, screw_1b, null]`).
       - Board 1 has 0 remaining screws $\rightarrow$ Board 1 falls and clears!
       - `screw_1a` and `screw_1b` are ejected $\rightarrow$ **LEVEL 1 WON!**
  - **Alternative Valid Path (discovered by BFS)**:
    `['screw_1a', 'screw_3a', 'screw_3b', 'screw_1b', 'screw_2a', 'screw_2b']` (tapping exposed `screw_1a` first, then clearing Board 3 to uncover `screw_1b`, clearing Board 1, then clearing Board 2).
  - In all winning variations, Board 3 must drop before Board 1 or Board 2 can be fully cleared.
* **Deadlock Trap Executably Verified**:
  - If a player taps `screw_1a` (Slot 0), `screw_2a` (Slot 1), and `screw_3a` (Slot 2):
  - Tray becomes `[screw_1a, screw_2a, screw_3a]`. All 3 slots are full.
  - Board 1 still needs `screw_1b` (covered by Board 3).
  - Board 2 still needs `screw_2b` (covered by Board 3).
  - Board 3 still needs `screw_3b` (uncovered, but rejected because tray has 0 empty slots).
  - `status == GameStatus.lost` is asserted and confirmed by automated test.

---

## 5. Functional Requirements

### Core Mechanics & State
* **REQ-002-01 (Deterministic Board Domain Model)**:
  - Game state, wooden boards, screws, and tray slots must be represented by pure Dart domain models completely decoupled from Flutter widgets.
* **REQ-002-02 (Tap-to-Move Interaction)**:
  - Tapping an accessible screw must automatically move it into the lowest-index empty tray slot ($0, 1, 2$).
* **REQ-002-03 (Single Screw Ownership)**:
  - Every screw must belong to exactly one wooden board (`boardId`).
* **REQ-002-04 (Tray Slot Capacity)**:
  - The holding tray must strictly constrain capacity to 3 slots.
  - Tapping a screw when all 3 slots are full must reject input with visual shake feedback and a toast.
* **REQ-002-05 (Board Release & Fall Animation)**:
  - When all screws attached to a wooden board are removed, the board must unlock and animate falling off-screen with accelerated gravity curve ($400\text{ms}$).
* **REQ-002-06 (Tray Clearing on Fall Complete)**:
  - Only when a board completely finishes falling and transitions to `cleared` status must its associated screws be ejected from the tray, restoring empty slot capacity.
* **REQ-002-07 (Animation-Safe Win Resolution)**:
  - The win condition must be evaluated and resolved strictly after all screw movement, board falling, and tray clearing animations have completed.
  - When all boards are `cleared`, the game transitions to `GameStatus.won` and presents the Level Cleared modal.
* **REQ-002-08 (Animation-Safe Lose Resolution)**:
  - The lose condition must be evaluated and resolved strictly after all screw movement, board falling, and tray clearing animations have completed.
  - When all 3 tray slots are full and no boards have 0 attached screws, the game transitions to `GameStatus.lost` and presents the Game Over modal.

### Controls & Assistance
* **REQ-002-09 (Lossless Snapshot Undo)**:
  - Tapping "UNDO" must pop the previous `GameStateSnapshot` and restore the exact pre-move state (tray slots, boards, screws, and derived accessibility).
  - Unlimited undos are supported back to the level start state.
* **REQ-002-10 (Unified Pure Dart BFS Hint Engine)**:
  - Tapping "HINT" must execute the BFS solver using the authoritative gameplay transition rules to identify the next winning screw and highlight it with an animated golden halo ($3.0\text{s}$).
  - If the state is deadlocked, Hint must display an informative toast advising the player to Undo or Restart.
* **REQ-002-11 (Level Restart)**:
  - Tapping "Restart" must reset the board, screws, tray, and move history to the initial Level 1 state.

### Level Specification & Solvability
* **REQ-002-12 (Declarative Level 1 Specification)**:
  - Level 1 must be defined as an immutable data structure specifying exact board geometries, overlap relationships, screw coordinates, and 3 tray slots.
* **REQ-002-13 (Automated Solvability Test)**:
  - An automated pure Dart unit test must run the BFS solver against Level 1, mathematically proving it is solvable in 6 moves.

### UI & Aesthetics
* **REQ-002-14 (Strict Native Visuals)**:
  - All boards, screws, tray sockets, and HUD components must be rendered using native Flutter widgets (`CustomPainter`, `BoxDecoration`, gradients) without external image files.
* **REQ-002-15 (Smooth Animation Pipeline)**:
  - Screw translation to tray ($250\text{ms}$), board gravity drop ($400\text{ms}$), and tray clearing ($150\text{ms}$) must execute sequentially without frame stutter.
* **REQ-002-16 (Screen Navigation Integration)**:
  - Tapping "PLAY" on `HomeScreen` must navigate to the interactive `GameplayScreen` (replacing the temporary `GameplayPlaceholderScreen`).

---

## 6. Non-Functional Requirements

* **NFR-002-01 (60 FPS Performance)**:
  - Animations, hit testing, and state transitions must maintain a steady 60 FPS on baseline Android devices (Android 8.0+ / API 26+) without noticeable jank.
* **NFR-002-02 (Headless Domain Testability)**:
  - All core game logic (state machine, move validation, tray management, board unlocking, undo, and BFS solver) must run in pure Dart unit tests without Flutter engine dependencies.
* **NFR-002-03 (Zero Third-Party Game Engine)**:
  - Implementation must use Flutter's standard widget tree, `Canvas`, and `AnimationController`. Zero Flame, zero Box2D.
* **NFR-002-04 (Responsive Viewport Adaptation)**:
  - The puzzle canvas and tray must scale cleanly across Android screens from 320dp width to tablets, preserving aspect ratios and SafeAreas without `RenderFlex` overflow.
* **NFR-002-05 (100% Offline Capability)**:
  - Gameplay, Hint calculation, and state persistence must function completely offline.
* **NFR-002-06 (No Forced Advertising or Dark Patterns)**:
  - No interstitial ads, no banner ads, and no artificial wait timers during gameplay.

---

## 7. Edge Cases & Error States

* **EC-002-01 (Rapid Multi-Touch / Tap Spamming)**:
  - All touch inputs on the puzzle canvas must be locked (`isInputLocked = true`) while a screw movement or board fall animation is in progress, discarding rapid subsequent taps.
* **EC-002-02 (Filling 3rd Tray Slot on Winning Move)**:
  - When the 3rd tray slot is filled by the final screw of a board, Game Over must NOT trigger; the board must drop and clear its screws from the tray.
* **EC-002-03 (Undo During Animation)**:
  - The Undo and Hint buttons must be disabled while any screw movement or board fall animation is running.
* **EC-002-04 (Undo at Initial State)**:
  - The Undo button must be visually disabled when `history.isEmpty`.
* **EC-002-05 (Tapping Covered Screws)**:
  - A screw whose coordinate is covered by a board with a higher `zIndex` must not respond to touch.
* **EC-002-06 (Simultaneous Board Drops)**:
  - If a move simultaneously frees multiple boards, all freed boards must drop concurrently without state corruption.
* **EC-002-07 (Device Orientation)**:
  - Orientation remains locked strictly in `portraitUp`.

---

## 8. Acceptance Criteria

- [ ] **AC-002-01 (Playable Level 1 Launch)**: Tapping "PLAY" on `HomeScreen` opens `GameplayScreen` displaying Level 1 with 3 layered boards (Oak, Walnut, Teak), 6 screws, 3 tray slots, and HUD controls. (Traces: `REQ-002-12`, `REQ-002-16`)
- [ ] **AC-002-02 (Tap-to-Move to First Empty Slot)**: Tapping an accessible screw moves it into the lowest-index empty tray slot ($0, 1, 2$) within 250ms. (Traces: `REQ-002-02`, `REQ-002-15`)
- [ ] **AC-002-03 (Screw Single Ownership)**: Each screw is associated with exactly one board and remains in the tray until that board finishes falling. (Traces: `REQ-002-03`)
- [ ] **AC-002-04 (Board Fall Animation)**: When the second screw of a board is removed, the board animates dropping vertically with gravity curve ($400\text{ms}$) and clears. (Traces: `REQ-002-05`, `REQ-002-15`)
- [ ] **AC-002-05 (Tray Clearing on Fall Complete)**: When a board completes falling, its associated screws are removed from the tray, restoring empty slot capacity. (Traces: `REQ-002-06`)
- [ ] **AC-002-06 (Animation-Safe Game Over)**: Filling all 3 tray slots without clearing a board waits for animations to settle, locks further board taps, and displays the Game Over modal with Undo and Retry buttons. (Traces: `REQ-002-04`, `REQ-002-08`, `EC-002-02`)
- [ ] **AC-002-07 (Animation-Safe Victory)**: Clearing all 3 boards waits for all fall animations to settle, then displays the celebratory "LEVEL 1 CLEARED!" modal with Replay and Home buttons. (Traces: `REQ-002-07`)
- [ ] **AC-002-08 (Lossless Snapshot Undo)**: Tapping "UNDO" restores the exact pre-move `GameStateSnapshot` (tray slots, board statuses, screw positions, and accessibility) without state corruption. (Traces: `REQ-002-09`, `EC-002-03`)
- [ ] **AC-002-09 (Unified BFS Hint)**: Tapping "HINT" calculates the next winning screw using the authoritative game rules via BFS without blocking UI frames, highlighting it with a pulsating gold halo. (Traces: `REQ-002-10`)
- [ ] **AC-002-10 (Level Restart)**: Tapping "Restart" instantly resets the puzzle to the pristine Level 1 state. (Traces: `REQ-002-11`)
- [ ] **AC-002-11 (Mathematical Solvability Verified by Test)**: An automated BFS solver unit test passes, proving Level 1 is solvable in 6 moves. (Traces: `REQ-002-13`)
- [ ] **AC-002-12 (Strict Native Visuals & Zero Game Engine)**: All components render natively via Flutter canvas/widgets; zero image files and zero third-party game engines. (Traces: `REQ-002-14`, `NFR-002-03`)

---

## 9. Sign-off & Approvals

* **Specification Status**: `Approved & Finalized for Planning`
* **Reviewed By**: [Pending User Approval]
* **Approval Date**: 2026-11-03
