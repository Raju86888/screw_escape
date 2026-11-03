# Technical Implementation Plan: Core Gameplay

* **Feature ID**: `SPEC-002`
* **Spec Reference**: `specs/002-core-gameplay/spec.md`
* **Status**: `Final Plan (Pending Review)`
* **Author**: `Development Team`
* **Date**: `2026-11-03`

---

## 1. Architectural Strategy & Principles

This technical plan defines the implementation of **Feature 002: Core Gameplay** for "Screw Escape". It builds directly upon the architecture established in Feature 001 and strictly adheres to the project constitution and approved specification:

1. **Strict Separation of Concerns (Clean Architecture)**:
   - **Domain Layer (Pure Dart, Zero Flutter UI)**: Controlled mutable domain models with deep-copy isolation (`GameState`, `WoodenBoardState`, `ScrewState`), snapshot models for rollback (`GameStateSnapshot`), dynamic geometric accessibility computation, and the BFS solver (`PuzzleSolver`). 100% executable in headless Dart without Flutter engine or UI imports.
   - **Application / State Layer**: `GameplayController` (`ChangeNotifier`) orchestrating domain mutations, input locking, animation sequencing, and game status notifications.
   - **Presentation Layer (Flutter Widgets & CustomPainters)**: Responsive canvas rendering of layered planks, interactive screws, the 3-slot holding tray, HUD controls, and result modals. Purely reactive and decoupled from domain logic.
2. **Unified State Transition Logic & Terminal-State Precedence**:
   - The exact same authoritative state transition methods (`GameState.applyMove`, `finalizeBoardClear`, and `evaluateLoseCondition`) are used by both the interactive live game and the automated BFS puzzle solver.
   - The win condition has strict precedence over the lose condition: clearing all boards unconditionally results in `GameStatus.won`, and no state can transition to `lost` once won.
3. **Lossless Snapshot Undo**:
   - Every accepted move stores a complete, deeply cloned `GameStateSnapshot` in `history`. Undo performs an exact rollback of board states, tray slots, screw positions, and derived accessibility, avoiding fragile incremental reversals.
4. **Deep-Copy Isolation Across All States and History**:
   - All collections (`boards`, `screws`, `traySlots`, `attachedScrewIds`, and `history`) are deeply cloned upon snapshot creation and state cloning. Every `GameStateSnapshot` in `history` is deep-cloned whenever a state is cloned. Zero shared mutable references or collections can leak between Undo history or BFS search branches.
5. **Pure Geometric Accessibility**:
   - Screw accessibility is evaluated dynamically as a pure function of board bounding boxes, active pinned status, and z-order. Zero mutable or cached boolean flags that could become stale.
6. **Animation-Safe State Transitions & Strict Input Locking**:
   - Input is strictly locked across Screw taps, Undo, Hint, and Restart during active animations. Win/Lose evaluations and dialog triggers occur **strictly after all animations (screw translation, board gravity drop, and tray clearing) have visually settled**.
7. **Zero External Visuals & Zero Game Engine**:
   - Built exclusively with native Flutter widgets, `CustomPainter`, and `AnimationController`. Zero Flame, zero Box2D, zero external raster image files (`.png`/`.jpg`).

---

## 2. Proposed File Structure & Responsibilities

```text
lib/src/features/gameplay/
├── domain/
│   ├── models/
│   │   ├── board_status.dart            # BoardStatus enum: pinned, falling, cleared
│   │   ├── game_status.dart             # GameStatus enum: playing, won, lost
│   │   ├── screw_state.dart             # ScrewState model: id, boardId, (x, y), traySlot
│   │   ├── wooden_board_state.dart      # WoodenBoardState model: id, rect, zIndex, attachedScrewIds, status
│   │   ├── game_state_snapshot.dart     # Deeply cloned snapshot for lossless Undo
│   │   ├── move_result.dart             # Result payload of applyMove (traySlot, boardDropped, etc.)
│   │   └── game_state.dart              # Authoritative GameState: boards, screws, tray, applyMove, undo
│   ├── levels/
│   │   └── level_1_data.dart            # Canonical Level 1 factory definition
│   └── solver/
│       └── puzzle_solver.dart           # Pure Dart BFS solver using GameState.applyMove
├── application/
│   └── gameplay_controller.dart         # ChangeNotifier: state orchestration, animation sequencing, input lock
└── presentation/
    ├── gameplay_screen.dart             # Main gameplay scaffold & layout container
    ├── widgets/
    │   ├── game_hud.dart                # Top bar: Back, Level Title, Restart
    │   ├── holding_tray_widget.dart     # Top 3-slot holding tray widget
    │   ├── puzzle_canvas.dart           # Interactive board canvas with responsive touch transform
    │   ├── wooden_board_widget.dart     # Individual board widget with gravity drop keyframe animation
    │   ├── interactive_screw_widget.dart# Tap detection, unscrewing depression, and translation animation
    │   ├── hint_highlight_widget.dart   # Pulsating golden halo overlay for hinted screw (3.0s)
    │   ├── level_win_dialog.dart        # Celebratory Level 1 Cleared modal
    │   └── game_over_dialog.dart        # Out of Holes modal with Undo and Retry
```

