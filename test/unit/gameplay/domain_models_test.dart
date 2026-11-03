import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/board_status.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/game_status.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/screw_state.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/wooden_board_state.dart';

void main() {
  group('TASK-002-01: Domain Models & Deep-Copy Isolation Tests', () {
    test('BoardStatus enum defines pinned, falling, cleared', () {
      expect(BoardStatus.values, equals([
        BoardStatus.pinned,
        BoardStatus.falling,
        BoardStatus.cleared,
      ]));
    });

    test('GameStatus enum defines playing, won, lost', () {
      expect(GameStatus.values, equals([
        GameStatus.playing,
        GameStatus.won,
        GameStatus.lost,
      ]));
    });

    test('ScrewState initializes correctly and clone provides deep copy isolation', () {
      final screw = ScrewState(
        id: 'screw_1a',
        boardId: 'board_1',
        x: 75.0,
        y: 335.0,
      );

      expect(screw.id, equals('screw_1a'));
      expect(screw.boardId, equals('board_1'));
      expect(screw.x, equals(75.0));
      expect(screw.y, equals(335.0));
      expect(screw.traySlot, isNull);
      expect(screw.isInTray, isFalse);

      // Clone screw and mutate traySlot
      final clonedScrew = screw.clone();
      expect(clonedScrew.id, equals(screw.id));
      expect(clonedScrew.boardId, equals(screw.boardId));
      expect(clonedScrew.x, equals(screw.x));
      expect(clonedScrew.y, equals(screw.y));
      expect(clonedScrew.traySlot, isNull);

      clonedScrew.traySlot = 0;
      expect(clonedScrew.traySlot, equals(0));
      expect(clonedScrew.isInTray, isTrue);
      // Original screw remains untouched
      expect(screw.traySlot, isNull);
      expect(screw.isInTray, isFalse);
    });

    test('WoodenBoardState initializes, tests point containment, and clone isolates attachedScrewIds', () {
      final board = WoodenBoardState(
        id: 'board_1',
        left: 40.0,
        top: 310.0,
        width: 280.0,
        height: 50.0,
        zIndex: 0,
        attachedScrewIds: {'screw_1a', 'screw_1b'},
      );

      expect(board.id, equals('board_1'));
      expect(board.left, equals(40.0));
      expect(board.top, equals(310.0));
      expect(board.width, equals(280.0));
      expect(board.height, equals(50.0));
      expect(board.zIndex, equals(0));
      expect(board.status, equals(BoardStatus.pinned));
      expect(board.attachedScrewIds, equals({'screw_1a', 'screw_1b'}));

      // Point containment tests (bounds: X in [40, 320], Y in [310, 360])
      expect(board.containsPoint(40.0, 310.0), isTrue); // Top-left corner
      expect(board.containsPoint(320.0, 360.0), isTrue); // Bottom-right corner
      expect(board.containsPoint(180.0, 335.0), isTrue); // Center
      expect(board.containsPoint(39.9, 335.0), isFalse); // Left of board
      expect(board.containsPoint(320.1, 335.0), isFalse); // Right of board
      expect(board.containsPoint(180.0, 309.9), isFalse); // Above board
      expect(board.containsPoint(180.0, 360.1), isFalse); // Below board

      // Deep copy isolation
      final clonedBoard = board.clone();
      expect(clonedBoard.id, equals(board.id));
      expect(clonedBoard.attachedScrewIds, equals(board.attachedScrewIds));
      expect(clonedBoard.status, equals(BoardStatus.pinned));

      // Mutate cloned board's set and status
      clonedBoard.attachedScrewIds.remove('screw_1a');
      clonedBoard.status = BoardStatus.falling;

      expect(clonedBoard.attachedScrewIds, equals({'screw_1b'}));
      expect(clonedBoard.status, equals(BoardStatus.falling));
      // Original board remains untouched
      expect(board.attachedScrewIds, equals({'screw_1a', 'screw_1b'}));
      expect(board.status, equals(BoardStatus.pinned));
    });
  });
}

