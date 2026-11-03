import 'board_status.dart';
import 'game_state_snapshot.dart';
import 'game_status.dart';
import 'move_result.dart';
import 'screw_state.dart';
import 'wooden_board_state.dart';

/// Authoritative Game State Engine for Screw Escape.
class GameState {
  /// Map of wooden board states by board ID.
  final Map<String, WoodenBoardState> boards;

  /// Map of screw fastener states by screw ID.
  final Map<String, ScrewState> screws;

  /// Holding tray slots (strictly fixed length of 3: indices 0, 1, 2).
  final List<String?> traySlots;

  /// Current game progression status (playing, won, lost).
  GameStatus status;

  /// Undo history recording pre-move snapshots.
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

  /// Dynamic pure geometric accessibility query.
  ///
  /// A screw is accessible if:
  /// 1. It is not currently in the tray (`traySlot == null`).
  /// 2. Its owning board is currently in `BoardStatus.pinned` status.
  /// 3. No currently pinned board with a higher `zIndex` physically covers its `(x, y)` coordinate.
  bool isScrewAccessible(String screwId) {
    final screw = screws[screwId];
    if (screw == null || screw.isInTray) return false;

    final owningBoard = boards[screw.boardId];
    if (owningBoard == null || owningBoard.status != BoardStatus.pinned) {
      return false;
    }

    for (final board in boards.values) {
      if (board.status == BoardStatus.pinned &&
          board.zIndex > owningBoard.zIndex &&
          board.containsPoint(screw.x, screw.y)) {
        return false;
      }
    }
    return true;
  }

  /// Authoritative move transition.
  ///
  /// Moves an accessible screw into the lowest-index empty tray slot.
  /// If this was the last screw pinning its board, marks the board as `falling`.
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

    // 2. Remove screw from parent board's attached set
    final board = boards[screw.boardId]!;
    board.attachedScrewIds.remove(screwId);

    // 3. Check board unlocking condition
    final bool boardDropped = board.attachedScrewIds.isEmpty;
    if (boardDropped) {
      board.status = BoardStatus.falling;
    }

    final clearedScrewIds = boardDropped
        ? screws.values
            .where((s) => s.boardId == board.id && s.isInTray)
            .map((s) => s.id)
            .toList()
        : const <String>[];

    return MoveResult(
      screwId: screwId,
      traySlot: targetSlot,
      boardDropped: boardDropped,
      droppedBoardId: boardDropped ? board.id : null,
      clearedScrewIds: clearedScrewIds,
    );
  }

  /// Finalizes the clearing of a fallen wooden board.
  ///
  /// Ejects all screws associated with this board from the tray, restoring
  /// empty capacity, and evaluates the Win condition with strict precedence.
  void finalizeBoardClear(String boardId) {
    final board = boards[boardId];
    if (board == null) return;

    board.status = BoardStatus.cleared;

    // Eject all screws associated with this board from the tray
    for (int i = 0; i < traySlots.length; i++) {
      final sId = traySlots[i];
      if (sId != null && screws[sId]!.boardId == board.id) {
        traySlots[i] = null;
        screws[sId]!.traySlot = null;
      }
    }

    // Evaluate Win condition FIRST (Strict Terminal Precedence)
    if (boards.values.every((b) => b.status == BoardStatus.cleared)) {
      status = GameStatus.won;
    }
  }

  /// Evaluates the Lose condition.
  ///
  /// Strictly guarded so that terminal states (won or lost) are never mutated.
  void evaluateLoseCondition() {
    // Terminal Precedence Guard: never overwrite a terminal status (won or lost)
    if (status != GameStatus.playing) return;

    // Lose condition: Tray is full AND no board has 0 attached screws
    if (!traySlots.contains(null) &&
        !boards.values.any((b) => b.attachedScrewIds.isEmpty)) {
      status = GameStatus.lost;
    }
  }

  /// Creates a lossless immutable snapshot of current state.
  GameStateSnapshot toSnapshot() {
    return GameStateSnapshot(
      boards: boards,
      screws: screws,
      traySlots: traySlots,
      status: status,
    );
  }

  /// Restores exact pre-move state from snapshot.
  void restoreSnapshot(GameStateSnapshot snapshot) {
    boards.clear();
    boards.addAll(snapshot.boards.map((k, v) => MapEntry(k, v.clone())));
    screws.clear();
    screws.addAll(snapshot.screws.map((k, v) => MapEntry(k, v.clone())));
    traySlots.clear();
    traySlots.addAll(snapshot.traySlots);
    status = snapshot.status;
  }

  /// Undoes the last move cleanly using snapshot restoration.
  bool undo() {
    if (history.isEmpty) return false;
    final snapshot = history.removeLast();
    restoreSnapshot(snapshot);
    return true;
  }

  /// Deeply clones the GameState, including every board, screw, tray slot,
  /// AND every GameStateSnapshot inside history. Zero shared collections or objects.
  GameState clone() {
    return GameState(
      boards: boards,
      screws: screws,
      traySlots: traySlots,
      status: status,
      history: history.map((s) => s.clone()).toList(),
    );
  }
}