---

## 3. Domain Model Implementation & Snapshot Safety (Pure Dart)

### 3.1 Controlled Mutable Models with Deep-Copy Isolation

The domain entities (`ScrewState`, `WoodenBoardState`, and `GameState`) are implemented as **controlled mutable domain models** featuring encapsulated in-place mutations and strict deep-copy guarantees (`clone()`). This design provides optimal computational efficiency during BFS graph traversal while completely eliminating shared-reference corruption across Undo history stacks or solver branches:

```dart
// lib/src/features/gameplay/domain/models/board_status.dart
enum BoardStatus { pinned, falling, cleared }

// lib/src/features/gameplay/domain/models/game_status.dart
enum GameStatus { playing, won, lost }

// lib/src/features/gameplay/domain/models/screw_state.dart
class ScrewState {
  final String id;
  final String boardId;
  final double x;
  final double y;
  int? traySlot; // null if on board; 0, 1, 2 if in holding tray (controlled mutation)

  ScrewState({
    required this.id,
    required this.boardId,
    required this.x,
    required this.y,
    this.traySlot,
  });

  bool get isInTray => traySlot != null;

  ScrewState clone() => ScrewState(
        id: id,
        boardId: boardId,
        x: x,
        y: y,
        traySlot: traySlot,
      );
}

// lib/src/features/gameplay/domain/models/wooden_board_state.dart
class WoodenBoardState {
  final String id;
  final double left;
  final double top;
  final double width;
  final double height;
  final int zIndex;
  final Set<String> attachedScrewIds; // Controlled mutable set of attached screw IDs
  BoardStatus status;                 // Controlled mutable status (pinned -> falling -> cleared)

  WoodenBoardState({
    required this.id,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.zIndex,
    required Set<String> attachedScrewIds,
    this.status = BoardStatus.pinned,
  }) : attachedScrewIds = Set<String>.from(attachedScrewIds);

  bool containsPoint(double px, double py) =>
      px >= left && px <= left + width && py >= top && py <= top + height;

  WoodenBoardState clone() => WoodenBoardState(
        id: id,
        left: left,
        top: top,
        width: width,
        height: height,
        zIndex: zIndex,
        attachedScrewIds: Set<String>.from(attachedScrewIds), // Fresh Set instance
        status: status,
      );
}

// lib/src/features/gameplay/domain/models/game_state_snapshot.dart
class GameStateSnapshot {
  final Map<String, WoodenBoardState> boards;
  final Map<String, ScrewState> screws;
  final List<String?> traySlots;
  final GameStatus status;

  GameStateSnapshot({
    required Map<String, WoodenBoardState> boards,
    required Map<String, ScrewState> screws,
    required List<String?> traySlots,
    required this.status,
  })  : boards = boards.map((k, v) => MapEntry(k, v.clone())),
        screws = screws.map((k, v) => MapEntry(k, v.clone())),
        traySlots = List<String?>.from(traySlots);

  GameStateSnapshot clone() => GameStateSnapshot(
        boards: boards,
        screws: screws,
        traySlots: traySlots,
        status: status,
      );
}
```

### 3.2 Dynamic Geometric Accessibility Pure Function

Screw accessibility is derived strictly as a pure mathematical query over active boards:

```dart
// In GameState:
bool isScrewAccessible(String screwId) {
  final screw = screws[screwId];
  if (screw == null || screw.isInTray) return false;

  final owningBoard = boards[screw.boardId];
  if (owningBoard == null || owningBoard.status != BoardStatus.pinned) {
    return false;
  }

  // A screw is accessible if no pinned board with higher z-index physically covers its coordinate
  for (final board in boards.values) {
    if (board.status == BoardStatus.pinned &&
        board.zIndex > owningBoard.zIndex &&
        board.containsPoint(screw.x, screw.y)) {
      return false;
    }
  }
  return true;
}
```

### 3.3 Authoritative State Transitions & Terminal-State Precedence (`GameState`)

