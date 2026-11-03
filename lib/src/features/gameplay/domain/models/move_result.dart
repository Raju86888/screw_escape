/// Result payload returned upon applying a move in GameState.
class MoveResult {
  /// The identifier of the screw that moved.
  final String screwId;

  /// The tray slot index (0, 1, or 2) the screw was moved into.
  final int traySlot;

  /// Whether moving this screw freed its parent board to fall.
  final bool boardDropped;

  /// The identifier of the board that dropped, or `null` if no board dropped.
  final String? droppedBoardId;

  /// Identifiers of any screws ejected from the tray upon a board clear.
  final List<String> clearedScrewIds;

  MoveResult({
    required this.screwId,
    required this.traySlot,
    required this.boardDropped,
    this.droppedBoardId,
    this.clearedScrewIds = const [],
  });
}

