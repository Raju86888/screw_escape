import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/board_status.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/game_state.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/game_status.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/screw_state.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/wooden_board_state.dart';

void main() {
  group('TASK-002-04: Authoritative GameState Transitions & Precedence Tests', () {
    late GameState gameState;

    setUp(() {
      // 3 boards:
      // board_3 (Teak, z:2, top) -> screw_3a, screw_3b
      // board_2 (Walnut, z:1, middle) -> screw_2a (exposed), screw_2b (covered by board_3)
      // board_1 (Oak, z:0, bottom) -> screw_1a (exposed), screw_1b (covered by board_3)
      final boards = {
        'board_1': WoodenBoardState(
          id: 'board_1',
          left: 40.0,
          top: 310.0,
          width: 280.0,
          height: 50.0,
          zIndex: 0,
          attachedScrewIds: {'screw_1a', 'screw_1b'},
        ),
        'board_2': WoodenBoardState(
          id: 'board_2',
          left: 40.0,
          top: 210.0,
          width: 280.0,
          height: 50.0,
          zIndex: 1,
          attachedScrewIds: {'screw_2a', 'screw_2b'},
        ),
        'board_3': WoodenBoardState(
          id: 'board_3',
          left: 150.0,
          top: 140.0,
          width: 60.0,
          height: 260.0,
          zIndex: 2,
          attachedScrewIds: {'screw_3a', 'screw_3b'},
        ),
      };

      final screws = {
        'screw_1a': ScrewState(id: 'screw_1a', boardId: 'board_1', x: 75.0, y: 335.0),
        'screw_1b': ScrewState(id: 'screw_1b', boardId: 'board_1', x: 180.0, y: 335.0),
        'screw_2a': ScrewState(id: 'screw_2a', boardId: 'board_2', x: 75.0, y: 235.0),
        'screw_2b': ScrewState(id: 'screw_2b', boardId: 'board_2', x: 180.0, y: 235.0),
        'screw_3a': ScrewState(id: 'screw_3a', boardId: 'board_3', x: 180.0, y: 170.0),
        'screw_3b': ScrewState(id: 'screw_3b', boardId: 'board_3', x: 180.0, y: 375.0),
      };

      gameState = GameState(boards: boards, screws: screws);
    });

    test('applyMove assigns screw to lowest empty tray slot and updates parent board', () {
      expect(gameState.traySlots, equals([null, null, null]));

      final result1 = gameState.applyMove('screw_3a');
      expect(result1.screwId, equals('screw_3a'));
      expect(result1.traySlot, equals(0));
      expect(result1.boardDropped, isFalse);
      expect(gameState.traySlots, equals(['screw_3a', null, null]));
      expect(gameState.screws['screw_3a']!.traySlot, equals(0));
      expect(gameState.boards['board_3']!.attachedScrewIds, equals({'screw_3b'}));
      expect(gameState.history.length, equals(1));

      final result2 = gameState.applyMove('screw_3b');
      expect(result2.screwId, equals('screw_3b'));
      expect(result2.traySlot, equals(1));
      expect(result2.boardDropped, isTrue);
      expect(result2.droppedBoardId, equals('board_3'));
      expect(gameState.traySlots, equals(['screw_3a', 'screw_3b', null]));
      expect(gameState.boards['board_3']!.status, equals(BoardStatus.falling));
      expect(gameState.boards['board_3']!.attachedScrewIds, isEmpty);
      expect(gameState.history.length, equals(2));
    });

    test('applyMove throws StateError when moving inaccessible screw', () {
      // screw_2b is occluded by board_3
      expect(
        () => gameState.applyMove('screw_2b'),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('inaccessible'),
        )),
      );
    });

    test('applyMove throws StateError when tray is full', () {
      gameState.applyMove('screw_1a'); // Slot 0
      gameState.applyMove('screw_2a'); // Slot 1
      gameState.applyMove('screw_3a'); // Slot 2
      expect(gameState.traySlots, equals(['screw_1a', 'screw_2a', 'screw_3a']));

      // Any further move must throw StateError
      expect(
        () => gameState.applyMove('screw_3b'),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('full'),
        )),
      );
    });

    test('finalizeBoardClear sets board cleared, ejects screws from tray, and frees slots', () {
      gameState.applyMove('screw_3a'); // Slot 0
      gameState.applyMove('screw_3b'); // Slot 1
      expect(gameState.traySlots, equals(['screw_3a', 'screw_3b', null]));

      gameState.finalizeBoardClear('board_3');

      expect(gameState.boards['board_3']!.status, equals(BoardStatus.cleared));
      // Slots 0 and 1 are cleared
      expect(gameState.traySlots, equals([null, null, null]));
      expect(gameState.screws['screw_3a']!.traySlot, isNull);
      expect(gameState.screws['screw_3b']!.traySlot, isNull);
      // Covered screws on board_2 and board_1 become accessible
      expect(gameState.isScrewAccessible('screw_2b'), isTrue);
      expect(gameState.isScrewAccessible('screw_1b'), isTrue);
    });

    test('Terminal-State Precedence: Win condition unconditionally supersedes lose condition', () {
      // Drop board 3
      gameState.applyMove('screw_3a');
      gameState.applyMove('screw_3b');
      gameState.finalizeBoardClear('board_3');

      // Drop board 2
      gameState.applyMove('screw_2a');
      gameState.applyMove('screw_2b');
      gameState.finalizeBoardClear('board_2');

      // Drop board 1 (final board)
      gameState.applyMove('screw_1a');
      gameState.applyMove('screw_1b');
      gameState.finalizeBoardClear('board_1');

      // Status must be won
      expect(gameState.status, equals(GameStatus.won));

      // Attempting to evaluate lose condition must NOT overwrite won status
      gameState.evaluateLoseCondition();
      expect(gameState.status, equals(GameStatus.won));
    });

    test('Filling all 3 tray slots without clearing a board results in GameStatus.lost', () {
      gameState.applyMove('screw_1a'); // Slot 0
      gameState.applyMove('screw_2a'); // Slot 1
      gameState.applyMove('screw_3a'); // Slot 2

      expect(gameState.traySlots.contains(null), isFalse);
      gameState.evaluateLoseCondition();
      expect(gameState.status, equals(GameStatus.lost));

      // Once lost, evaluateLoseCondition does not alter it
      gameState.evaluateLoseCondition();
      expect(gameState.status, equals(GameStatus.lost));
    });

    test('Filling 3rd tray slot by final screw of a board drops board and avoids GameStatus.lost', () {
      // Slot 0: screw_1a
      gameState.applyMove('screw_1a');
      // Slot 1: screw_3a
      gameState.applyMove('screw_3a');
      // Slot 2: screw_3b (frees board_3!)
      final result = gameState.applyMove('screw_3b');
      expect(result.boardDropped, isTrue);

      // Finalize board_3 clear before evaluating lose condition
      gameState.finalizeBoardClear('board_3');
      gameState.evaluateLoseCondition();

      // board_3 cleared screws 3a and 3b, leaving only screw_1a in tray
      expect(gameState.traySlots, equals(['screw_1a', null, null]));
      expect(gameState.status, equals(GameStatus.playing));
    });

    test('undo restores exact pre-move state and accessibility deterministically', () {
      expect(gameState.history, isEmpty);
      expect(gameState.undo(), isFalse); // No history to undo

      // Move 1
      gameState.applyMove('screw_3a');
      expect(gameState.traySlots[0], equals('screw_3a'));
      expect(gameState.history.length, equals(1));

      // Undo move 1
      expect(gameState.undo(), isTrue);
      expect(gameState.traySlots[0], isNull);
      expect(gameState.screws['screw_3a']!.isInTray, isFalse);
      expect(gameState.boards['board_3']!.attachedScrewIds.contains('screw_3a'), isTrue);
      expect(gameState.history, isEmpty);

      // Move 2 screws and drop board 3
      gameState.applyMove('screw_3a');
      gameState.applyMove('screw_3b');
      gameState.finalizeBoardClear('board_3');
      expect(gameState.boards['board_3']!.status, equals(BoardStatus.cleared));
      expect(gameState.isScrewAccessible('screw_2b'), isTrue);

      // Undo the second move
      gameState.undo();
      // Board 3 is restored to pinned with screw_3b attached
      expect(gameState.boards['board_3']!.status, equals(BoardStatus.pinned));
      expect(gameState.boards['board_3']!.attachedScrewIds, equals({'screw_3b'}));
      expect(gameState.screws['screw_3b']!.isInTray, isFalse);
      // screw_2b is dynamically occluded again
      expect(gameState.isScrewAccessible('screw_2b'), isFalse);
    });

    test('clone provides deep-copy isolation including history snapshots', () {
      gameState.applyMove('screw_3a');
      expect(gameState.history.length, equals(1));

      final clonedState = gameState.clone();

      // Verify identical values
      expect(clonedState.boards.keys, equals(gameState.boards.keys));
      expect(clonedState.screws.keys, equals(gameState.screws.keys));
      expect(clonedState.traySlots, equals(gameState.traySlots));
      expect(clonedState.status, equals(gameState.status));
      expect(clonedState.history.length, equals(1));

      // Mutate cloned state boards and history
      clonedState.boards['board_1']!.attachedScrewIds.clear();
      clonedState.traySlots[1] = 'screw_2a';
      clonedState.history.clear();

      // Original state must be completely untouched
      expect(gameState.boards['board_1']!.attachedScrewIds, equals({'screw_1a', 'screw_1b'}));
      expect(gameState.traySlots[1], isNull);
      expect(gameState.history.length, equals(1));
    });
  });
}