#### Terminal-State Precedence Rules
1. **Win Precedence**: The win condition takes strict precedence over the lose condition.
2. **Terminal Invariance**: Once `status` transitions to `GameStatus.won`, it is terminal and immutable. No subsequent check may transition the state to `lost`.
3. **Atomic Board Clearing Order**:
   - `applyMove(screwId)` places the screw in the tray, removes it from the board, and marks the board as `falling` if all its screws are removed.
   - `finalizeBoardClear(boardId)` sets the board to `cleared`, ejects its screws from `traySlots`, and immediately evaluates the **Win condition**. If all boards are cleared, `status` transitions to `GameStatus.won`.
   - `evaluateLoseCondition()` is executed only if `status == GameStatus.playing`. If `status` is already `won`, it immediately returns without evaluating.

```dart
class GameState {
  final Map<String, WoodenBoardState> boards;
  final Map<String, ScrewState> screws;
  final List<String?> traySlots; // length 3: [null, null, null]
  GameStatus status;
  final List<GameStateSnapshot> history;

  GameState({
    required Map<String, WoodenBoardState> boards,
    required Map<String, ScrewState> screws,
    List<String?>? traySlots,
    this.status = GameStatus.playing,
    List<GameStateSnapshot>? history,
  })  : boards = boards.map((k, v) => MapEntry(k, v.clone())),
        screws = screws.map((k, v) => MapEntry(k, v.clone())),
        traySlots = traySlots != null
            ? List<String?>.from(traySlots)
            : [null, null, null],
        history = history != null
            ? history.map((s) => s.clone()).toList()
            : [];

  MoveResult applyMove(String screwId) {
    if (!isScrewAccessible(screwId)) {
      throw StateError('Cannot move inaccessible screw: $screwId');
    }
    final targetSlot = traySlots.indexOf(null);
    if (targetSlot == -1) {
      throw StateError('Cannot move screw when tray is full');
    }

    // Capture complete snapshot before mutating
    history.add(toSnapshot());

    // 1. Place screw in first available tray slot
    traySlots[targetSlot] = screwId;
    final screw = screws[screwId]!;
    screw.traySlot = targetSlot;

    // 2. Remove screw from parent board
    final board = boards[screw.boardId]!;
    board.attachedScrewIds.remove(screwId);

    // 3. Check board unlocking condition
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

    // Eject all screws associated with this board from the tray
    for (int i = 0; i < traySlots.length; i++) {
      final sId = traySlots[i];
      if (sId != null && screws[sId]!.boardId == board.id) {
        traySlots[i] = null;
        screws[sId]!.traySlot = null;
      }
    }

    // Evaluate Win condition FIRST (Strict Precedence)
    if (boards.values.every((b) => b.status == BoardStatus.cleared)) {
      status = GameStatus.won;
    }
  }

  void evaluateLoseCondition() {
    // Strict Precedence Guard: never overwrite a terminal status (won or lost)
    if (status != GameStatus.playing) return;

    // Lose condition: Tray is full AND no board has 0 attached screws
    if (!traySlots.contains(null) &&
        !boards.values.any((b) => b.attachedScrewIds.isEmpty)) {
      status = GameStatus.lost;
    }
  }

  GameStateSnapshot toSnapshot() => GameStateSnapshot(
        boards: boards,
        screws: screws,
        traySlots: traySlots,
        status: status,
      );

  void restoreSnapshot(GameStateSnapshot snapshot) {
    boards.clear();
    boards.addAll(snapshot.boards.map((k, v) => MapEntry(k, v.clone())));
    screws.clear();
    screws.addAll(snapshot.screws.map((k, v) => MapEntry(k, v.clone())));
    traySlots.clear();
    traySlots.addAll(snapshot.traySlots);
    status = snapshot.status;
  }

  bool undo() {
    if (history.isEmpty) return false;
    final snapshot = history.removeLast();
    restoreSnapshot(snapshot);
    return true;
  }

  /// Deeply clones the GameState, including every board, screw, tray slot,
  /// AND every GameStateSnapshot inside history. Zero shared collections or objects.
  GameState clone() => GameState(
        boards: boards.map((k, v) => MapEntry(k, v.clone())),
        screws: screws.map((k, v) => MapEntry(k, v.clone())),
        traySlots: List<String?>.from(traySlots),
        status: status,
        history: history.map((s) => s.clone()).toList(),
      );
}
```

### 3.4 Canonical BFS State Key with Field Rationale

To prevent cycles, guarantee optimality, and avoid aliasing divergent states in the BFS solver, the canonical state key deterministically encodes all variables affecting future transitions:

