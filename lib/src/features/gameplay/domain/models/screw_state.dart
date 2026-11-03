/// Controlled mutable domain model representing a screw fastener.
class ScrewState {
  /// Unique identifier of the screw fastener (e.g., 'screw_1a').
  final String id;

  /// Identifier of the wooden board this screw belongs to.
  final String boardId;

  /// Logical X coordinate of the screw when pinned on the puzzle canvas.
  final double x;

  /// Logical Y coordinate of the screw when pinned on the puzzle canvas.
  final double y;

  /// Holding tray slot index (0, 1, or 2), or `null` if currently on the board.
  int? traySlot;

  ScrewState({
    required this.id,
    required this.boardId,
    required this.x,
    required this.y,
    this.traySlot,
  });

  /// Whether this screw currently rests in the holding tray.
  bool get isInTray => traySlot != null;

  /// Creates a deep clone of this screw state.
  ScrewState clone() {
    return ScrewState(
      id: id,
      boardId: boardId,
      x: x,
      y: y,
      traySlot: traySlot,
    );
  }
}
