/// Lifecycle status of a wooden board in Screw Escape.
enum BoardStatus {
  /// The board is pinned in place by one or more attached screws.
  pinned,

  /// All attached screws have been removed; the board is animating its fall.
  falling,

  /// The board has completed its fall animation and is cleared from the canvas.
  cleared,
}