```dart
String canonicalStateKey(GameState s) {
  // 1. Boards: sorted by ID
  final sortedBoardIds = s.boards.keys.toList()..sort();
  final bParts = sortedBoardIds.map((id) {
    final b = s.boards[id]!;
    final screws = b.attachedScrewIds.toList()..sort();
    return '$id:${b.status.name}:[${screws.join(",")}]';
  }).join(';');

  // 2. Screws: sorted by ID, recording tray assignment
  final sortedScrewIds = s.screws.keys.toList()..sort();
  final sParts = sortedScrewIds.map((id) {
    final sc = s.screws[id]!;
    return '$id:${sc.traySlot ?? "board"}';
  }).join(';');

  // 3. Tray slots: exact ordered occupancy (0, 1, 2)
  final tParts = s.traySlots.map((slot) => slot ?? '_').join(',');

  // 4. Game status: playing, won, lost
  final gPart = s.status.name;

  return 'B:$bParts#S:$sParts#T:$tParts#G:$gPart';
}
```

#### Field Rationale Documentation:
1. **Sorted Board IDs, Status, and Attached Screws (`B`)**:
   - `id`: Guarantees unique board attribution. Sorting keys ensures canonical string equivalence regardless of Map insertion order.
   - `status`: Determines whether the board is actively obstructing lower boards (`pinned`), in flight (`falling`), or cleared off-screen (`cleared`).
   - `attachedScrewIds`: Determines exactly how many and which screws remain before this board drops. Sorting the set prevents hash-set iteration variance from creating false duplicate keys.
2. **Sorted Screw IDs & Tray Assignment (`S`)**:
   - Tracks whether each screw is still attached on its board or sitting in tray slot 0, 1, or 2. This prevents any state aliasing if screws transition between board and tray.
3. **Tray Slot Occupancy Array (`T`)**:
   - Captures the exact ordered occupancy of slots 0, 1, and 2. Because moves always place screws in the lowest-index empty slot (`indexOf(null)`), the exact sequence of empty vs occupied slots directly dictates which slot subsequent moves will consume and whether deadlock occurs.
4. **GameStatus (`G`)**:
   - Explicitly records terminal states (`won`, `lost`) versus intermediate active states (`playing`). Ensures winning and lost terminal nodes are never conflated with active puzzle states.

---

## 4. Unified Pure Dart BFS Solver & Solvability Verification

### 4.1 Solver Architecture & State Exploration

The BFS solver (`PuzzleSolver`) operates directly on `GameState` using the authoritative state transition methods, with zero UI dependencies:

```dart
// lib/src/features/gameplay/domain/solver/puzzle_solver.dart
class PuzzleSolver {
  static SolverResult solve(GameState initial) {
    final queue = <_SolverNode>[_SolverNode(initial.clone(), [])];
    final visited = <String>{};
    List<String>? winningPath;
    int statesVisited = 0;
    int deadlocksFound = 0;

    visited.add(canonicalStateKey(initial));

    while (queue.isNotEmpty) {
      final node = queue.removeAt(0);
      statesVisited++;

      if (node.state.status == GameStatus.won) {
        winningPath ??= node.path;
        continue;
      }

      if (node.state.status == GameStatus.lost) {
        deadlocksFound++;
        continue;
      }

      if (!node.state.traySlots.contains(null)) {
        deadlocksFound++;
        continue;
      }

      for (final screwId in node.state.screws.keys) {
        if (!node.state.isScrewAccessible(screwId)) continue;

        final nextState = node.state.clone();
        final result = nextState.applyMove(screwId);
        if (result.boardDropped) {
          nextState.finalizeBoardClear(result.droppedBoardId!);
        }
        nextState.evaluateLoseCondition();

        final key = canonicalStateKey(nextState);
        if (!visited.contains(key)) {
          visited.add(key);
          queue.add(_SolverNode(nextState, [...node.path, screwId]));
        }
      }
    }

    return SolverResult(
      isSolvable: winningPath != null,
      shortestPath: winningPath ?? [],
      statesVisited: statesVisited,
      deadlocksFound: deadlocksFound,
    );
  }
}
```

### 4.2 Performance Target & Measurement Requirement

* **Performance Target**:
  - The BFS solver is targeted to complete exploration of Level 1 in **$< 5\,\text{ms}$** execution time.
