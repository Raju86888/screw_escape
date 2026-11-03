import '../models/board_status.dart';
import '../models/game_state.dart';
import '../models/game_status.dart';
import '../models/screw_state.dart';
import '../models/wooden_board_state.dart';

/// Declarative layout definition and factory for Level 1 ("The Inaugural Puzzle").
abstract final class Level1Data {
  /// Logical canvas width for Level 1.
  static const double canvasWidth = 360.0;

  /// Logical canvas height for Level 1.
  static const double canvasHeight = 500.0;

  /// Creates a fresh, fully independent [GameState] representing the initial state of Level 1.
  ///
  /// Every invocation returns new collection and entity instances with zero
  /// shared mutable references across game sessions or solver exploration branches.
  static GameState create() {
    final boards = <String, WoodenBoardState>{
      'board_1': WoodenBoardState(
        id: 'board_1',
        left: 40.0,
        top: 310.0,
        width: 280.0,
        height: 50.0,
        zIndex: 0,
        attachedScrewIds: {'screw_1a', 'screw_1b'},
        status: BoardStatus.pinned,
      ),
      'board_2': WoodenBoardState(
        id: 'board_2',
        left: 40.0,
        top: 210.0,
        width: 280.0,
        height: 50.0,
        zIndex: 1,
        attachedScrewIds: {'screw_2a', 'screw_2b'},
        status: BoardStatus.pinned,
      ),
      'board_3': WoodenBoardState(
        id: 'board_3',
        left: 150.0,
        top: 140.0,
        width: 60.0,
        height: 260.0,
        zIndex: 2,
        attachedScrewIds: {'screw_3a', 'screw_3b'},
        status: BoardStatus.pinned,
      ),
    };

    final screws = <String, ScrewState>{
      'screw_1a': ScrewState(
        id: 'screw_1a',
        boardId: 'board_1',
        x: 75.0,
        y: 335.0,
      ),
      'screw_1b': ScrewState(
        id: 'screw_1b',
        boardId: 'board_1',
        x: 180.0,
        y: 335.0,
      ),
      'screw_2a': ScrewState(
        id: 'screw_2a',
        boardId: 'board_2',
        x: 75.0,
        y: 235.0,
      ),
      'screw_2b': ScrewState(
        id: 'screw_2b',
        boardId: 'board_2',
        x: 180.0,
        y: 235.0,
      ),
      'screw_3a': ScrewState(
        id: 'screw_3a',
        boardId: 'board_3',
        x: 180.0,
        y: 170.0,
      ),
      'screw_3b': ScrewState(
        id: 'screw_3b',
        boardId: 'board_3',
        x: 180.0,
        y: 375.0,
      ),
    };

    return GameState(
      boards: boards,
      screws: screws,
      traySlots: [null, null, null],
      status: GameStatus.playing,
    );
  }
}

