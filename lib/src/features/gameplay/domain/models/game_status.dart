/// Overall gameplay progression status.
enum GameStatus {
  /// The puzzle is actively in progress.
  playing,

  /// All boards have dropped and cleared off-screen (Victory).
  won,

  /// All holding tray slots are full and no board can drop (Deadlock).
  lost,
}
