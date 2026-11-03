import 'game_status.dart';
import 'screw_state.dart';
import 'wooden_board_state.dart';

/// Deeply cloned point-in-time snapshot enabling lossless, deterministic Undo.
class GameStateSnapshot {
  /// Deeply cloned map of wooden boards.
  final Map<String, WoodenBoardState> boards;

  /// Deeply cloned map of screws.
  final Map<String, ScrewState> screws;

  /// Deeply cloned holding tray slots (fixed length: 3).
  final List<String?> traySlots;

  /// Gameplay status at the time of the snapshot.
  final GameStatus status;

  GameStateSnapshot({
    required Map<String, WoodenBoardState> boards,
    required Map<String, ScrewState> screws,
    required List<String?> traySlots,
    required this.status,
  })  : boards = boards.map((k, v) => MapEntry(k, v.clone())),
        screws = screws.map((k, v) => MapEntry(k, v.clone())),
        traySlots = List<String?>.from(traySlots);

  /// Creates a deep copy of this snapshot.
  GameStateSnapshot clone() {
    return GameStateSnapshot(
      boards: boards,
      screws: screws,
      traySlots: traySlots,
      status: status,
    );
  }
}
