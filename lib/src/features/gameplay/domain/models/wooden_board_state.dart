import 'board_status.dart';

/// Controlled mutable domain model representing a wooden plank board.
class WoodenBoardState {
  /// Unique identifier of the board (e.g., 'board_1').
  final String id;

  /// Logical X origin (left) on the puzzle canvas.
  final double left;

  /// Logical Y origin (top) on the puzzle canvas.
  final double top;

  /// Logical width of the plank in dp.
  final double width;

  /// Logical height of the plank in dp.
  final double height;

  /// Stacking z-index: higher values render in front and geometrically obstruct lower boards.
  final int zIndex;

  /// Set of screw IDs currently pinning this board.
  final Set<String> attachedScrewIds;

  /// Current physical status of the board.
  BoardStatus status;

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

  /// Checks whether logical coordinate point (px, py) lies within this board's bounding rectangle.
  bool containsPoint(double px, double py) {
    return px >= left && px <= left + width && py >= top && py <= top + height;
  }

  /// Creates a deep copy of this board with an isolated attachedScrewIds set.
  WoodenBoardState clone() {
    return WoodenBoardState(
      id: id,
      left: left,
      top: top,
      width: width,
      height: height,
      zIndex: zIndex,
      attachedScrewIds: Set<String>.from(attachedScrewIds),
      status: status,
    );
  }
}