* **Measurement & Verification Requirement**:
  - The $< 5\,\text{ms}$ threshold is a benchmark target and verification requirement, not an unconditional platform-wide guarantee.
  - It must be explicitly measured, profiled, and verified via automated test benchmarks ([`test/unit/level_solvability_test.dart`](file:///Users/satyanarayanaraju/development/screw_escape/test/unit/level_solvability_test.dart)) using `Stopwatch` before relying on synchronous in-game Hint execution.
  - Level 1's state space comprises 53 reachable states and 12 deadlock endpoints. Automated benchmarking in CI and unit tests ensures performance stays within budget and alerts if algorithm complexity regresses. If future complex level designs or low-end Android hardware ever exceed this benchmark, Hint execution can be offloaded asynchronously without modifying domain rules.

---

## 5. Solver vs. Animation Lifecycle & Input Locking

### 5.1 Dual-Lifecycle Architecture (Synchronous Domain vs Visual Controller)

The solver and the interactive gameplay controller share identical transition logic, but differ in execution timing:

| Lifecycle Dimension | Pure Dart Solver (`PuzzleSolver`) | Interactive Controller (`GameplayController`) |
| :--- | :--- | :--- |
| **Execution Mode** | Synchronous & Instantaneous | Asynchronous & Visual Animation Sequenced |
| **Move Application** | `applyMove(s)` executes synchronously in sub-millisecond Dart | `applyMove(s)` executes while screw translates ($250\,\text{ms}$) |
| **Board Fall** | `finalizeBoardClear(b)` executes immediately | Board animates gravity drop ($400\,\text{ms}$) before clear |
| **Tray Clearing** | Cleared immediately within `finalizeBoardClear` | Tray screws animate shrink & fade ($150\,\text{ms}$) |
| **Terminal Check** | Synchronous check on cloned state: Win check first, then Lose check | Evaluated strictly after all animations visually settle: Win first, then Lose |
| **Final State Equality** | **100% Identical**: Board statuses, screw positions, tray occupancy, and win/lose flags match. |

### 5.2 Strict Input Locking Lifecycle (`isInputLocked`)

To prevent tap spamming, race conditions, and animation glitches:

```text
User Taps Accessible Screw S
      │
      ▼
Check: isInputLocked || !isScrewAccessible(S) || trayFull?
      ├──(Yes)──> Reject Tap (Subtle shake feedback, no state change)
      └──(No)───> Proceed
                    │
                    ▼
              [LOCK INPUT]: isInputLocked = true; notifyListeners();
              • Screw Taps: Disabled
              • Undo Button: Disabled (opacity 0.5)
              • Hint Button: Disabled (opacity 0.5)
              • Restart Button: Disabled (opacity 0.5)
                    │
                    ▼
              [STEP 1: Screw Translation Animation] (250ms, Curves.easeInOutCubic)
              applyMove(S) updates GameState
                    │
                    ▼
              Board attachedScrewIds.isEmpty?
                    │
                 ├──(No)──> Animations Complete
                 │               │
                 │               ▼
                 │         evaluateLoseCondition()
                 │         status == lost ? Mount GameOverDialog : [UNLOCK INPUT] (isInputLocked = false)
                 │
                 └──(Yes)─> [STEP 2: Board Gravity Drop Animation] (400ms, Curves.easeInQuad + 8° tilt)
                                 │
                                 ▼
                           finalizeBoardClear(boardId) // Ejects screws from tray, evaluates Win condition
                                 │
                                 ▼
                           [STEP 3: Tray Screws Ejection Animation] (150ms shrink & fade)
                                 │
                                 ▼
                           [STEP 4: Terminal State Evaluation]
                           evaluateLoseCondition() // Evaluates Lose condition only if status == playing
                                 │
                                 ├── status == won  ──> Delay 100ms ──> Mount LevelWinDialog
                                 ├── status == lost ──> Delay 100ms ──> Mount GameOverDialog
                                 └── otherwise      ──> [UNLOCK INPUT] (isInputLocked = false)
```

### 5.3 Dialog Triggering & Animation Settlement

* **Settlement Buffer**: Dialogs are never presented while any sprite or board is moving. A $100\,\text{ms}$ post-settlement buffer ensures visual stillness before the modal barrier fades in.
* **Modal Controls**:
  - `LevelWinDialog`: Offers "Replay Level" and "Main Menu".
  - `GameOverDialog`: Offers "Undo Move" (pops dialog and restores pre-deadlock snapshot) and "Retry Level" (reloads Level 1).
  - Tapping dialog actions safely restores `isInputLocked = false` once the new board state is mounted.

---

## 6. Rendering Approach & Presentation Architecture

### 6.1 Puzzle Canvas Coordinate Space & Responsive Inverse Touch Transform

The puzzle canvas is designed in a normalized logical coordinate space of $360 \times 500\,\text{dp}$. To support all Android viewports (from 320dp phones up to 1200dp tablets), touch coordinates must be mapped back to logical canvas coordinates:

```dart
// Coordinate Transformation Math:
// Given screen container size (W_box, H_box):
final double scale = min(boxWidth / 360.0, boxHeight / 500.0);
final double renderedWidth = 360.0 * scale;
final double renderedHeight = 500.0 * scale;
final double dx = (boxWidth - renderedWidth) / 2.0;
final double dy = (boxHeight - renderedHeight) / 2.0;

// Inverse Touch Mapping:
Offset screenToLogical(Offset touch) {
  return Offset(
    (touch.dx - dx) / scale,
    (touch.dy - dy) / scale,
  );
}
```

* **Hit-Testing Algorithm**:
  1. Transform screen touch $P_{\text{screen}}$ to $P_{\text{logical}} = \text{screenToLogical}(P_{\text{screen}})$.
  2. If $P_{\text{logical}}$ is outside $([0, 360], [0, 500])$, discard tap.
  3. Identify all screws where Euclidean distance $\|P_{\text{logical}} - S\| \le R_{\text{touch}}$ ($R_{\text{touch}} = 24.0\,\text{dp}$).
  4. If multiple screws match, sort candidates descending by owning board `zIndex`.
  5. Select the topmost candidate. If `isScrewAccessible(candidate.id)` is true and `!isInputLocked`, trigger move; if inaccessible (covered by a higher board), absorb touch with no action.

### 6.2 Layered Wooden Boards (`WoodenBoardWidget` & `WoodSurface`)
- Rendered using native `WoodSurface` with wood grain gradients, chamfered borders, and depth drop-shadows.
- Stacking order in `Stack` is ordered by `board.zIndex` (Oak: 0, Walnut: 1, Teak: 2).
- When a board unlocks, `AnimatedBuilder` drives vertical translation ($Y \to Y + 600\,\text{dp}$) and slight angular tilt ($+8^{\circ}$), simulating natural gravity drop.

### 6.3 Interactive Screws (`InteractiveScrewWidget` & `ScrewAccent`)
- Rendered using `ScrewAccent` (brass gold finish with slotted head).
- Touch target: $48 \times 48\,\text{dp}$ ($R = 24\,\text{dp}$).
- Movement animation: `AnimatedPositioned` / `Transform.translate` from canvas $(x, y)$ to the assigned tray slot socket over $250\,\text{ms}$ with `Curves.easeInOutCubic`.

### 6.4 Holding Tray (`HoldingTrayWidget`)
- Fixed 3-slot horizontal container positioned at the top of the playfield.
- Each socket renders a beveled recessed socket (`BoxDecoration` with inner shadow).
- When occupied, renders the docked `ScrewAccent`.
- When cleared upon board drop, screws shrink (`scale: 1.0 -> 0.0`) and fade (`opacity: 1.0 -> 0.0`) over $150\,\text{ms}$.

### 6.5 Hint System & Non-Mutating Golden Halo (`HintHighlightWidget`)
- **Execution**: Tapping "HINT" invokes `PuzzleSolver.solve(gameState)`. This is a pure read-only query; zero state changes occur.
- **Winning Path Available**:
  - Target screw: `hintScrewId = result.shortestPath.first`.
  - An animated golden halo (`AppColors.metalGoldLight` / `0xFFFFD700`) pulses around the target screw for **$3.0\,\text{seconds}$** using a looping scale/opacity animation ($1.0\times$ to $1.25\times$).
  - Auto-dismisses after $3.0\,\text{s}$ or immediately if the player taps any screw.
- **Deadlock / No Path**:
  - No halo is displayed.
  - A non-blocking toast/snackbar appears: *"No winning path from here. Use Undo or Restart!"*.

---

## 7. Concrete Level 1 Layout Specification & Solvability

* **Canvas Dimensions**: $360 \times 500\,\text{dp}$.
* **Holding Tray**: 3 slots at the top.

```text
Canvas (360 x 500 dp)
├── Board 1 (Bottom, Oak, zIndex: 0):
│   ├── Rect: Rect.fromLTWH(40, 310, 280, 50)
│   ├── screw_1a: (75, 335)   -> Exposed, Accessible
│   └── screw_1b: (180, 335)  -> Covered by Board 3, Inaccessible
├── Board 2 (Middle, Walnut, zIndex: 1):
│   ├── Rect: Rect.fromLTWH(40, 210, 280, 50)
│   ├── screw_2a: (75, 235)   -> Exposed, Accessible
│   └── screw_2b: (180, 235)  -> Covered by Board 3, Inaccessible
└── Board 3 (Top, Teak, zIndex: 2):
    ├── Rect: Rect.fromLTWH(150, 140, 60, 260)
    ├── screw_3a: (180, 170)  -> Exposed (Top zone), Accessible
    └── screw_3b: (180, 375)  -> Exposed (Bottom zone), Accessible
```

* **Canonical 6-Move Winning Path**:
  `['screw_3a', 'screw_3b', 'screw_2a', 'screw_2b', 'screw_1a', 'screw_1b']`
* **Verified Deadlock Trap**:
  `['screw_1a', 'screw_2a', 'screw_3a']` $\rightarrow$ fills all 3 slots without clearing any board $\rightarrow$ `status == GameStatus.lost`.
* **Automated Test Evidence**:
  Fully verified by [`test/unit/level_solvability_test.dart`](file:///Users/satyanarayanaraju/development/screw_escape/test/unit/level_solvability_test.dart) (5/5 tests passing).

---

## 8. Integration with Feature 001

1. **Navigation Entry Point**:
   - In [`lib/src/features/home/presentation/home_screen.dart`](file:///Users/satyanarayanaraju/development/screw_escape/lib/src/features/home/presentation/home_screen.dart), tapping "PLAY" navigates to `GameplayScreen` (replacing `GameplayPlaceholderScreen`).
   - Debounced navigation guard (`_isNavigating` with `try/finally`) is preserved.
2. **Back Navigation**:
   - Tapping "BACK" in `GameHud` or Android back gesture pops back to `HomeScreen`.
3. **Sound Settings Integration**:
   - `GameplayController` observes `SettingsController.soundEnabled` for upcoming Feature 003 audio effects.
4. **Theme & Design Tokens**:
   - Uses `AppColors`, `AppTypography`, `AppSpacing`, `WoodSurface`, `ScrewAccent`, and `TactileButton` exclusively.

---

## 9. Testing Strategy

### 9.1 Pure Dart Unit Tests (Headless)
1. **Solvability & Benchmark Tests** (`test/unit/level_solvability_test.dart`):
   - Level 1 solvability in 6 moves.
   - Benchmark: BFS exploration time $< 5\,\text{ms}$ target measured via `Stopwatch`.
   - Deadlock trap detection.
   - Dynamic geometric accessibility changes upon board drop.
   - Lossless snapshot Undo across multiple moves.
2. **Domain Logic Tests** (`test/unit/gameplay/game_state_test.dart`):
   - Move validation, tray occupancy assignment.
   - Deep-copy snapshot verification (no shared references across state, clones, or history).
   - Terminal-state precedence verification (win condition unconditionally supersedes lose condition).
   - Board drop and tray ejection rules.

### 9.2 Widget Tests
1. **`holding_tray_widget_test.dart`**: Sockets render empty and filled states.
2. **`interactive_screw_widget_test.dart`**: Accessible vs covered touch targets.
3. **`gameplay_screen_test.dart`**:
   - Full Level 1 interactive playthrough to victory.
   - Deadlock triggering Game Over modal.
   - Undo restoring prior board and screw visual state.
   - Hint pulsating halo display for 3.0s and deadlock toast.
   - Restart button resets Level 1.
4. **`gameplay_navigation_test.dart`**: Home to Gameplay to Home navigation flow.

---

## 10. Technical Risks & Mitigations

| Risk | Impact | Mitigation Strategy |
| :--- | :--- | :--- |
| **Rapid Tap Spamming** | High | `isInputLocked = true` engaged synchronously on the initial tap frame, disabling all screws, Undo, Hint, and Restart until all animations visually settle. |
| **Premature Game Over on Board Clear** | High | Strict terminal-state precedence: `finalizeBoardClear` executes first and evaluates win condition. If all boards are cleared, `status = won` and `evaluateLoseCondition` immediately exits without mutating status. |
| **Touch Coordinate Misalignment on Small Screens** | High | Responsive inverse transformation (`screenToLogical`) maps screen pixels back to the $360 \times 500$ coordinate space, supporting viewports down to 320dp. |
| **Stale Accessibility Flags** | Medium | Accessibility is never stored as a mutable flag; it is evaluated dynamically via pure geometric query `isScrewAccessible(screw, state)`. |
| **Snapshot State Corruption** | High | Deep-copy constructors for `GameStateSnapshot` and `GameState.clone()` clone all sets, maps, lists, and snapshots in `history`, guaranteeing zero shared mutable references across history or solver branches. |
| **UI Stutter During Hint Calculation** | Low | Performance target of $< 5\,\text{ms}$ on Level 1 must be measured and verified via automated benchmark tests before synchronous Hint calculation is engaged; if execution ever exceeds the target on lower-end devices, hint calculation can be offloaded to an asynchronous compute task. |

---

## 11. Requirements & Acceptance Criteria Traceability Matrix

| Spec Requirement / AC | Architectural Component | Automated Test Reference |
| :--- | :--- | :--- |
| **REQ-002-01 / AC-002-01** (Board Domain Model) | `lib/src/features/gameplay/domain/models/` | `test/unit/gameplay/game_state_test.dart` |
| **REQ-002-02 / AC-002-02** (Tap-to-Move to First Slot) | `GameState.applyMove`, `GameplayController` | `test/unit/level_solvability_test.dart`, `gameplay_screen_test.dart` |
| **REQ-002-03 / AC-002-03** (Single Screw Ownership) | `ScrewState.boardId`, `WoodenBoardState.attachedScrewIds` | `test/unit/level_solvability_test.dart` |
| **REQ-002-04 / AC-002-06** (3-Slot Tray Capacity) | `GameState.traySlots` (fixed length: 3) | `test/unit/level_solvability_test.dart` |
| **REQ-002-05 / AC-002-04** (Board Release & Fall Animation)| `WoodenBoardWidget`, `GameState.finalizeBoardClear` | `gameplay_screen_test.dart` |
| **REQ-002-06 / AC-002-05** (Tray Clearing on Fall Complete)| `GameState.finalizeBoardClear`, `HoldingTrayWidget` | `test/unit/level_solvability_test.dart`, `gameplay_screen_test.dart` |
| **REQ-002-07 / AC-002-07** (Animation-Safe Win Resolution)| `GameplayController`, `LevelWinDialog` | `test/unit/level_solvability_test.dart`, `gameplay_screen_test.dart` |
| **REQ-002-08 / AC-002-06** (Animation-Safe Lose Resolution)| `GameplayController`, `GameOverDialog` | `test/unit/level_solvability_test.dart`, `gameplay_screen_test.dart` |
| **REQ-002-09 / AC-002-08** (Lossless Snapshot Undo) | `GameState.undo`, `GameStateSnapshot` | `test/unit/level_solvability_test.dart`, `gameplay_screen_test.dart` |
| **REQ-002-10 / AC-002-09** (Unified BFS Hint Engine) | `PuzzleSolver`, `HintHighlightWidget` | `test/unit/level_solvability_test.dart`, `gameplay_screen_test.dart` |
| **REQ-002-11 / AC-002-10** (Level Restart) | `GameplayController.restartLevel` | `gameplay_screen_test.dart` |
| **REQ-002-12 / AC-002-01** (Declarative Level 1 Data) | `lib/src/features/gameplay/domain/levels/level_1_data.dart` | `test/unit/level_solvability_test.dart` |
| **REQ-002-13 / AC-002-11** (BFS Solvability Proof) | `PuzzleSolver.solve` | `test/unit/level_solvability_test.dart` |
| **REQ-002-14 / AC-002-12** (Strict Native Visuals) | `WoodSurface`, `ScrewAccent`, `CustomPainter` | `gameplay_screen_test.dart` |
| **REQ-002-15 / AC-002-02** (Smooth Animation Pipeline) | `AnimationController` ($250\text{ms}, 400\text{ms}, 150\text{ms}$) | `gameplay_screen_test.dart` |
| **REQ-002-16 / AC-002-01** (Screen Navigation Integration) | `HomeScreen` Play CTA $\to$ `GameplayScreen` | `test/widget/gameplay_navigation_test.dart` |

---

## 12. Proposed Implementation Phases (For Tasks Phase)

When approved, `tasks.md` will break implementation down into atomic, testable phases:
- **Phase 1: Domain Entities & Game State Logic (Pure Dart TDD)**: Controlled mutable models with deep-copy isolation, deep-cloned snapshotting, terminal-state precedence, geometric accessibility, and unit tests.
- **Phase 2: BFS Solver & Solvability Verification**: Canonical state key, BFS search algorithm, performance benchmark target test ($< 5\,\text{ms}$).
- **Phase 3: Gameplay Controller & Animation Pipeline**: State orchestration, sequential animation timing, strict input locking (`isInputLocked`).
- **Phase 4: Presentation Components**: `HoldingTrayWidget`, `WoodenBoardWidget`, `InteractiveScrewWidget`, `HintHighlightWidget`, responsive `PuzzleCanvas`.
- **Phase 5: Gameplay Screen, Modals & Home Integration**: `GameHud`, `LevelWinDialog`, `GameOverDialog`, `HomeScreen` navigation hookup.
- **Phase 6: Full Regression, Responsiveness & Acceptance Verification**: Responsive layout tests (320dp to tablet), portrait locking, flutter analyze, full test suite pass.
